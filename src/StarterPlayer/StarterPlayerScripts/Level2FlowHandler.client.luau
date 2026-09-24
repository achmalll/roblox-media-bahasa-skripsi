local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local level2Gui = playerGui:WaitForChild("Level2Gui")
local introFrame = level2Gui:WaitForChild("space2IntroFrame")
local NewsFrame = level2Gui:WaitForChild("NewsScrollingFrame")
local ConfirmModal = level2Gui:WaitForChild("ConfirmModal")
local Overlay = level2Gui:WaitForChild("BackgroundOverlay")
local quizFrame = level2Gui:WaitForChild("quizFrame")

local GuiAnimation = require(
	game.Players.LocalPlayer.PlayerScripts:WaitForChild("GuiAnimationHandler")
)

-- Part & Prompt
local part = workspace:WaitForChild("Space2Answers")
local prompt = part:WaitForChild("ProximityPrompt")

-- Optional: kalau kamu pakai module PlayerControl
local PlayerControl = require(player.PlayerScripts:WaitForChild("PlayerControlHandler"))



-- Ketika player tekan E
prompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then

		level2Gui.Enabled = true
		GuiAnimation.Show(introFrame)
		-- Lock movement
		PlayerControl.Lock()
	end
end)

introFrame.mulaibtn.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(introFrame)
	GuiAnimation.Show(NewsFrame)
	PlayerControl.Lock()
end)

introFrame.close.MouseButton1Click:Connect(function()
	level2Gui.Enabled = false
	PlayerControl.Unlock()
end)

NewsFrame.StartQuizButton.MouseButton1Click:Connect(function()
	NewsFrame.Visible = false
	GuiAnimation.Show(ConfirmModal)
	Overlay.ZIndex = 2
	PlayerControl.Lock()
end)

ConfirmModal.NoButton.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(ConfirmModal)
	Overlay.ZIndex = 1
	GuiAnimation.Show(NewsFrame)
	PlayerControl.Lock()
end)

ConfirmModal.YesButton.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(ConfirmModal)
	GuiAnimation.Show(quizFrame)
	Overlay.ZIndex = 1
	PlayerControl.Lock()
end)