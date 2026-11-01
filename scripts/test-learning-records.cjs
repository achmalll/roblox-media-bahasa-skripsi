const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8').replace(/^\uFEFF/,'');
const factory=read('studio-sync/recording/LearningRecordStore.luau');
const harness=`
local newRecorder=(function()\n${factory}\nend)()
local tick,utc,fail,warnings=0,100000,false,0
local disk={}
local function clone(v) if type(v)~="table" then return v end; local o={}; for k,x in pairs(v) do o[k]=clone(x) end; return o end
local function make(user,session)
 return newRecorder({userId=user,sessionId=session,placeId=1,jobId="test",startedAtMs=utc,contentRevision="fixture",
 now=function() return tick end,utc=function() return utc end,wait=function() end,warn=function() warnings+=1 end,
 write=function(key,data) if fail then error("network down") end; disk[user.."/"..key]=clone(data) end})
end
local a=make(1,"a"); a:start(1); tick=125; utc+=125000
assert(a:append(1,"practice",{choices={"B","A"},correct=false},"practice1"))
assert(a:append(1,"practice",{choices={"A","B"},correct=true},"practice2"))
assert(a:result(1,{id="fail",answers={1,1,1,1},reasons={1,1,1,1}},0,1))
assert(not a.levels["1"].completed)
tick=180; assert(a:result(1,{id="pass",answers={2,3,2,1},reasons={2,1,3,4}},75,4))
assert(a.levels["1"].completed and a.levels["1"].completedSeconds==180)
assert(not a:result(1,{id="pass",answers={5,5,5,5}},0))
tick=300; a:result(1,{id="retry",answers={2,3,2,5}},100)
assert(a.levels["1"].completedSeconds==180 and a.levels["1"].bestScore==100)
assert(a:flush() and disk["1/a:000001"].events[1].data.choices[1]=="B")
assert(#disk["1/a:000001"].events==5)
local b=make(2,"b"); b:start(2); tick=360; b:close("player_left"); b:flush()
assert(not disk["2/b:000001"].levels["2"].completed and disk["2/b:000001"].levels["2"].observedSeconds==60)
assert(disk["1/a:000001"].userId==1 and disk["2/b:000001"].userId==2)
local rejoin=make(1,"rejoin"); rejoin:start(1); rejoin:flush()
assert(disk["1/a:000001"] and disk["1/rejoin:000001"])
local missing=make(3,"missing"); missing:result(3,{id="x",answers={4,5,1,2}},100); missing:flush()
assert(disk["3/missing:000001"].levels["3"].timingQuality=="evaluation_only")
assert(disk["3/missing:000001"].levels["3"].completedSeconds==nil)
local c=make(4,"c"); c:start(2); c:append(2,"practice",{choices={2,3}},"one")
fail=true; assert(not c:flush() and c.status=="failed" and warnings>0)
fail=false; assert(c:flush() and #disk["4/c:000001"].events==1)
for i=2,151 do assert(c:append(2,"practice",{choices={2,3}},"item"..i)) end
assert(c:flush())
local count=0
for key,value in pairs(disk) do if key:sub(1,4)=="4/c:" then count+=#value.events; assert(#value.events<=64) end end
assert(count==151 and c.pages[1]==nil and c.pages[2]==nil)
c:close("server_shutdown"); c:flush(); assert(disk["4/c:000003"].sessionClosed)
assert(not c:append(2,"practice",{},"closed"))
local racing
racing=newRecorder({userId=5,sessionId="race",contentRevision="fixture",now=function() return tick end,utc=function() return utc end,
wait=function() end,warn=function() end,write=function(key,value)
 disk[key]=clone(value); if #value.events==1 then racing:append(1,"practice",{},"during") end
end})
racing:append(1,"practice",{},"first"); assert(not racing:flush() and racing.status=="pending")
assert(racing:flush() and #disk["race:000001"].events==2)
local full=make(6,"full")
for i=1,4096 do assert(full:append(1,"practice",{},"p"..i)) end
assert(not full:append(1,"practice",{},"overflow") and full.droppedEvents==1)
assert(full:flush() and full.status=="incomplete")
assert(disk["6/full:000064"].droppedEvents==1)
print("PASS records: attempts, first-pass timing, interrupted/rejoin/user isolation, missing start, paging, storage retry, yielding write")
`;
const out=path.join(root,'local-rbxl/bridge/test-learning-records.luau');fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,harness);
process.stdout.write(cp.execFileSync(path.join(root,'local-rbxl/luau-0.745/luau.exe'),[out],{encoding:'utf8'}));
const config=JSON.parse(read('studio-sync/project.json'));assert.equal(config.scripts.length,11);
const generated=read('studio-sync/src/LevelProgressHandler.server.luau');assert.ok(generated.includes(factory.trim()));
console.log('PASS records: generated recorder embedded in existing instance; 11 source targets.');
const catalog=JSON.parse(read('docs/development/recording-content-v1.json'));
const key=q=>q.key1.match(/Kunci tier 1: ([A-E])/)[1].charCodeAt(0)-64;
const rk=q=>q.key2.match(/Kunci tier 2: ([A-E])/)[1].charCodeAt(0)-64;
const answers=[catalog.levels[1].questions.map(q=>q.answer),catalog.levels[2].questions.map(key),catalog.levels[3].questions.map(q=>q.answer)];
const reasons=[catalog.levels[1].questions.map(q=>q.reason),catalog.levels[2].questions.map(rk)];
const luau=v=>'{'+v.map(x=>Array.isArray(x)?luau(x):x).join(',')+'}';
assert.ok(generated.includes('local answerKeys='+luau(answers)));
assert.ok(generated.includes('local reasonKeys='+luau(reasons)));
assert.ok(generated.includes('CONTENT_REVISION="'+catalog.contentRevision+'"'));
console.log('PASS catalogue: all server recording keys and content revision match source questions.');
