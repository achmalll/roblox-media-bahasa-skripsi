const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const root=path.resolve(__dirname,'..');
const prelude=`
local callback,removed
local remote={FireClient=function() end,OnServerEvent={Connect=function(_,fn) callback=fn end}}
local players={PlayerRemoving={Connect=function(_,fn) removed=fn end}}
local kiosk={GetDescendants=function() return {} end,DescendantAdded={Connect=function() end}}
workspace={WaitForChild=function() return {WaitForChild=function() return kiosk end} end}
task={spawn=function() end}
game={GetService=function(_,name) if name=="Players" then return players end; return {WaitForChild=function() return remote end} end}
local function folder(v) v.FindFirstChild=function(self,name) return self[name] end; return v end
local function player(level) return folder({UserId=1,leaderstats=folder({LevelProgress={Value=level}}),PlayerScores=folder({Level1Score={Value=0},Level2Score={Value=100},Level3Score={Value=0}})}) end
`;
for(const [level,answers] of [[1,'2,3,2,5'],[3,'4,5,1,3']]) {
 const tests=`
local p=player(${level})
callback(p,100); assert(p.PlayerScores.Level${level}Score.Value==0)
callback(p,{id="nan",answers={0/0,1,1,1},reasons={1,1,1,1}}); assert(p.PlayerScores.Level${level}Score.Value==0)
callback(p,{id="pass",answers={${answers}},reasons={2,1,3,4}})
assert(p.PlayerScores.Level${level}Score.Value==100 and p.leaderstats.LevelProgress.Value==${level+1})
callback(p,{id="retry",answers={5,4,3,1},reasons={1,1,1,1}})
assert(p.PlayerScores.Level${level}Score.Value==100)
local other=player(${level}); callback(other,{id="fail",answers={5,4,3,1},reasons={1,1,1,1}})
assert(other.leaderstats.LevelProgress.Value==${level} and other.PlayerScores.Level${level}Score.Value==0)
${level===3?'local denied=player(2); callback(denied,{id="deny",answers={4,5,1,2}}); assert(denied.PlayerScores.Level3Score.Value==0)':''}
removed(p)
print("PASS L${level}: server choices, invalid numeric/NaN rejected, failure/retry, isolation, best score, atomic unlock")
`;
 const out=path.join(root,'local-rbxl/bridge/test-score-'+level+'.luau');fs.mkdirSync(path.dirname(out),{recursive:true});
 fs.writeFileSync(out,prelude+fs.readFileSync(path.join(root,'studio-sync/src/Level'+level+'ScoreHandler.server.luau'),'utf8')+tests);
 process.stdout.write(cp.execFileSync(path.join(root,'local-rbxl/luau-0.745/luau.exe'),[out],{encoding:'utf8'}));
}
const progressTest=`
local p=player(1)
callback(p,4); assert(p.leaderstats.LevelProgress.Value==1)
callback(p,2); assert(p.leaderstats.LevelProgress.Value==1)
p.PlayerScores.Level1Score.Value=75; callback(p,2); assert(p.leaderstats.LevelProgress.Value==2)
p.PlayerScores.Level2Score.Value=50; callback(p,3); assert(p.leaderstats.LevelProgress.Value==2)
p.PlayerScores.Level2Score.Value=75; callback(p,3); assert(p.leaderstats.LevelProgress.Value==3)
p.PlayerScores.Level3Score.Value=50; callback(p,4); assert(p.leaderstats.LevelProgress.Value==3)
p.PlayerScores.Level3Score.Value=75; callback(p,4); assert(p.leaderstats.LevelProgress.Value==4)
callback(p,0/0); callback(p,5); callback(p,1); assert(p.leaderstats.LevelProgress.Value==4)
print("PASS progress: each level requires prior score; early Level4 event cannot bypass evaluation")
`;
const progressFile=path.join(root,'local-rbxl/bridge/test-progress-recording.luau');
fs.writeFileSync(progressFile,prelude+fs.readFileSync(path.join(root,'studio-sync/templates/LevelProgressHandler.server.luau'),'utf8')+progressTest);
process.stdout.write(cp.execFileSync(path.join(root,'local-rbxl/luau-0.745/luau.exe'),[progressFile],{encoding:'utf8'}));
