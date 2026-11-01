const fs=require('node:fs'),path=require('node:path');
const configHash=config=>hash(Buffer.from(JSON.stringify(config)));
const {read,hash}=require('./rbxl-local.cjs');
const {inventory}=require('./rbxl-prompt-hold.cjs');
const normal=p=>typeof p==='string'?path.resolve(p).replace(/[\\/]+$/,'').toLowerCase():'';
function assess({root,config,health,status,saved,latestSourceMs=0,now=Date.now()}) {
 const result={stage:'bridge_unavailable',next:'prepare_bridge',expectedSources:config.scripts.length,
  editorSynced:0,editorVerified:false,saved,playVerified:false,cloudVerified:false};
 if(!health) return result;
 if(normal(health.workspaceRoot)!==normal(root)||health.projectKey!==config.projectKey) return {...result,stage:'wrong_clone',next:'inspect_other_bridge'};
 if(health.configSha256!==configHash(config)) return {...result,stage:'bridge_config_changed',next:'restart_owned_bridge'};
 if(!status||!health.online||!status.online) return {...result,stage:'awaiting_studio',next:'open_correct_working_and_allow_plugin'};
 const age=now-Date.parse(status.lastSeen);
 if(!Number.isFinite(age)||age< -2000||age>=8000||status.projectKey!==config.projectKey) return {...result,stage:'stale_status',next:'reconnect_and_read_fresh_status'};
 if(status.gameName!=='RobloxLearningMedia-WORKING.rbxl') return {...result,stage:'wrong_place',next:'open_correct_working'};
 if(status.running!==false) return {...result,stage:'awaiting_edit',next:'user_stop_play'};
 const scripts=Array.isArray(status.scripts)?status.scripts:[];
 if(scripts.some(s=>String(s.status).includes('conflict'))) return {...result,stage:'source_conflict',next:'preserve_both_versions_and_resolve'};
 const synced=config.scripts.filter(expected=>scripts.filter(s=>s.file===expected.file&&JSON.stringify(s.instancePath)===JSON.stringify(expected.instancePath)&&s.status==='synced_in_editor').length===1).length;
 result.editorSynced=synced;
 if(synced!==config.scripts.length||scripts.length!==config.scripts.length||latestSourceMs>Date.parse(status.lastSeen)) return {...result,stage:'syncing_editor',next:'wait_for_all_sources_and_readback'};
 result.editorVerified=true;
 if(!saved?.matches) return {...result,stage:'awaiting_save',next:'user_save_then_verify_disk'};
 return {...result,stage:'ready_for_play',next:'user_play_current_checklist'};
}
function diskState(root,config) {
 const file=path.join(root,'places/RobloxLearningMedia-WORKING.rbxl');
 try {
  const parsed=read(file),inv=inventory(file);
  const scripts=config.scripts.map(item=>{
   const hits=inv.instances.filter(i=>i.class===item.className&&JSON.stringify(i.instancePath)===JSON.stringify(item.instancePath));
   if(hits.length!==1)throw Error('Missing or ambiguous instance: '+item.file);
   const names=parsed.props.find(p=>p.class===item.className&&p.property==='Name')?.values||[];
   const ids=names.map((n,i)=>n.toString()===item.instancePath.at(-1)?i:-1).filter(i=>i>=0);
   if(ids.length!==1)throw Error('Missing or ambiguous source: '+item.file);
   const saved=parsed.props.find(p=>p.class===item.className&&p.property==='Source').values[ids[0]];
   const local=fs.readFileSync(path.join(root,item.file));
   return {file:item.file,matches:saved.equals(local),sourceSha256:hash(local),savedSha256:hash(saved)};
  });
  return {sha256:hash(parsed.bytes),bytes:parsed.bytes.length,matches:scripts.every(s=>s.matches),matched:scripts.filter(s=>s.matches).length,total:scripts.length,scripts};
 } catch(error) {return {matches:false,error:error.message};}
}
async function inspect(root) {
 root=path.resolve(root);
 const config=JSON.parse(fs.readFileSync(path.join(root,'studio-sync/project.json'),'utf8').replace(/^\uFEFF/,''));
 let health=null,healthError=null,status=null;
 try {const response=await fetch('http://127.0.0.1:'+config.port+'/health',{method:'POST',headers:{'X-Codex-Bridge':'rbxl-v1','Content-Type':'application/json'},body:'{}',signal:AbortSignal.timeout(2500)});if(response.ok)health=await response.json();else healthError='HTTP '+response.status;} catch(e){healthError=e.cause?.code||e.message;}
 try {status=JSON.parse(fs.readFileSync(path.join(root,'local-rbxl/bridge/status.json'),'utf8').replace(/^\uFEFF/,''));} catch {}
 const latestSourceMs=Math.max(...config.scripts.map(s=>fs.statSync(path.join(root,s.file)).mtimeMs));
 return {schemaVersion:1,checkedAt:new Date().toISOString(),workspaceRoot:root,workingPath:path.join(root,'places/RobloxLearningMedia-WORKING.rbxl'),
  ...assess({root,config,health,status,saved:diskState(root,config),latestSourceMs}),healthError,
  statusLastSeen:status?.lastSeen??null,managedSources:config.scripts.map(s=>s.file)};
}
module.exports={assess,diskState,inspect,configHash};
if(require.main===module)inspect(process.argv[2]||path.resolve(__dirname,'..')).then(r=>console.log(JSON.stringify(r,null,2))).catch(e=>{console.error(e.message);process.exitCode=1;});
