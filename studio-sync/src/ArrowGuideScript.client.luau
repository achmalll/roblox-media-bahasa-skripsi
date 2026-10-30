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
local function panelOpen()
	for _, name in ipairs({"Level1Gui", "FlowGui", "Welcome GUI"}) do
		local gui = player.PlayerGui:FindFirstChild(name)
		if gui and gui.Enabled then
			for _, child in ipairs(gui:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible and child.Name ~= "BackgroundOverlay" then return true end
			end
		end
	end
	return false
end
local function setArrowVisible(visible)
	if not arrow then return end
	for _, part in ipairs(arrow:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = visible and 0 or 1
		end
	end
end

-- function spawn arrow
local function setupArrow(char)

	character = char

	if arrow then
		arrow:Destroy()
	end

	arrow = ArrowModel:Clone()
	arrow.Parent = workspace
	-- Preserve the existing asset, orientation and follow-player behavior.
	for _, part in ipairs(arrow:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
		end
	end

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

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Preserve the original follow position at the character root.
	local position = root.Position
	local targetPosition = currentTarget and currentTarget.Position
	local isLevel1 = progress.Value == 1
	if isLevel1 then
		targetPosition = player:GetAttribute("L1GuideTarget")
	end
	local hidden = panelOpen() or not targetPosition
	setArrowVisible(not hidden)
	if hidden then return end
	-- Turn only on the horizontal plane; keep the original model pivot at the player.
	local flatTarget = Vector3.new(targetPosition.X, position.Y, targetPosition.Z)
	if (flatTarget - position).Magnitude < .1 then setArrowVisible(false); return end

	arrow:SetPrimaryPartCFrame(
		CFrame.new(position, flatTarget)
	)
	
	local distance = (root.Position - targetPosition).Magnitude

	if distance < (isLevel1 and 3 or 30) then
		arrow.Arrow.Transparency = 1
	else
		arrow.Arrow.Transparency = 0
	end

end)

