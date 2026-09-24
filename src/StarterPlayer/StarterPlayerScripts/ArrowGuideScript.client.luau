local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArrowModel = ReplicatedStorage:WaitForChild("ArrowModel")

local hideArrowEvent = ReplicatedStorage:WaitForChild("HideArrowEvent")

local targets = {
	[1] = workspace:WaitForChild("Space1Answers"),
	[2] = workspace:WaitForChild("Space2Answers"),
	[3] = workspace:WaitForChild("Space3Answers"),
	[4] = workspace:WaitForChild("SummaryProximity")
}

local character
local arrow
local currentTarget

-- function spawn arrow
local function setupArrow(char)

	character = char

	if arrow then
		arrow:Destroy()
	end

	arrow = ArrowModel:Clone()
	arrow.Parent = workspace

end


hideArrowEvent.Event:Connect(function()

	if arrow then
		arrow:Destroy()
	end

end)


-- ketika character spawn
player.CharacterAdded:Connect(setupArrow)

if player.Character then
	setupArrow(player.Character)
end

-- tunggu leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local progress = leaderstats:WaitForChild("LevelProgress")

-- update target berdasarkan progress
local function updateTarget()

	currentTarget = targets[progress.Value]

end

updateTarget()

progress.Changed:Connect(function()

	updateTarget()

end)

-- arahkan arrow
RunService.RenderStepped:Connect(function()

	if not arrow then return end
	if not character then return end
	if not currentTarget then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local position = root.Position

	arrow:SetPrimaryPartCFrame(
		CFrame.new(position, currentTarget.Position)
	)
	
	local distance = (root.Position - currentTarget.Position).Magnitude

	if distance < 30 then
		arrow.Arrow.Transparency = 1
	else
		arrow.Arrow.Transparency = 0
	end

end)

