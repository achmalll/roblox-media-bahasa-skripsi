local Players = game:GetService("Players")

local player = Players.LocalPlayer
-- Research records are server-timed; no player names or free text are sent.
local recordHttp = game:GetService("HttpService")
local function recordLearning(op, fields)
 local remote=game:GetService("ReplicatedStorage"):FindFirstChild("LearningRecordEvent")
 if not remote then return end
 fields=fields or {}; fields.op=op; fields.level=3; fields.id=fields.id or recordHttp:GenerateGUID(false)
 remote:FireServer(fields)
end

local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local level3Gui = playerGui:WaitForChild("Level3Gui")
local introFrame = level3Gui:WaitForChild("space3IntroFrame")
local AbstractFrame = level3Gui:WaitForChild("AbstractFrame")
local ConfirmModal = level3Gui:WaitForChild("ConfirmModal")
local Overlay = level3Gui:WaitForChild("BackgroundOverlay")
local quizFrame = level3Gui:WaitForChild("quizFrame")

-- Keep the same navigation convention as Levels 1 and 2.
local function navigationButton(button,right)
 button.AnchorPoint=Vector2.new(right and 1 or 0,1)
 button.Position=UDim2.fromScale(right and .92 or .08,.94)
 button.Size=UDim2.fromScale(.40,.12)
 button.TextWrapped=true; button.TextSize=20; button.Font=Enum.Font.GothamBold
 button.TextColor3=Color3.new(1,1,1)
 button.BackgroundColor3=right and Color3.fromRGB(153,59,42) or Color3.fromRGB(125,102,90)
 if not button:FindFirstChildOfClass("UICorner") then Instance.new("UICorner",button).CornerRadius=UDim.new(0,10) end
end
navigationButton(introFrame:WaitForChild("mulaibtn"),true)
navigationButton(AbstractFrame:WaitForChild("StartQuizButton"),true)
navigationButton(ConfirmModal:WaitForChild("NoButton"),false)
navigationButton(ConfirmModal:WaitForChild("YesButton"),true)
introFrame.mulaibtn.Text="Mulai"
AbstractFrame.StartQuizButton.Text="Mulai evaluasi"
ConfirmModal.NoButton.Text="Nanti dulu"
ConfirmModal.YesButton.Text="Mulai evaluasi"

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
		recordLearning("start")

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
