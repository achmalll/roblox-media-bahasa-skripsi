// Convert raw DataStore page values to CSV locally; does not contact Roblox or modify inputs.
const fs=require('node:fs'),path=require('node:path');
function summarize(pages) {
 const unique=new Map();
 for(const p of pages) {
  if(p.schemaVersion!==1||!Number.isSafeInteger(p.userId)||typeof p.sessionId!=='string'||!Number.isInteger(p.page)||p.page<1||!Array.isArray(p.events)||!p.levels) throw Error('Expected raw schemaVersion=1 page values');
  const id=[p.userId,p.sessionId,p.page].join('/'),old=unique.get(id);
  if(old&&old.revision===p.revision&&JSON.stringify(old)!==JSON.stringify(p)) throw Error('Conflicting copies of page '+id);
  if(!old||p.revision>old.revision) unique.set(id,p);
 }
 const groups=new Map();
 for(const p of unique.values()) {const id=p.userId+'/'+p.sessionId;if(!groups.has(id))groups.set(id,[]);groups.get(id).push(p);}
 const levels=[],events=[];
 for(const group of groups.values()) {
  group.sort((a,b)=>a.page-b.page);const last=group.at(-1);
  const completePages=group.length===last.page&&group.every((p,i)=>p.page===i+1);
  for(const p of group) for(const e of p.events) events.push({userId:p.userId,sessionId:p.sessionId,contentRevision:p.contentRevision,
   sequence:e.sequence,level:e.level,kind:e.kind,atMs:e.atMs,elapsedSeconds:e.elapsedSeconds,details:JSON.stringify(e.data)});
  for(const [level,t] of Object.entries(last.levels)) levels.push({userId:last.userId,sessionId:last.sessionId,contentRevision:last.contentRevision,
   level:Number(level),completed:t.completed,completedSeconds:t.completedSeconds??'',completedMinutes:t.completedSeconds==null?'':t.completedSeconds/60,
   observedSeconds:t.observedSeconds,timingQuality:t.timingQuality,bestScore:t.bestScore??'',sessionClosed:last.sessionClosed,
   closeReason:last.closeReason??'',pagesComplete:completePages,recordsComplete:!(last.droppedEvents>0),droppedEvents:last.droppedEvents??0});
 }
 events.sort((a,b)=>a.userId-b.userId||a.sessionId.localeCompare(b.sessionId)||a.sequence-b.sequence);
 return {levels,events};
}
function csv(rows,columns) {
 const cell=v=>'"'+String(v??'').replace(/"/g,'""')+'"';
 return [columns.join(','),...rows.map(r=>columns.map(c=>cell(r[c])).join(','))].join('\r\n')+'\r\n';
}
function main(input,output) {
 if(!input||!output)throw Error('Usage: node scripts/export-learning-records.cjs RAW_PAGE_JSON_DIRECTORY NEW_OUTPUT_DIRECTORY');
 if(fs.existsSync(output))throw Error('Output directory must be new');
 const files=fs.readdirSync(input).filter(f=>f.endsWith('.json')).sort();if(!files.length)throw Error('No JSON pages');
 const result=summarize(files.map(f=>JSON.parse(fs.readFileSync(path.join(input,f),'utf8').replace(/^\uFEFF/,''))));
 fs.mkdirSync(output,{recursive:true});
 fs.writeFileSync(path.join(output,'levels.csv'),csv(result.levels,['userId','sessionId','contentRevision','level','completed','completedSeconds','completedMinutes','observedSeconds','timingQuality','bestScore','sessionClosed','closeReason','pagesComplete','recordsComplete','droppedEvents']),{flag:'wx'});
 fs.writeFileSync(path.join(output,'attempts.csv'),csv(result.events,['userId','sessionId','contentRevision','sequence','level','kind','atMs','elapsedSeconds','details']),{flag:'wx'});
 console.log(JSON.stringify({pages:files.length,levels:result.levels.length,events:result.events.length,output:path.resolve(output)}));
}
module.exports={summarize,csv};
if(require.main===module)main(...process.argv.slice(2));
