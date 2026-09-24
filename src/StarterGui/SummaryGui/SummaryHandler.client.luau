local player = game.Players.LocalPlayer
local gui = script.Parent
local frame = gui:WaitForChild("SummaryFrame")

local levelSummary = frame:WaitForChild("LevelSummary")
local totalScoreText = frame:WaitForChild("TotalScore")
local nextButton = frame:WaitForChild("NextButton")

local achievementsFrame = gui:WaitForChild("AchievementsFrame")

local bronzeFrame = achievementsFrame:WaitForChild("BronzeAchievement")
local silverFrame = achievementsFrame:WaitForChild("SilverAchievement")
local goldFrame = achievementsFrame:WaitForChild("GoldAchievement")
local platinumFrame = achievementsFrame:WaitForChild("PlatinumAchievement")

local inventoryGuideFrame = gui:WaitForChild("InventoryGuideFrame")
local closeGuideButton = inventoryGuideFrame:WaitForChild("CloseButton")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local giveMedalEvent = ReplicatedStorage:WaitForChild("GiveMedalEvent")


local PlayerControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerControlHandler"))

local GuiAnimation = require(
	game.Players.LocalPlayer.PlayerScripts:WaitForChild("GuiAnimationHandler")
)

local proximity = workspace:WaitForChild("SummaryProximity"):WaitForChild("ProximityPrompt")
local proximityPart = workspace:WaitForChild("SummaryProximity")
local proximity = proximityPart:WaitForChild("ProximityPrompt")

local function hideSummaryPrompt()

	proximityPart.Transparency = 1
	proximityPart.CanCollide = false

	if proximity then
		proximity.Enabled = false
	end

end

gui.Enabled = false
inventoryGuideFrame.Visible = false

local function openSummary()

	-- ambil data score
	local scores = player:WaitForChild("PlayerScores")
	local leaderstats = player:WaitForChild("leaderstats")

	local level1 = scores:WaitForChild("Level1Score").Value
	local level2 = scores:WaitForChild("Level2Score").Value
	local level3 = scores:WaitForChild("Level3Score").Value

	local total = leaderstats:WaitForChild("TotalScore").Value

	-- tampilkan teks summary
	levelSummary.Text =
		"Level 1 : "..level1..
		"\nLevel 2 : "..level2..
		"\nLevel 3 : "..level3

	totalScoreText.Text = "Total Score : "..total

	-- buka GUI
	gui.Enabled = true
	GuiAnimation.Show(frame)

	-- kunci player
	PlayerControl.Lock()

end

local function showAchievement()

	local total = player.leaderstats.TotalScore.Value

	-- sembunyikan semua dulu
	bronzeFrame.Visible = false
	silverFrame.Visible = false
	goldFrame.Visible = false
	platinumFrame.Visible = false

	if total == 300 then
		GuiAnimation.Show(platinumFrame)
		platinumFrame.Visible = true

	elseif total == 275 then
		GuiAnimation.Show(goldFrame)
		goldFrame.Visible = true

	elseif total == 250 then
		GuiAnimation.Show(silverFrame)
		silverFrame.Visible = true

	elseif total == 225 then
		GuiAnimation.Show(bronzeFrame)
		bronzeFrame.Visible = true

	end
end

local function showInventoryGuide()

	inventoryGuideFrame.Visible = true
	GuiAnimation.Show(inventoryGuideFrame)

end


-- ketika proximity ditekan
proximity.Triggered:Connect(function(plr)

	if plr == player then
		openSummary()
	end

end)


-- tombol lanjutkan
nextButton.MouseButton1Click:Connect(function()

	-- sembunyikan summary
	GuiAnimation.Hide(frame)
	task.wait(0.3)
	frame.Visible = false

	-- tampilkan achievement
	showAchievement()

end)

bronzeFrame.NextButton.MouseButton1Click:Connect(function()

	giveMedalEvent:FireServer("BronzeMedal")
	hideSummaryPrompt()
	ReplicatedStorage.HideArrowEvent:Fire()
	bronzeFrame.Visible = false
	showInventoryGuide()

end)

silverFrame.NextButton.MouseButton1Click:Connect(function()

	giveMedalEvent:FireServer("SilverMedal")
	hideSummaryPrompt()
	ReplicatedStorage.HideArrowEvent:Fire()
	silverFrame.Visible = false
	showInventoryGuide()

end)

goldFrame.NextButton.MouseButton1Click:Connect(function()

	giveMedalEvent:FireServer("GoldMedal")
	hideSummaryPrompt()
	ReplicatedStorage.HideArrowEvent:Fire()
	goldFrame.Visible = false
	showInventoryGuide()

end)

platinumFrame.NextButton.MouseButton1Click:Connect(function()

	giveMedalEvent:FireServer("PlatinumMedal")
	hideSummaryPrompt()
	ReplicatedStorage.HideArrowEvent:Fire()
	platinumFrame.Visible = false
	showInventoryGuide()

end)

closeGuideButton.MouseButton1Click:Connect(function()

	GuiAnimation.Hide(inventoryGuideFrame)

	task.wait(0.3)

	inventoryGuideFrame.Visible = false
	gui.Enabled = false

	PlayerControl.Unlock()
end)