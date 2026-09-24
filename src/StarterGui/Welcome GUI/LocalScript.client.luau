local gui = script.Parent
local welcomeFrame = gui:WaitForChild("welcomeFrame")
local overlay = gui:WaitForChild("BackgroundOverlay")
local PlayerControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerControlHandler"))

local GuiAnimation = require(
	game.Players.LocalPlayer.PlayerScripts:WaitForChild("GuiAnimationHandler")
)

local lanjutButton = welcomeFrame:WaitForChild("lanjutButton")
PlayerControl.Lock()

lanjutButton.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(welcomeFrame)
	PlayerControl.Unlock()
	overlay.Visible = false
end)

