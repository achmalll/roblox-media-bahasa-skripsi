local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the GUI to be ready
local screenGui = script.Parent
local mainContainer = screenGui:FindFirstChild("MainContainer")
if not mainContainer then return end

local badgeSection = mainContainer:FindFirstChild("BadgeSection")
local scoreSection = mainContainer:FindFirstChild("ScoreSection")

-- Get UI elements
local badgeCircle = badgeSection and badgeSection:FindFirstChild("BadgeCircle")
local levelLabel = badgeCircle and badgeCircle:FindFirstChild("LevelLabel")
local starLabel = badgeCircle and badgeCircle:FindFirstChild("StarLabel")
local dariLabel = badgeSection and badgeSection:FindFirstChild("DariLabel")

local scoreValue = scoreSection and scoreSection:FindFirstChild("ScoreValue")

-- Helper to safely get leaderstats values
local function getLeaderstat(name)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return nil end
	return leaderstats:FindFirstChild(name)
end

-- Helper to get PlayerScores values
local function getPlayerScore(name)
	local playerScores = player:FindFirstChild("PlayerScores")
	if not playerScores then return nil end
	return playerScores:FindFirstChild(name)
end

-- Update the level display based on LevelProgress value
local function updateLevelDisplay(levelProgressValue)
	if not levelLabel then return end

	-- LevelProgress: 1=start/on level1, 2=level1 passed (on level2),
	-- 3=level2 passed (on level3), 4=level3 passed (all complete)
	-- Badge shows the current level the player is on (1, 2, or 3 out of "dari 3")
	local displayLevel = math.clamp(levelProgressValue, 1, 3)
	levelLabel.Text = tostring(displayLevel)
end

-- Update the score display
local function updateScoreDisplay(totalScoreValue)
	if not scoreValue then return end
	scoreValue.Text = tostring(totalScoreValue)
end

-- Main setup function - connects to data changes
local function setupDataConnections()
	-- Wait for leaderstats to exist
	local leaderstats = player:WaitForChild("leaderstats", 30)
	if not leaderstats then return end

	-- Connect to LevelProgress changes
	local levelProgress = leaderstats:FindFirstChild("LevelProgress")
	if levelProgress and levelProgress:IsA("IntValue") then
		updateLevelDisplay(levelProgress.Value)
		levelProgress.Changed:Connect(function(newValue)
			updateLevelDisplay(newValue)
		end)
	end

	-- Connect to TotalScore changes
	local totalScore = leaderstats:FindFirstChild("TotalScore")
	if totalScore and totalScore:IsA("IntValue") then
		updateScoreDisplay(totalScore.Value)
		totalScore.Changed:Connect(function(newValue)
			updateScoreDisplay(newValue)
		end)
	end
end

-- Start the data connections
setupDataConnections()