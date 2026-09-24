local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local event = ReplicatedStorage:WaitForChild("GiveMedalEvent")
local medals = ServerStorage:WaitForChild("AchievementTools")

event.OnServerEvent:Connect(function(player, medalName)

	local medal = medals:FindFirstChild(medalName)

	if medal then

		-- cegah duplikat
		if player.Backpack:FindFirstChild(medalName) then
			return
		end

		local clone = medal:Clone()
		clone.Parent = player.Backpack

	end

end)