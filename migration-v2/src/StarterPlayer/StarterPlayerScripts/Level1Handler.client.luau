local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PlayerControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerControlHandler"))

local GuiAnimation = require(
	game.Players.LocalPlayer.PlayerScripts:WaitForChild("GuiAnimationHandler")
)

-- Ambil GUI
local level1Gui = playerGui:WaitForChild("Level1Gui")
local introFrame = level1Gui:WaitForChild("space1IntroFrame")
local audiochoose = level1Gui:WaitForChild("audioChoose")
local audioPlayerMale = level1Gui:WaitForChild("audioPlayerMale")
local audioPlayerFemale = level1Gui:WaitForChild("audioPlayerFemale")
local quizFrame = level1Gui:WaitForChild("quizFrame")

-- Ambil part Space1Answers
local spacePart = workspace:WaitForChild("Space1Answers")
local prompt = spacePart:WaitForChild("ProximityPrompt")

local function hideAll()
	introFrame.Visible = false
	audiochoose.Visible = false
	audioPlayerMale.Visible = false
	audioPlayerFemale.Visible = false
end

-- Ketika E ditekan
prompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		level1Gui.Enabled = true
		GuiAnimation.Show(introFrame)
		PlayerControl.Lock()
	end
end)

-- Tombol Close
local closeButton = introFrame:WaitForChild("close")

closeButton.MouseButton1Click:Connect(function()
	level1Gui.Enabled = false
	introFrame.Visible = false
	PlayerControl.Unlock()
end)

introFrame.mulaibtn.MouseButton1Click:Connect(function()
	hideAll()
	audiochoose.Visible = true
	PlayerControl.Lock()
end)

audiochoose.malebtn.MouseButton1Click:Connect(function()
	hideAll()
	audioPlayerMale.Visible = true
	PlayerControl.Lock() 
end)

audiochoose.femalebtn.MouseButton1Click:Connect(function()
	hideAll()
	audioPlayerFemale.Visible = true
	PlayerControl.Lock()
end)


local function setupAudioPlayer(audioFrame)

	local RunService = game:GetService("RunService")

	local playButton = audioFrame:WaitForChild("PlayButton")
	local pauseButton = audioFrame:WaitForChild("PauseButton")
	local quizButton = audioFrame:WaitForChild("StartQuizButton")

	local progressFill = audioFrame
		:WaitForChild("ProgressBackground")
		:WaitForChild("ProgressFill")

	local confirmModal = audioFrame:WaitForChild("ConfirmModal")
	local yesButton = confirmModal:WaitForChild("YesButton")
	local noButton = confirmModal:WaitForChild("NoButton")

	local sound = audioFrame:WaitForChild("NarationSound")

	quizButton.Active = false
	quizButton.AutoButtonColor = false
	quizButton.ImageTransparency = 0.7

	local connection

	local function startProgress()
		if connection then
			connection:Disconnect()
		end

		connection = RunService.RenderStepped:Connect(function()
			if sound.TimeLength > 0 then
				local progress = sound.TimePosition / sound.TimeLength
				progressFill.Size = UDim2.new(progress, 0, 1, 0)
			end
		end)
	end

	local function enableQuiz()
		quizButton.Active = true
		quizButton.AutoButtonColor = true
		quizButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
		quizButton.ImageTransparency = 0
	end

	playButton.MouseButton1Click:Connect(function()
		sound:Play()
		startProgress()
	end)

	pauseButton.MouseButton1Click:Connect(function()
		sound:Pause()
	end)

	sound.Ended:Connect(function()
		enableQuiz()
	end)

	quizButton.MouseButton1Click:Connect(function()
		if quizButton.Active then
			confirmModal.Visible = true
			
			PlayerControl.Lock()
		end
	end)

	noButton.MouseButton1Click:Connect(function()
		confirmModal.Visible = false
	end)

	yesButton.MouseButton1Click:Connect(function()

		confirmModal.Visible = false
		audioFrame.Visible = false

		-- Tampilkan quiz
		quizFrame.Visible = true
		PlayerControl.Lock()

	end)
end

setupAudioPlayer(audioPlayerMale)
setupAudioPlayer(audioPlayerFemale)

-- Overlay
local overlay = level1Gui:WaitForChild("BackgroundOverlay")

prompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		level1Gui.Enabled = true
		overlay.Visible = true
		introFrame.Visible = true
		PlayerControl.Lock()
	end
end)

closeButton.MouseButton1Click:Connect(function()
	level1Gui.Enabled = false
	overlay.Visible = false
	PlayerControl.Unlock()
	hideAll()
end)