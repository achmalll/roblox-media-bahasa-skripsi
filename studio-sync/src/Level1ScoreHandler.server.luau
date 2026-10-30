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
local event = ReplicatedStorage:WaitForChild("UpdateLevel1Score")

event.OnServerEvent:Connect(function(player, score)

	if typeof(score) ~= "number" or score ~= score or score < 0 or score > 100 or score % 25 ~= 0 then return end
	local scores = player:FindFirstChild("PlayerScores")
	local savedScore = scores and scores:FindFirstChild("Level1Score")
	local stats = player:FindFirstChild("leaderstats")
	local progress = stats and stats:FindFirstChild("LevelProgress")
	if not savedScore or not progress then return end
	-- Best score makes retries idempotent and preserves earned access.
	savedScore.Value = math.max(savedScore.Value, score)
	if savedScore.Value >= 75 then progress.Value = math.max(progress.Value, 2) end
	print("[L1 Server] Result", player.UserId, "score", savedScore.Value, "progress", progress.Value)

end)
