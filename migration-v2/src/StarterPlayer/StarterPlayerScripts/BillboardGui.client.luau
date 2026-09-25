local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local character = player.Character or player.CharacterAdded:Wait()

-- leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local progress = leaderstats:WaitForChild("LevelProgress")

-- daftar door + minimal progress
local doors = {

	{
		part = workspace:WaitForChild("Space2DoorBlock"),
		requiredProgress = 1
	},

	{
		part = workspace:WaitForChild("Space3DoorBlock"),
		requiredProgress = 2
	},

	{
		part = workspace:WaitForChild("ApresiasiDoorBlock"),
		requiredProgress = 3
	}

}

local maxDistance = 15

RunService.RenderStepped:Connect(function()

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, data in ipairs(doors) do

		local door = data.part
		local requiredProgress = data.requiredProgress

		local gui = door:FindFirstChild("BillboardGui")
		if not gui then continue end

		-- jika level sudah terbuka
		if progress.Value > requiredProgress then

			gui.Enabled = false

		else

			local distance = (root.Position - door.Position).Magnitude

			if distance <= maxDistance then
				gui.Enabled = true
			else
				gui.Enabled = false
			end

		end

	end

end)