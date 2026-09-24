local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GuiAnimation = require(
	game.Players.LocalPlayer.PlayerScripts:WaitForChild("GuiAnimationHandler")
)

local PlayerControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerControlHandler"))


-- GUI
local boardGui = playerGui:WaitForChild("Level3Board")
local Slide1 = boardGui:WaitForChild("Slide1")
local Slide2 = boardGui:WaitForChild("Slide2")


-- Ambil ProximityPrompt
local space2 = workspace:WaitForChild("Space 3")
local infoboard = space2:WaitForChild("Infoboard")
local surface = infoboard:WaitForChild("Surface")
local prompt = surface:WaitForChild("ProximityPrompt")

prompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		boardGui.Enabled = true
		GuiAnimation.Show(Slide1)
		PlayerControl.Lock()
	end
end)

Slide1.next.MouseButton1Click:Connect(function()
	Slide1.Visible = false
	Slide2.Visible = true
end)

Slide1.close.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(Slide1)
	boardGui.Enabled = false
	PlayerControl.Unlock()
end)

Slide2.prev.MouseButton1Click:Connect(function()
	Slide2.Visible = false
	Slide1.Visible = true
end)

Slide2.close.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(Slide2)
	boardGui.Enabled = false
	PlayerControl.Unlock()
end)