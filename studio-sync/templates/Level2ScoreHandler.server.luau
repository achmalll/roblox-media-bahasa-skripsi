-- Existing UpdateLevel2Score remote; validate choices and calculate both scores on server.
local Players=game:GetService("Players")
local event=game:GetService("ReplicatedStorage"):WaitForChild("UpdateLevel2Score")
-- GENERATED_KEYS
local cache={}
local function integer(value,maximum)
 return typeof(value)=="number" and value==value and value%1==0 and value>=1 and value<=maximum
end
event.OnServerEvent:Connect(function(player,payload)
 if typeof(payload)~="table" or typeof(payload.id)~="string" or #payload.id>64 or #payload.id<1 then return end
 local previous=cache[player]
 if previous and previous.id==payload.id then event:FireClient(player,previous); return end
 local stats=player:FindFirstChild("leaderstats")
 local scores=player:FindFirstChild("PlayerScores")
 local progress=stats and stats:FindFirstChild("LevelProgress")
 local level1=scores and scores:FindFirstChild("Level1Score")
 local saved=scores and scores:FindFirstChild("Level2Score")
 if not progress or not saved or not level1 then return end
 if progress.Value<2 or level1.Value<75 then
  event:FireClient(player,{id=payload.id,error="Selesaikan Level 1 dengan nilai minimal 75 terlebih dahulu."}); return
 end
 if typeof(payload.answers)~="table" or typeof(payload.reasons)~="table" then return end
 if #payload.answers~=4 or #payload.reasons~=4 then return end
 local score,reasons=0,0
 for i=1,4 do
  if not integer(payload.answers[i],5) or not integer(payload.reasons[i],4) then return end
  if payload.answers[i]==answerKeys[i] then score+=25 end
  if payload.reasons[i]==reasonKeys[i] then reasons+=1 end
 end
 saved.Value=math.max(saved.Value,score)
 if saved.Value>=75 then progress.Value=math.max(progress.Value,3) end
 local response={id=payload.id,score=score,reasons=reasons,best=saved.Value,unlocked=progress.Value>=3}
 cache[player]=response
 event:FireClient(player,response)
 print("[L2 Server] Result",player.UserId,"score",score,"reasons",reasons,"progress",progress.Value)
end)
Players.PlayerRemoving:Connect(function(player) cache[player]=nil end)
