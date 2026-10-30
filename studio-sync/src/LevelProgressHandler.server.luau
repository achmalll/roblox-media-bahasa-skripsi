
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local event = ReplicatedStorage:WaitForChild("UpdateLevelProgress")

event.OnServerEvent:Connect(function(player, newLevel)
	if typeof(newLevel) ~= "number" or newLevel ~= newLevel or newLevel % 1 ~= 0 or newLevel < 1 or newLevel > 4 then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local progress = leaderstats:FindFirstChild("LevelProgress")
	if not progress then return end

	-- L1 score submission unlocks L2 atomically; an early progress event cannot bypass it.
	if newLevel == 2 then
		local scores = player:FindFirstChild("PlayerScores")
		local score = scores and scores:FindFirstChild("Level1Score")
		if not score or score.Value < 75 then return end
	end
	if newLevel > progress.Value then
		progress.Value = newLevel
	end
	
end)
