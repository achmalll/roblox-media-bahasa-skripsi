local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("UpdateLevel1Score")

event.OnServerEvent:Connect(function(player, score)

	if player:FindFirstChild("PlayerScores") then
		player.PlayerScores.Level1Score.Value = score
	end

end)