local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local level3Gui = playerGui:WaitForChild("Level3Gui")
local introFrame = level3Gui:WaitForChild("space3IntroFrame")
local AbstractFrame = level3Gui:WaitForChild("AbstractFrame")
local ConfirmModal = level3Gui:WaitForChild("ConfirmModal")
local Overlay = level3Gui:WaitForChild("BackgroundOverlay")
local quizFrame = level3Gui:WaitForChild("quizFrame")

local GuiAnimation = require(
	game.Players.LocalPlayer.PlayerScripts:WaitForChild("GuiAnimationHandler")
)

-- Part & Prompt
local part = workspace:WaitForChild("Space3Answers")
local prompt = part:WaitForChild("ProximityPrompt")

-- Optional: kalau kamu pakai module PlayerControl
local PlayerControl = require(player.PlayerScripts:WaitForChild("PlayerControlHandler"))



-- Ketika player tekan E
prompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then

		level3Gui.Enabled = true
		GuiAnimation.Show(introFrame)
		-- Lock movement
		PlayerControl.Lock()
	end
end)

introFrame.mulaibtn.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(introFrame)
	GuiAnimation.Show(AbstractFrame)
	PlayerControl.Lock()
end)

introFrame.close.MouseButton1Click:Connect(function()
	level3Gui.Enabled = false
	PlayerControl.Unlock()
end)

AbstractFrame.StartQuizButton.MouseButton1Click:Connect(function()
	AbstractFrame.Visible = false
	GuiAnimation.Show(ConfirmModal)
	Overlay.ZIndex = 2
	PlayerControl.Lock()
end)

ConfirmModal.NoButton.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(ConfirmModal)
	Overlay.ZIndex = 1
	GuiAnimation.Show(AbstractFrame)
	PlayerControl.Lock()
end)

ConfirmModal.YesButton.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(ConfirmModal)
	GuiAnimation.Show(quizFrame)
	Overlay.ZIndex = 1
	PlayerControl.Lock()
end)