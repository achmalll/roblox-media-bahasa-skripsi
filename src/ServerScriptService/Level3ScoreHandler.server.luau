local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("UpdateLevel3Score")

event.OnServerEvent:Connect(function(player, score)

	if player:FindFirstChild("PlayerScores") then
		player.PlayerScores.Level3Score.Value = score
	end

end)