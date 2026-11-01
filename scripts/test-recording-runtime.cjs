const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8');
const factory=read('studio-sync/recording/LearningRecordStore.luau'),runtime=read('studio-sync/recording/LearningRecordRuntime.luau');
const prelude=`
local CONTENT_REVISION="fixture"
local newRecorder=(function()\n${factory}\nend)()
local tick,uuid,fail,storeCalls,saveCalls,autoTicks=0,0,false,0,0,0
local disk,background,created,shutdown={},{}
local runNoArgs=false
local function signal()
 local s={callbacks={}}
 function s:Connect(fn) table.insert(self.callbacks,fn) end
 function s:Fire(...) for _,fn in ipairs(self.callbacks) do fn(...) end end
 return s
end
local function folder(v) v.FindFirstChild=function(self,n) return self[n] end; return v end
local function player(id,level)
 local p=folder({UserId=id,attrs={},leaderstats=folder({LevelProgress={Value=level}}),PlayerScores=folder({Level1Score={Value=100},Level2Score={Value=100}})})
 function p:SetAttribute(k,v) self.attrs[k]=v end; return p
end
local a,b,c=player(1,3),player(2,1),player(3,3)
local ps={PlayerAdded=signal(),PlayerRemoving=signal(),GetPlayers=function() return {a,b,c} end}
local rep={}
for i=1,3 do rep["UpdateLevel"..i.."Score"]={OnServerEvent=signal()} end
function rep:WaitForChild(name) return assert(self[name]) end
Instance={new=function(class) assert(class=="RemoteEvent"); created={OnServerEvent=signal()}; return created end}
local http={GenerateGUID=function() uuid+=1; return "session"..uuid end}
local ds={GetDataStore=function(_,name,scope)
 storeCalls+=1
 if INIT_FAIL then INIT_FAIL=false; error("Store initialization unavailable") end
 return {UpdateAsync=function(_,key,fn)
  saveCalls+=1; if fail then error("network failure") end
  local full=name.."/"..scope.."/"..key; local value=fn(disk[full]); if value then disk[full]=value end
 end}
end}
DateTime={now=function() return {UnixTimestampMillis=100000+tick*1000} end}
os={clock=function() return tick end}
workspace={GetAttribute=function() return OPT_IN end}
warn=function() end
task={wait=function(seconds)
 tick+=seconds
 if seconds==30 then if autoTicks>0 then autoTicks-=1; return seconds end; return nil end
 return seconds
end,spawn=function(fn,...)
 if select("#",...)>0 or runNoArgs then fn(...) else table.insert(background,fn) end
end}
game={PlaceId=1,JobId="fixture",BindToClose=function(_,fn) shutdown=fn end,GetService=function(_,name)
 if name=="Players" then return ps elseif name=="ReplicatedStorage" then return rep elseif name=="HttpService" then return http
 elseif name=="RunService" then return {IsStudio=function() return STUDIO end}
 elseif name=="DataStoreService" then return ds end; error(name)
end}
`;
const liveTests=`
created.OnServerEvent:Fire(a,{level=1,id="start1",op="start"})
tick=120
created.OnServerEvent:Fire(a,{level=1,id="p1",op="practice",activity="slots",choices={"B","A"}})
created.OnServerEvent:Fire(a,{level=1,id="i1",op="evaluation_item",attemptId="attempt",question=1,answer=1,reason=1})
created.OnServerEvent:Fire(a,{level=3,id="nan",op="evaluation_item",attemptId="bad",question=0/0,answer=4})
created.OnServerEvent:Fire(b,{level=3,id="denied",op="start"})
rep.UpdateLevel1Score.OnServerEvent:Fire(a,{id="pass1",answers={2,3,2,5,extra={private="must not persist"}},reasons={2,1,3,4}})
local page=disk["LearningRecords_v1/u1/session1:000001"]
assert(page and #page.events==3 and page.levels["1"].completedSeconds==120)
assert(page.events[1].data.correct==false and page.events[2].data.reasonCorrect==false)
assert(page.events[3].data.answers.extra==nil and page.events[3].data.score==100)
rep.UpdateLevel1Score.OnServerEvent:Fire(a,{id="pass1",answers={2,3,2,5},reasons={2,1,3,4}})
assert(#disk["LearningRecords_v1/u1/session1:000001"].events==3)
created.OnServerEvent:Fire(a,{level=2,id="start2",op="start"})
tick=200
created.OnServerEvent:Fire(a,{level=2,id="evidence",op="practice",activity="evidence",choices={3,2}})
created.OnServerEvent:Fire(a,{level=2,id="pairs",op="practice",activity="pairs",choices={2,1},help=true})
rep.UpdateLevel2Score.OnServerEvent:Fire(a,{id="fail2",answers={5,5,5,5},reasons={1,1,1,1}})
page=disk["LearningRecords_v1/u1/session1:000001"]
assert(page.events[4].data.correct and not page.events[5].data.correct and page.events[5].data.help)
assert(not page.levels["2"].completed)
created.OnServerEvent:Fire(c,{level=3,id="start3",op="start"})
tick=260
rep.UpdateLevel3Score.OnServerEvent:Fire(c,{id="pass3",answers={4,5,1,2}})
assert(disk["LearningRecords_v1/u3/session3:000001"].levels["3"].completedSeconds==60)
-- Final write fails after departure: retain it until periodic retry succeeds.
fail=true; ps.PlayerRemoving:Fire(a); assert(a.attrs.LearningRecordStatus=="failed")
fail=false; autoTicks=1; background[1]()
page=disk["LearningRecords_v1/u1/session1:000001"]
assert(page.sessionClosed and page.closeReason=="player_left" and a.attrs.LearningRecordStatus=="saved")
assert(disk["LearningRecords_v1/u2/session2:000001"].levels["3"]==nil)
-- A second connection never overwrites the first session.
local again=player(1,1); ps.PlayerAdded:Fire(again)
created.OnServerEvent:Fire(again,{level=1,id="again",op="start"})
runNoArgs=true; shutdown()
assert(disk["LearningRecords_v1/u1/session4:000001"].sessionClosed)
assert(disk["LearningRecords_v1/u1/session1:000001"].closeReason=="player_left")
print("PASS runtime live mock: all 3 levels, server timers, raw practice, wrong reasons, sanitization, prerequisites, dedup, departure retry, rejoin, shutdown")
`;
for(const [mode,studio,optIn,initFail] of [['live',false,false,false],['init-retry',false,false,true],['studio-off',true,false,false],['studio-on',true,true,false]]) {
 const test=studio&&!optIn?`
assert(storeCalls==0 and a.attrs.LearningRecordStatus=="disabled_studio")
created.OnServerEvent:Fire(a,{level=1,id="s",op="start"})
rep.UpdateLevel1Score.OnServerEvent:Fire(a,{id="x",answers={2,3,2,5},reasons={2,1,3,4}})
assert(saveCalls==0 and a.attrs.LearningRecordStatus=="disabled_studio")
print("PASS runtime Studio: persistence disabled, no live DataStore requests")
`:(studio?liveTests.replaceAll('LearningRecords_v1','LearningRecords_TEST_v1'):liveTests);
 const file=path.join(root,'local-rbxl/bridge/test-recording-runtime-'+mode+'.luau');fs.mkdirSync(path.dirname(file),{recursive:true});
 fs.writeFileSync(file,'local STUDIO='+studio+'\nlocal OPT_IN='+optIn+'\nlocal INIT_FAIL='+initFail+'\n'+prelude+runtime+'\n'+test);
 process.stdout.write(cp.execFileSync(path.join(root,'local-rbxl/luau-0.745/luau.exe'),[file],{encoding:'utf8'}));
}
