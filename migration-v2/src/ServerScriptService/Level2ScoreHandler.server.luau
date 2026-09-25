local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("UpdateLevel2Score")

event.OnServerEvent:Connect(function(player, score)

	if player:FindFirstChild("PlayerScores") then
		player.PlayerScores.Level2Score.Value = score
	end

end)