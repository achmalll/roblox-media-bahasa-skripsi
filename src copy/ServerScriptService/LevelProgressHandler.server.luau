
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local event = ReplicatedStorage:WaitForChild("UpdateLevelProgress")

event.OnServerEvent:Connect(function(player, newLevel)

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local progress = leaderstats:FindFirstChild("LevelProgress")
	if not progress then return end

	progress.Value = newLevel
	if newLevel > progress.Value then
		progress.Value = newLevel
	end
	
end)