local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local humanoid

local normalSpeed = 16 -- default Roblox speed
local sprintSpeed = 28 -- kecepatan saat sprint


-- fungsi saat character spawn / respawn
local function setupCharacter(character)

	humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = normalSpeed

end


-- jika character sudah ada
if player.Character then
	setupCharacter(player.Character)
end

-- saat respawn
player.CharacterAdded:Connect(setupCharacter)



-- input mulai tekan tombol
UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then return end
	if not humanoid then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		humanoid.WalkSpeed = sprintSpeed
	end

end)


-- input saat tombol dilepas
UserInputService.InputEnded:Connect(function(input)

	if not humanoid then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		humanoid.WalkSpeed = normalSpeed
	end

end)