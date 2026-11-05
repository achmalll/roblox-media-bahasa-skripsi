-- Studio persistence is opt-in, always in a separate test store.
local Players=game:GetService("Players")
local Replicated=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local DataStore=game:GetService("DataStoreService")
local studio=Run:IsStudio()
local enabled=not studio or workspace:GetAttribute("EnableLearningRecordStudioTest")==true
local storeName=studio and "LearningRecords_TEST_v1" or "LearningRecords_v1"
local records,buckets={},{}
local remote=Instance.new("RemoteEvent"); remote.Name="LearningRecordEvent"; remote.Parent=Replicated
local function integer(v,max) return typeof(v)=="number" and v==v and v%1==0 and v>=1 and v<=max end
local function identity(v) return typeof(v)=="string" and #v>=1 and #v<=64 and v:match("^[%w:_%-]+$")~=nil end
local function eligible(player,level)
 local stats=player:FindFirstChild("leaderstats")
 local progress=stats and stats:FindFirstChild("LevelProgress")
 if not progress or progress.Value<level then return false end
 if level==1 then return true end
 local scores=player:FindFirstChild("PlayerScores")
 local score=scores and scores:FindFirstChild("Level"..(level-1).."Score")
 return score~=nil and score.Value>=75
end
local function status(player,r)
 player:SetAttribute("LearningRecordStatus",enabled and r.status or "disabled_studio")
 player:SetAttribute("LearningRecordStore",storeName)
end
local function add(player)
 if records[player] then return records[player] end
 local sessionId=Http:GenerateGUID(false):gsub("%-","")
 local store
 if enabled then
  local ok,result=pcall(DataStore.GetDataStore,DataStore,storeName,"u"..player.UserId)
  if ok then store=result else warn("[LearningRecords] Store unavailable",player.UserId,result) end
 end
 local r=newRecorder({userId=player.UserId,sessionId=sessionId,placeId=game.PlaceId,jobId=game.JobId,
  startedAtMs=DateTime.now().UnixTimestampMillis,contentRevision=CONTENT_REVISION,
  now=os.clock,utc=function() return DateTime.now().UnixTimestampMillis end,wait=task.wait,
  warn=function(message) warn("[LearningRecords]",player.UserId,message); player:SetAttribute("LearningRecordStatus","failed") end,
  write=function(key,data)
   if not enabled then error("Studio persistence disabled") end
   if not store then store=DataStore:GetDataStore(storeName,"u"..player.UserId) end
   store:UpdateAsync(key,function(old)
    if old and old.sessionId==data.sessionId and (old.revision or 0)>data.revision then return nil end
    return data
   end)
  end})
 records[player]=r; status(player,r); return r
end
local function save(player,r)
 if enabled then r:flush() end
 status(player,r)
 -- Retain disconnected players with failed writes for autosave/shutdown retry.
 if r.closed and (not enabled or r.persistedClean) then records[player]=nil; buckets[player]=nil end
end
local function allow(player)
 local now=os.clock(); local b=buckets[player] or {at=now,tokens=20}; buckets[player]=b
 b.tokens=math.min(20,b.tokens+math.max(0,now-b.at)*5); b.at=now
 if b.tokens<1 then return false end; b.tokens-=1; return true
