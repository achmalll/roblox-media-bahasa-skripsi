local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Shared environment initialization; does not change either level's score rules.
task.spawn(function()
	local folder = workspace:WaitForChild("Level2Development", 30)
	local tableModel = folder and folder:WaitForChild("L2_MejaPasangan", 15)
	if not tableModel then warn("[L2 Server] Missing L2_MejaPasangan"); return end
	local function anchor(part)
		if part:IsA("BasePart") then part.Anchored = true end
	end
	tableModel.DescendantAdded:Connect(anchor)
	local count = 0
	for _, part in ipairs(tableModel:GetDescendants()) do
		anchor(part)
		if part:IsA("BasePart") then count += 1 end
	end
	print("[L2 Server] Meja pasangan anchored on server:", count)
end)
-- Level 1 server initialization: stabilize the decorative kiosk before physics runs.
local kiosk = workspace:WaitForChild("Level1Development"):WaitForChild("L1_KiosEvaluasi")
local function stabilizePart(part)
	if part:IsA("BasePart") then part.Anchored = true end
end
for _, part in ipairs(kiosk:GetDescendants()) do stabilizePart(part) end
kiosk.DescendantAdded:Connect(stabilizePart)
print("[L1 Server] Kiosk anchored on server")
-- Validate choices on server; recordings observe this same payload.
local Players=game:GetService("Players")
local event=game:GetService("ReplicatedStorage"):WaitForChild("UpdateLevel1Score")
local keys={2,3,2,5}
local seen={}
local function integer(v,max) return typeof(v)=="number" and v==v and v%1==0 and v>=1 and v<=max end
event.OnServerEvent:Connect(function(player,payload)
 if typeof(payload)~="table" or typeof(payload.id)~="string" or #payload.id<1 or #payload.id>64 then return end
 local previous=seen[player]; if previous and previous.id==payload.id then return end
 if typeof(payload.answers)~="table" or #payload.answers~=4 then return end
 if typeof(payload.reasons)~="table" or #payload.reasons~=4 then return end
 local scores=player:FindFirstChild("PlayerScores")
 local stats=player:FindFirstChild("leaderstats")
 local progress=stats and stats:FindFirstChild("LevelProgress")
 local saved=scores and scores:FindFirstChild("Level1Score")
 if not progress or not saved then return end
 local score=0
 for i=1,4 do
  if not integer(payload.answers[i],5) then return end
  if not integer(payload.reasons[i],4) then return end
  if payload.answers[i]==keys[i] then score+=25 end
 end
 seen[player]={id=payload.id}
 saved.Value=math.max(saved.Value,score)
 if saved.Value>=75 then progress.Value=math.max(progress.Value,2) end
 print("[L1 Server] Result",player.UserId,"score",score,"best",saved.Value)
end)
Players.PlayerRemoving:Connect(function(player) seen[player]=nil end)
