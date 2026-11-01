-- Validate choices on server; recordings observe this same payload.
local Players=game:GetService("Players")
local event=game:GetService("ReplicatedStorage"):WaitForChild("UpdateLevel3Score")
local keys={4,5,1,2}
local seen={}
local function integer(v,max) return typeof(v)=="number" and v==v and v%1==0 and v>=1 and v<=max end
event.OnServerEvent:Connect(function(player,payload)
 if typeof(payload)~="table" or typeof(payload.id)~="string" or #payload.id<1 or #payload.id>64 then return end
 local previous=seen[player]; if previous and previous.id==payload.id then return end
 if typeof(payload.answers)~="table" or #payload.answers~=4 then return end
 local scores=player:FindFirstChild("PlayerScores")
 local stats=player:FindFirstChild("leaderstats")
 local progress=stats and stats:FindFirstChild("LevelProgress")
 local saved=scores and scores:FindFirstChild("Level3Score")
 if not progress or not saved then return end
 local previousScore=scores:FindFirstChild("Level2Score")
 if progress.Value<3 or not previousScore or previousScore.Value<75 then return end
 local score=0
 for i=1,4 do
  if not integer(payload.answers[i],5) then return end
  if payload.answers[i]==keys[i] then score+=25 end
 end
 seen[player]={id=payload.id}
 saved.Value=math.max(saved.Value,score)
 if saved.Value>=75 then progress.Value=math.max(progress.Value,4) end
 print("[L3 Server] Result",player.UserId,"score",score,"best",saved.Value)
end)
Players.PlayerRemoving:Connect(function(player) seen[player]=nil end)