end
local answerKeys={{2,3,2,5},{1,2,2,3},{4, 5, 1, 3}}
local reasonKeys={{2,1,3,4},{3,1,2,4},{3, 1, 2, 4}}
remote.OnServerEvent:Connect(function(player,p)
 if not allow(player) or typeof(p)~="table" or not integer(p.level,3) or not identity(p.id) or not eligible(player,p.level) then return end
 local r=add(player)
 if p.op=="start" then r:start(p.level); status(player,r); return
 elseif p.op=="evaluation_item" then
  if not identity(p.attemptId) or not integer(p.question,4) or not integer(p.answer,5) then return end
  if p.level<=3 and not integer(p.reason,4) then return end
  local data={attemptId=p.attemptId,question=p.question,answer=p.answer,
   answerCorrect=p.answer==answerKeys[p.level][p.question],validation="client_report_server_checked"}
  if p.level<=3 then data.reason=p.reason; data.reasonCorrect=p.reason==reasonKeys[p.level][p.question] end
  r:append(p.level,"evaluation_item",data,"item:"..p.level..":"..p.id)
 elseif p.op=="practice" then
  local providedSource=p.level==3 and p.activity=="editor" and p.variant=="provided_source_v2"
  if typeof(p.choices)~="table" or #p.choices<(providedSource and 1 or 2) or #p.choices>3 then return end
  if providedSource and #p.choices~=1 then return end
  local a,b=p.choices[1],p.choices[2]; local correct
  if p.level==1 and p.activity=="slots" then
   if not (typeof(a)=="string" and typeof(b)=="string" and a:match("^[A-D]$") and b:match("^[A-D]$")) then return end
   correct=a=="A" and b=="B"
  elseif p.level==2 and p.activity=="evidence" then
   if not integer(a,4) or not integer(b,4) or a==b then return end
   correct=(a==2 and b==3) or (a==3 and b==2)
  elseif p.level==2 and p.activity=="pairs" then
   if not integer(a,2) or not integer(b,2) or a==b then return end
   correct=a==1 and b==2
  elseif p.level==3 and p.activity=="functions" then
   local c=p.choices[3]
   if not integer(a,3) or not integer(b,3) or not integer(c,3) or a==b or a==c or b==c then return end
   correct=a==1 and b==2 and c==3
  elseif p.level==3 and p.activity=="editor" then
   if not integer(p.round,4) or not integer(a,3) or (not providedSource and not integer(b,2)) then return end
   correct=a==({3,1,2,3})[p.round] and (providedSource or b==({2,1,2,2})[p.round])
  else return end
  r:append(p.level,"practice",{activity=p.activity,variant=providedSource and "provided_source_v2" or nil,evidenceProvided=providedSource or nil,round=p.level==3 and p.round or nil,choices=providedSource and {a} or (p.activity=="functions" and {a,b,p.choices[3]} or {a,b}),correct=correct,help=p.help==true,
   validation="client_report_server_checked"},"practice:"..p.level..":"..p.id)
 else return end
 status(player,r)
end)
for level=1,3 do
 local event=Replicated:WaitForChild("UpdateLevel"..level.."Score")
 event.OnServerEvent:Connect(function(player,p)
  if not allow(player) or typeof(p)~="table" or not identity(p.id) or not eligible(player,level) then return end
  if typeof(p.answers)~="table" or #p.answers~=4 then return end
  if level<=3 and (typeof(p.reasons)~="table" or #p.reasons~=4) then return end
  local score,reasons=0,0
  -- Copy only whitelisted scalar entries, never arbitrary client fields or nested data.
  local clean={id=p.id,answers={}}
  if level<=3 then clean.reasons={} end
  for i=1,4 do
   if not integer(p.answers[i],5) or (level<=3 and not integer(p.reasons[i],4)) then return end
   clean.answers[i]=p.answers[i]
   if level<=3 then clean.reasons[i]=p.reasons[i] end
   if p.answers[i]==answerKeys[level][i] then score+=25 end
   if level<=3 and p.reasons[i]==reasonKeys[level][i] then reasons+=1 end
  end
  local r=add(player)
  if r:result(level,clean,score,level<=3 and reasons or nil) then task.spawn(save,player,r) end
 end)
end
Players.PlayerAdded:Connect(add)
for _,player in ipairs(Players:GetPlayers()) do add(player) end
Players.PlayerRemoving:Connect(function(player)
 local r=records[player]; if not r then return end
 r:close("player_left")
 local deadline=os.clock()+20
 while r.saving and os.clock()<deadline do task.wait(.1) end
 save(player,r)
end)
task.spawn(function()
 while task.wait(30) do
  for player,r in pairs(records) do r:checkpoint(); task.spawn(save,player,r) end
 end
end)
game:BindToClose(function()
 local remaining=0
 for player,r in pairs(records) do
  r:close("server_shutdown"); remaining+=1
  task.spawn(function()
   local deadline=os.clock()+20
   while r.saving and os.clock()<deadline do task.wait(.1) end
   save(player,r); remaining-=1
  end)
 end
 local deadline=os.clock()+25
 while remaining>0 and os.clock()<deadline do task.wait(.1) end
end)
print("[LearningRecords]",storeName,enabled and "enabled" or "Studio disabled; opt-in test store only")
