local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PlayerControl = {}

local originalWalkSpeed = nil
local originalJumpPower = nil
local isLocked = false

function PlayerControl.Lock()

	if isLocked then return end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	originalWalkSpeed = humanoid.WalkSpeed
	originalJumpPower = humanoid.JumpPower

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	isLocked = true
end

function PlayerControl.Unlock()

	if not isLocked then return end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	if originalWalkSpeed then
		humanoid.WalkSpeed = originalWalkSpeed
	end

	if originalJumpPower then
		humanoid.JumpPower = originalJumpPower
	end

	isLocked = false
end

return PlayerControl