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
local latihanCompleted = false

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

	-- Evaluasi dipindahkan ke kios; audio tidak lagi membuka kuis langsung.
	quizButton.Visible = false
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

-- ===== Papan Informasi (L1_PapanInformasi) =====
local papanInfoFrame = level1Gui:WaitForChild("papanInfoFrame")
local papanPrompt = workspace:WaitForChild("Level1Development"):WaitForChild("L1_PapanInformasi"):WaitForChild("Animation 2"):WaitForChild("ProximityPrompt")

papanPrompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		level1Gui.Enabled = true
		overlay.Visible = true
		GuiAnimation.Show(papanInfoFrame)
		PlayerControl.Lock()
	end
end)

papanInfoFrame.TutupBtn.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(papanInfoFrame)
	overlay.Visible = false
	level1Gui.Enabled = false
	PlayerControl.Unlock()
end)

-- ===== Papan Latihan (L1_PapanLatihan) =====
local latihanFrame = level1Gui:WaitForChild("latihanFrame")
local latihanPrompt = workspace:WaitForChild("Level1Development"):WaitForChild("L1_PapanLatihan"):WaitForChild("Animation 2"):WaitForChild("ProximityPrompt")

-- Latihan 07B: pilih dua dari empat kartu dan tempatkan ke dua slot.
-- UI dibuat runtime agar tidak mengubah/menggandakan objek permanen di place.
local oldActivity = latihanFrame:FindFirstChild("L1TwoSlotActivity")
if oldActivity then oldActivity:Destroy() end
local activity = Instance.new("Frame")
activity.Name = "L1TwoSlotActivity"
activity.BackgroundTransparency = 1
activity.Size = UDim2.new(1, -28, 1, -110)
activity.Position = UDim2.new(0, 14, 0, 70)
activity.Parent = latihanFrame

-- Pastikan UI latihan lama tidak menumpuk di bawah/di atas activity baru.
-- Objek permanen di Studio tetap dipertahankan; hanya disembunyikan saat runtime.
for _, child in ipairs(latihanFrame:GetChildren()) do
	if child:IsA("GuiObject") and child ~= activity and child.Name ~= "TutupBtn" then
		child.Visible = false
	end
end

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(70, 48, 38)
title.Text = "Lengkapi informasi dari audio"
title.Parent = activity

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, 0, 0, 28)
hint.Position = UDim2.new(0, 0, 0, 30)
hint.Font = Enum.Font.Gotham
hint.TextSize = 16
hint.TextColor3 = Color3.fromRGB(85, 65, 55)
hint.Text = "Pilih kartu, lalu klik tempatnya. Dua kartu tidak digunakan."
hint.Parent = activity

local cards = {
	{ id = "A", text = "Sistem operasi berperan penting dalam mengelola sumber daya dan mendukung penggunaan komputer." },
	{ id = "B", text = "Sumber daya yang dikelola mencakup prosesor, memori, penyimpanan, serta perangkat input dan output." },
	{ id = "C", text = "Rekaman menjelaskan langkah memasang sistem operasi." },
	{ id = "D", text = "Sistem operasi merupakan perangkat keras yang mengelola sumber daya komputer." },
}
local cardById = {}
for _, card in ipairs(cards) do cardById[card.id] = card end
local selectedCard = nil
local slots = { main = nil, supporting = nil }
local cardButtons = {}

local cardPanel = Instance.new("ScrollingFrame")
cardPanel.Name = "Cards"
cardPanel.BackgroundTransparency = 1
cardPanel.BorderSizePixel = 0
cardPanel.Size = UDim2.new(0.58, -8, 1, -78)
cardPanel.Position = UDim2.new(0, 0, 0, 68)
cardPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
cardPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
cardPanel.ScrollBarThickness = 5
cardPanel.Parent = activity
local cardLayout = Instance.new("UIListLayout")
cardLayout.Padding = UDim.new(0, 9)
cardLayout.Parent = cardPanel

local slotPanel = Instance.new("Frame")
slotPanel.Name = "Slots"
slotPanel.BackgroundTransparency = 1
slotPanel.Size = UDim2.new(0.42, -8, 1, -78)
slotPanel.Position = UDim2.new(0.58, 8, 0, 68)
slotPanel.Parent = activity

local feedback = Instance.new("TextLabel")
feedback.Name = "Feedback"
feedback.BackgroundTransparency = 1
feedback.Size = UDim2.new(1, 0, 0, 60)
feedback.Position = UDim2.new(0, 0, 0, 286)
feedback.Font = Enum.Font.Gotham
feedback.TextWrapped = true
feedback.TextSize = 16
feedback.TextColor3 = Color3.fromRGB(90, 55, 40)
feedback.Text = ""
feedback.Parent = slotPanel

local checkButton = Instance.new("TextButton")
checkButton.Name = "Periksa"
checkButton.Size = UDim2.new(0.72, 0, 0, 46)
checkButton.Position = UDim2.new(0.14, 0, 0, 226)
checkButton.BackgroundColor3 = Color3.fromRGB(190, 105, 70)
checkButton.TextColor3 = Color3.new(1, 1, 1)
checkButton.Font = Enum.Font.GothamBold
checkButton.TextSize = 18
checkButton.Text = "Periksa"
checkButton.AutoButtonColor = true
checkButton.Parent = slotPanel

local function refreshCards()
	for id, button in pairs(cardButtons) do
		local used = slots.main == id or slots.supporting == id
		local destination = slots.main == id and "PESAN UTAMA" or (slots.supporting == id and "INFORMASI PENDUKUNG" or nil)
		button.BackgroundColor3 = used and Color3.fromRGB(150, 150, 150)
			or (selectedCard == id and Color3.fromRGB(80, 145, 205) or Color3.fromRGB(226, 157, 103))
		button.TextColor3 = Color3.new(1, 1, 1)
		if destination then
			button.Text = id .. ". DITEMPATKAN → " .. destination .. "\n" .. cardById[id].text
		elseif selectedCard == id then
			button.Text = id .. ". DIPILIH — KLIK SLOT TUJUAN\n" .. cardById[id].text
		else
			button.Text = id .. ". " .. cardById[id].text
		end
	end
	local ready = slots.main ~= nil and slots.supporting ~= nil
	checkButton.Active = ready
	checkButton.AutoButtonColor = ready
	checkButton.BackgroundColor3 = ready and Color3.fromRGB(190, 105, 70) or Color3.fromRGB(150, 140, 135)
	checkButton.Text = ready and "Periksa jawaban" or "Isi kedua slot untuk memeriksa"
end

-- Deklarasikan lebih dahulu agar callback slot merujuk objek lokal yang benar.
local mainSlot
local supportingSlot

local function makeSlot(name, label, key)
	local slot = Instance.new("TextButton")
	slot.Name = name
	slot.Size = UDim2.new(1, 0, 0, 100)
	slot.Position = key == "main" and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, 0, 110)
	slot.BackgroundColor3 = Color3.fromRGB(245, 226, 207)
	slot.TextColor3 = Color3.fromRGB(75, 52, 42)
	slot.Font = Enum.Font.Gotham
	slot.TextSize = 16
	slot.TextWrapped = true
	slot.Text = label .. "\nBelum terisi — pilih kartu di kiri, lalu klik tempat ini"
	slot.Parent = slotPanel
	slot.MouseButton1Click:Connect(function()
		if selectedCard then
			-- Satu kartu hanya boleh berada pada satu slot.
			if slots.main == selectedCard then slots.main = nil end
			if slots.supporting == selectedCard then slots.supporting = nil end
			slots[key] = selectedCard
			selectedCard = nil
			if slots.main then
				mainSlot.Text = "Pesan utama — TERISI KARTU " .. slots.main .. "\n" .. cardById[slots.main].text
			else
				mainSlot.Text = "Pesan utama\nBelum terisi — pilih kartu di kiri, lalu klik tempat ini"
			end
			if slots.supporting then
				supportingSlot.Text = "Informasi pendukung — TERISI KARTU " .. slots.supporting .. "\n" .. cardById[slots.supporting].text
			else
				supportingSlot.Text = "Informasi pendukung\nBelum terisi — pilih kartu di kiri, lalu klik tempat ini"
			end
			feedback.TextColor3 = Color3.fromRGB(40, 115, 65)
			feedback.Text = "Kartu berhasil ditempatkan. Isi slot lainnya, lalu tekan Periksa."
			refreshCards()
		else
			feedback.TextColor3 = Color3.fromRGB(170, 90, 50)
			feedback.Text = "Pilih salah satu kartu di sebelah kiri terlebih dahulu."
		end
	end)
	return slot
end
mainSlot = makeSlot("PesanUtama", "Pesan utama", "main")
supportingSlot = makeSlot("InformasiPendukung", "Informasi pendukung", "supporting")

for _, card in ipairs(cards) do
	local button = Instance.new("TextButton")
	button.Name = "Kartu" .. card.id
	button.Size = UDim2.new(1, -6, 0, 78)
	button.BackgroundColor3 = Color3.fromRGB(226, 157, 103)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.Gotham
	button.TextSize = 16
	button.TextWrapped = true
	button.Text = card.id .. ". " .. card.text
	button.Parent = cardPanel
	cardButtons[card.id] = button
	button.MouseButton1Click:Connect(function()
		if slots.main == card.id then slots.main = nil end
		if slots.supporting == card.id then slots.supporting = nil end
		selectedCard = card.id
		feedback.Text = "Kartu " .. card.id .. " dipilih — sekarang klik slot tujuan di sebelah kanan."
		refreshCards()
	end)
end

local function resetLatihan()
	selectedCard = nil
	slots.main = nil
	slots.supporting = nil
	feedback.Text = ""
	mainSlot.Text = "Pesan utama\nBelum terisi — pilih kartu di kiri, lalu klik tempat ini"
	supportingSlot.Text = "Informasi pendukung\nBelum terisi — pilih kartu di kiri, lalu klik tempat ini"
	checkButton.Active = true
	refreshCards()
end

latihanPrompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		resetLatihan()
		level1Gui.Enabled = true
		overlay.Visible = true
		GuiAnimation.Show(latihanFrame)
		PlayerControl.Lock()
	end
end)

latihanFrame.TutupBtn.MouseButton1Click:Connect(function()
	GuiAnimation.Hide(latihanFrame)
	overlay.Visible = false
	level1Gui.Enabled = false
	PlayerControl.Unlock()
end)

local function updateSlotText()
	local main = slots.main and cardById[slots.main].text or "(Klik kartu, lalu klik tempat ini)"
	local supporting = slots.supporting and cardById[slots.supporting].text or "(Klik kartu, lalu klik tempat ini)"
	mainSlot.Text = "Pesan utama\n" .. main
	supportingSlot.Text = "Informasi pendukung\n" .. supporting
end

checkButton.MouseButton1Click:Connect(function()
	updateSlotText()
	if not slots.main or not slots.supporting then
		feedback.TextColor3 = Color3.fromRGB(170, 90, 50)
		feedback.Text = "Isi kedua tempat terlebih dahulu."
		return
	end
	local correct = slots.main == "A" and slots.supporting == "B"
	if correct then
		latihanCompleted = true
		feedback.TextColor3 = Color3.fromRGB(40, 140, 60)
		feedback.Text = "Tepat. Pesan utama merangkum peran sistem operasi; informasi pendukung merinci sumber daya yang dikelolanya. Latihan selesai."
		checkButton.Active = false
		checkButton.AutoButtonColor = false
	else
		feedback.TextColor3 = Color3.fromRGB(180, 70, 45)
		feedback.Text = "Periksa kembali penempatannya: mana yang merangkum seluruh pembahasan dan mana yang memberi rincian khusus?"
	end
end)

-- ===== Kios Evaluasi Level 1 =====
local kioskModel = workspace:WaitForChild("Level1Development"):WaitForChild("L1_KiosEvaluasi")
-- Anchor khusus mencegah prompt menempel pada bagian dekorasi kios yang tidak terjangkau.
local kioskPromptPart = kioskModel:FindFirstChild("L1KioskInteractionAnchor")
if not kioskPromptPart then
	local kioskCFrame, kioskSize = kioskModel:GetBoundingBox()
	kioskPromptPart = Instance.new("Part")
	kioskPromptPart.Name = "L1KioskInteractionAnchor"
	kioskPromptPart.Anchored = true
	kioskPromptPart.CanCollide = false
	kioskPromptPart.CanTouch = false
	kioskPromptPart.CanQuery = false
	kioskPromptPart.Transparency = 1
	kioskPromptPart.Size = Vector3.new(1, 1, 1)
	kioskPromptPart.CFrame = kioskCFrame * CFrame.new(0, math.max(1.5, kioskSize.Y * 0.2), 0)
	kioskPromptPart.Parent = kioskModel
end
do
	local kioskPrompt = kioskPromptPart:FindFirstChild("L1KioskPrompt")
	if not kioskPrompt then
		kioskPrompt = Instance.new("ProximityPrompt")
		kioskPrompt.Name = "L1KioskPrompt"
		kioskPrompt.ActionText = "Buka evaluasi"
		kioskPrompt.ObjectText = "Evaluasi Level 1"
		kioskPrompt.KeyboardKeyCode = Enum.KeyCode.E
		kioskPrompt.HoldDuration = 1
		kioskPrompt.MaxActivationDistance = 16
		kioskPrompt.RequiresLineOfSight = false
		kioskPrompt.Parent = kioskPromptPart
	end
	local kioskLabel = kioskPromptPart:FindFirstChild("L1KioskLabel")
	if kioskLabel then kioskLabel:Destroy() end

	local oldKioskFrame = level1Gui:FindFirstChild("L1KioskFrame")
	if oldKioskFrame then oldKioskFrame:Destroy() end
	local kioskFrame = Instance.new("Frame")
	kioskFrame.Name = "L1KioskFrame"
	kioskFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	kioskFrame.Position = UDim2.fromScale(0.5, 0.5)
	kioskFrame.Size = UDim2.fromScale(0.58, 0.54)
	kioskFrame.BackgroundColor3 = Color3.fromRGB(246, 224, 207)
	kioskFrame.Visible = false
	kioskFrame.ZIndex = 20
	kioskFrame.Parent = level1Gui
	local kioskCorner = Instance.new("UICorner")
	kioskCorner.CornerRadius = UDim.new(0, 16)
	kioskCorner.Parent = kioskFrame
	local kioskStroke = Instance.new("UIStroke")
	kioskStroke.Color = Color3.fromRGB(154, 103, 76)
	kioskStroke.Thickness = 2
	kioskStroke.Parent = kioskFrame

	local kioskTitle = Instance.new("TextLabel")
	kioskTitle.BackgroundTransparency = 1
	kioskTitle.Position = UDim2.new(0.06, 0, 0.07, 0)
	kioskTitle.Size = UDim2.new(0.88, 0, 0.14, 0)
	kioskTitle.Font = Enum.Font.GothamBold
	kioskTitle.TextSize = 30
	kioskTitle.TextColor3 = Color3.fromRGB(70, 47, 37)
	kioskTitle.Text = "Evaluasi Level 1"
	kioskTitle.ZIndex = 21
	kioskTitle.Parent = kioskFrame

	local kioskMessage = Instance.new("TextLabel")
	kioskMessage.BackgroundTransparency = 1
	kioskMessage.Position = UDim2.new(0.08, 0, 0.23, 0)
	kioskMessage.Size = UDim2.new(0.84, 0, 0.38, 0)
	kioskMessage.Font = Enum.Font.Gotham
	kioskMessage.TextSize = 22
	kioskMessage.TextWrapped = true
	kioskMessage.TextColor3 = Color3.fromRGB(75, 55, 45)
	kioskMessage.ZIndex = 21
	kioskMessage.Parent = kioskFrame

	local startEvaluation = Instance.new("TextButton")
	startEvaluation.Position = UDim2.new(0.52, 0, 0.72, 0)
	startEvaluation.Size = UDim2.new(0.4, 0, 0.14, 0)
	startEvaluation.BackgroundColor3 = Color3.fromRGB(190, 99, 66)
	startEvaluation.TextColor3 = Color3.new(1, 1, 1)
	startEvaluation.Font = Enum.Font.GothamBold
	startEvaluation.TextSize = 20
	startEvaluation.Text = "Mulai evaluasi"
	startEvaluation.ZIndex = 21
	startEvaluation.Parent = kioskFrame
	local startCorner = Instance.new("UICorner")
	startCorner.CornerRadius = UDim.new(0, 9)
	startCorner.Parent = startEvaluation

	local closeKiosk = Instance.new("TextButton")
	closeKiosk.Position = UDim2.new(0.08, 0, 0.72, 0)
	closeKiosk.Size = UDim2.new(0.4, 0, 0.14, 0)
	closeKiosk.BackgroundColor3 = Color3.fromRGB(125, 102, 90)
	closeKiosk.TextColor3 = Color3.new(1, 1, 1)
	closeKiosk.Font = Enum.Font.GothamBold
	closeKiosk.TextSize = 20
	closeKiosk.Text = "Nanti dulu"
	closeKiosk.ZIndex = 21
	closeKiosk.Parent = kioskFrame
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 9)
	closeCorner.Parent = closeKiosk

	local function closeKioskFrame()
		kioskFrame.Visible = false
		overlay.Visible = false
		level1Gui.Enabled = false
		PlayerControl.Unlock()
	end

	-- Evaluasi mandiri: tier 1 jawaban, tier 2 alasan, lalu feedback.
	-- Tidak memakai quizFrame baseline karena handler lamanya masih mengarahkan ulang ke audioChoose.
	local oldEvaluation = level1Gui:FindFirstChild("L1TwoTierEvaluation")
	if oldEvaluation then oldEvaluation:Destroy() end
	local evaluationFrame = Instance.new("Frame")
	evaluationFrame.Name = "L1TwoTierEvaluation"
	evaluationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	evaluationFrame.Position = UDim2.fromScale(0.5, 0.5)
	evaluationFrame.Size = UDim2.fromScale(0.78, 0.84)
	evaluationFrame.BackgroundColor3 = Color3.fromRGB(246, 224, 207)
	evaluationFrame.Visible = false
	evaluationFrame.ZIndex = 30
	evaluationFrame.Parent = level1Gui
	local evaluationCorner = Instance.new("UICorner")
	evaluationCorner.CornerRadius = UDim.new(0, 16)
	evaluationCorner.Parent = evaluationFrame
	local evaluationStroke = Instance.new("UIStroke")
	evaluationStroke.Color = Color3.fromRGB(154, 103, 76)
	evaluationStroke.Thickness = 2
	evaluationStroke.Parent = evaluationFrame

	local function makeText(parent, name, position, size, textSize, bold)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.BackgroundTransparency = 1
		label.Position = position
		label.Size = size
		label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
		label.TextSize = textSize
		label.TextColor3 = Color3.fromRGB(70, 47, 37)
		label.TextWrapped = true
		label.ZIndex = 31
		label.Parent = parent
		return label
	end

	local evaluationTitle = makeText(evaluationFrame, "Title", UDim2.new(0.06, 0, 0.04, 0), UDim2.new(0.88, 0, 0.07, 0), 28, true)
	local evaluationStem = makeText(evaluationFrame, "Stem", UDim2.new(0.07, 0, 0.12, 0), UDim2.new(0.86, 0, 0.13, 0), 19, false)
	local selectedSummary = makeText(evaluationFrame, "SelectedSummary", UDim2.new(0.07, 0, 0.25, 0), UDim2.new(0.86, 0, 0.08, 0), 17, false)
	selectedSummary.Visible = false
	local options = Instance.new("ScrollingFrame")
	options.Name = "Options"
	options.BackgroundTransparency = 1
	options.BorderSizePixel = 0
	options.Position = UDim2.new(0.07, 0, 0.34, 0)
	options.Size = UDim2.new(0.86, 0, 0.42, 0)
	options.CanvasSize = UDim2.new(0, 0, 0, 0)
	options.AutomaticCanvasSize = Enum.AutomaticSize.Y
	options.ScrollBarThickness = 6
	options.ZIndex = 31
	options.Parent = evaluationFrame
	local optionLayout = Instance.new("UIListLayout")
	optionLayout.Padding = UDim.new(0, 7)
	optionLayout.Parent = options
	local status = makeText(evaluationFrame, "Status", UDim2.new(0.07, 0, 0.76, 0), UDim2.new(0.86, 0, 0.09, 0), 18, false)
	status.TextColor3 = Color3.fromRGB(100, 70, 55)
	local submit = Instance.new("TextButton")
	submit.Name = "Submit"
	submit.AnchorPoint = Vector2.new(0.5, 0)
	submit.Position = UDim2.new(0.5, 0, 0.87, 0)
	submit.Size = UDim2.new(0.38, 0, 0.08, 0)
	submit.BackgroundColor3 = Color3.fromRGB(150, 140, 135)
	submit.TextColor3 = Color3.new(1, 1, 1)
	submit.Font = Enum.Font.GothamBold
	submit.TextSize = 20
	submit.Text = "Pilih jawaban terlebih dahulu"
	submit.Active = false
	submit.AutoButtonColor = false
	submit.ZIndex = 31
	submit.Parent = evaluationFrame
	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 9)
	submitCorner.Parent = submit

	local evaluationQuestions = {
		{ stem = "Berdasarkan narasi audio yang disampaikan, sistem operasi dapat diartikan sebagai …", options = {"A. Perangkat keras utama yang berfungsi menjalankan aplikasi", "B. Perangkat lunak yang berfungsi mengelola sumber daya komputer", "C. Program tambahan yang digunakan untuk mempercepat kinerja komputer", "D. Sistem jaringan yang menghubungkan komputer dengan internet", "E. Media penyimpanan data yang digunakan oleh pengguna"}, reasons = {"A. Narasi menyebut OS sebagai perangkat keras yang menjalankan aplikasi.", "B. Narasi menyebut OS sebagai perangkat lunak pengelola sumber daya.", "C. Narasi membatasi tugas OS pada pengaturan jaringan dan akses internet.", "D. Narasi menyamakan OS dengan perangkat penyimpanan data milik pengguna."}, answer = 2, reason = 2, f1 = {"OS disebut perangkat lunak, bukan perangkat keras utama.", "Benar. OS adalah perangkat lunak yang mengelola sumber daya komputer.", "Narasi menjelaskan pengelolaan sumber daya, bukan program tambahan untuk mempercepat komputer.", "Jaringan internet tidak sama dengan OS yang dimaksud narasi.", "Penyimpanan adalah salah satu sumber daya yang dikelola, bukan pengertian OS."}, f2 = {"Alasan A mengubah OS menjadi perangkat keras; narasi menyebut perangkat lunak.", "Alasan B tepat: narasi merinci sumber daya yang dikelola perangkat lunak.", "Alasan C mempersempit isi menjadi internet, padahal narasi membahas berbagai sumber daya.", "Alasan D menyamakan pengelola dengan penyimpanan yang dikelola."} },
		{ stem = "Salah satu peran utama sistem operasi menurut narasi audio adalah …", options = {"A. Menggantikan fungsi perangkat keras komputer", "B. Menyimpan seluruh data pengguna secara permanen", "C. Menjadi penghubung antara pengguna dan aplikasi", "D. Mengendalikan jaringan internet secara langsung", "E. Menjalankan aplikasi tanpa bantuan perangkat keras"}, reasons = {"A. Narasi menyebut OS sebagai penghubung antara pengguna dan aplikasi.", "B. Narasi menyebut OS sebagai pengganti seluruh perangkat keras komputer.", "C. Narasi menyebut OS sebagai tempat penyimpanan permanen seluruh data.", "D. Narasi menyebut OS sebagai pengelola layanan internet pada komputer."}, answer = 3, reason = 1, f1 = {"Penghubung tidak berarti menggantikan perangkat keras.", "Menyimpan seluruh data secara permanen bukan peran yang ditanyakan dalam narasi.", "Benar. Narasi menyebut OS sebagai penghubung pengguna dan aplikasi.", "Mengendalikan internet bukan peran penghubung yang dijelaskan narasi.", "Narasi tidak menyatakan aplikasi berjalan tanpa perangkat keras."}, f2 = {"Alasan A tepat: hubungan pengguna dan aplikasi dinyatakan dalam narasi.", "Alasan B tidak tepat karena menjadi penghubung tidak menghapus kebutuhan perangkat keras.", "Alasan C tidak menunjukkan hubungan pengguna dan aplikasi yang ditanyakan.", "Alasan D membatasi OS pada internet, berbeda dari peran yang dijelaskan."} },
		{ stem = "Implementasi nyata dari pemahaman fungsi sistem operasi dalam mengelola sumber daya komputer secara optimal adalah …", options = {"A. Mendesain ulang perangkat keras komputer agar seluruh aplikasi berjalan tanpa sistem operasi", "B. Mengatur alokasi prosesor dan memori agar aplikasi dan sistem dapat bekerja secara terpadu", "C. Menghubungkan komputer ke jaringan internet agar semua perangkat lunak dapat diperbarui secara otomatis", "D. Menambahkan perangkat penyimpanan eksternal untuk memperbesar kapasitas data pengguna", "E. Menginstal sebanyak mungkin aplikasi agar kinerja komputer meningkat secara maksimal"}, reasons = {"A. Audio mengaitkan penambahan jumlah aplikasi dengan peningkatan kinerja komputer.", "B. Audio mengaitkan pemasangan perangkat tambahan dengan percepatan seluruh aplikasi.", "C. Audio mengaitkan pengelolaan sumber daya dengan kerja terpadu aplikasi dan sistem.", "D. Audio mengaitkan penggunaan internet dengan penggantian fungsi pengelolaan memori komputer."}, answer = 2, reason = 3, f1 = {"Merancang ulang perangkat keras bukan contoh pengelolaan sumber daya dalam audio.", "Benar. Pengelolaan prosesor dan memori sesuai peran OS yang dibahas.", "Pembaruan melalui internet berbeda dari alokasi sumber daya yang ditanyakan.", "Menambah kapasitas penyimpanan berbeda dari mengatur prosesor dan memori.", "Narasi tidak menyatakan semakin banyak aplikasi selalu meningkatkan kinerja."}, f2 = {"Alasan A tidak didukung: audio tidak menghubungkan banyaknya aplikasi dengan peningkatan kinerja.", "Alasan B menambah klaim bahwa perangkat tambahan otomatis mempercepat seluruh aplikasi.", "Alasan C tepat: pengelolaan sumber daya dihubungkan dengan kerja terpadu aplikasi dan sistem.", "Alasan D mengganti pengelolaan memori dengan internet, yang tidak dijelaskan audio."} },
		{ stem = "Dalam narasi audio, apa yang terjadi jika sistem operasi tidak mampu menjalankan peran penghubung pengguna dan aplikasi dengan baik?", options = {"A. Aplikasi akan berjalan lebih cepat karena tidak ada perantara", "B. Pengguna dapat langsung mengakses perangkat keras tanpa hambatan", "C. Perangkat keras akan meningkatkan kinerjanya secara mandiri", "D. Sistem operasi akan digantikan secara otomatis oleh aplikasi lain", "E. Aplikasi tidak dapat berjalan dengan baik karena komunikasi antara pengguna dan perangkat terganggu"}, reasons = {"A. Audio menyebut aplikasi mengambil alih seluruh tugas OS secara otomatis.", "B. Audio menyebut perangkat keras menambah kemampuannya sendiri saat OS terganggu.", "C. Audio menyebut kegagalan penghubung membuat aplikasi berjalan semakin cepat.", "D. Audio menyebut gangguan peran OS menghambat aplikasi berjalan dengan baik."}, answer = 5, reason = 4, f1 = {"Kegagalan penghubung dalam narasi mengganggu aplikasi, bukan mempercepatnya.", "Narasi tidak menyatakan kegagalan OS membuat akses perangkat keras menjadi tanpa hambatan.", "Kenaikan kemampuan perangkat keras secara mandiri tidak dinyatakan dalam audio.", "Pergantian OS oleh aplikasi secara otomatis tidak dinyatakan dalam audio.", "Benar. Akibat yang dinyatakan adalah aplikasi tidak dapat berjalan dengan baik."}, f2 = {"Alasan A tidak didukung: aplikasi tidak disebut mengambil alih seluruh tugas OS.", "Alasan B menambahkan kenaikan kemampuan perangkat keras yang tidak dinyatakan.", "Alasan C membalik akibat: kegagalan penghubung mengganggu, bukan mempercepat aplikasi.", "Alasan D tepat: kegagalan peran OS dikaitkan dengan aplikasi yang tidak berjalan baik."} },
	}
	local currentQuestion, currentTier, selectedAnswer, selectedReason = 1, 1, nil, nil
	local evaluationMode = "tier"
	local answerCorrect, reasonCorrect = 0, 0
	local optionButtons = {}
	local function setSubmit(enabled, text)
		submit.Active = enabled
		submit.AutoButtonColor = enabled
		submit.BackgroundColor3 = enabled and Color3.fromRGB(190, 99, 66) or Color3.fromRGB(150, 140, 135)
		submit.Text = text
	end
	local renderEvaluation
	local function showResult()
		evaluationMode = "result"
		for _, child in ipairs(options:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		selectedSummary.Visible = false
		evaluationTitle.Text = answerCorrect >= 3 and "Level 1 selesai" or "Level 1 belum tuntas"
		evaluationStem.Text = "Nilai jawaban: " .. (answerCorrect * 25) .. " / 100\nJawaban tepat: " .. answerCorrect .. " dari 4 • Alasan tepat: " .. reasonCorrect .. " dari 4"
		if answerCorrect >= 3 then
			status.Text = "Kamu memenuhi nilai minimal 75 untuk melanjutkan. Tutup panel lalu ikuti jalur ke Level 2."
		else
			status.Text = "Nilai minimal untuk melanjutkan adalah 75. Pelajari kembali bagian yang belum dipahami, lalu kembali ke kios untuk mencoba evaluasi lagi."
		end
		setSubmit(true, "Tutup hasil")
	end
	renderEvaluation = function()
		evaluationMode = "tier"
		for _, child in ipairs(options:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		optionButtons = {}
		local q = evaluationQuestions[currentQuestion]
		if currentTier == 1 then
			evaluationTitle.Text = "Evaluasi " .. currentQuestion .. "/4 — Tingkat 1: Jawaban"
			evaluationStem.Text = q.stem
			selectedSummary.Visible = false
			status.Text = "Pilih satu jawaban, lalu kunci jawaban tersebut."
			setSubmit(selectedAnswer ~= nil, selectedAnswer and "Kunci jawaban" or "Pilih jawaban terlebih dahulu")
		else
			evaluationTitle.Text = "Evaluasi " .. currentQuestion .. "/4 — Tingkat 2: Alasan"
			evaluationStem.Text = "Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?"
			selectedSummary.Visible = true
			selectedSummary.Text = "Jawaban terkunci: " .. q.options[selectedAnswer]
			status.Text = "Pilih satu alasan, lalu kirim kedua jawaban."
			setSubmit(selectedReason ~= nil, selectedReason and "Kirim jawaban" or "Pilih alasan terlebih dahulu")
		end
		local entries = currentTier == 1 and q.options or q.reasons
		for index, text in ipairs(entries) do
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, -8, 0, 50)
			button.BackgroundColor3 = Color3.fromRGB(232, 210, 196)
			button.TextColor3 = Color3.fromRGB(70, 47, 37)
			button.Font = Enum.Font.Gotham
			button.TextSize = 17
			button.TextWrapped = true
			button.Text = text
			button.ZIndex = 32
			button.Parent = options
			optionButtons[index] = button
			button.MouseButton1Click:Connect(function()
				if currentTier == 1 then selectedAnswer = index else selectedReason = index end
				for i, other in pairs(optionButtons) do other.BackgroundColor3 = i == index and Color3.fromRGB(103, 151, 199) or Color3.fromRGB(232, 210, 196) end
				setSubmit(true, currentTier == 1 and "Kunci jawaban" or "Kirim jawaban")
			end)
		end
	end
	submit.MouseButton1Click:Connect(function()
		if evaluationMode == "result" then
			evaluationFrame.Visible = false
			overlay.Visible = false
			level1Gui.Enabled = false
			PlayerControl.Unlock()
			return
		end
		if evaluationMode == "feedback" then
			if currentQuestion < #evaluationQuestions then
				currentQuestion += 1
				currentTier, selectedAnswer, selectedReason = 1, nil, nil
				renderEvaluation()
			else
				showResult()
			end
			return
		end
		if currentTier == 1 and selectedAnswer then
			currentTier = 2
			renderEvaluation()
		elseif currentTier == 2 and selectedReason then
			local q = evaluationQuestions[currentQuestion]
			local answerOK, reasonOK = selectedAnswer == q.answer, selectedReason == q.reason
			if answerOK then answerCorrect += 1 end
			if reasonOK then reasonCorrect += 1 end
			for _, child in ipairs(options:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
			evaluationTitle.Text = (answerOK and "Jawaban tepat" or "Jawaban belum tepat") .. " • " .. (reasonOK and "Alasan tepat" or "Alasan belum tepat")
			evaluationStem.Text = q.f1[selectedAnswer] .. "\n\n" .. q.f2[selectedReason]
			selectedSummary.Visible = true
			selectedSummary.Text = "Nilai jawaban soal ini: " .. (answerOK and "25 dari 25" or "0 dari 25") .. ". Ketepatan alasan dicatat terpisah."
			status.Text = "Jawaban dan alasan pada soal ini sudah dikirim dan tidak dapat diubah."
			setSubmit(true, currentQuestion < #evaluationQuestions and "Soal berikutnya" or "Lihat hasil")
			evaluationMode = "feedback"
		end
	end)
	local function openEvaluation()
		currentQuestion, currentTier, selectedAnswer, selectedReason = 1, 1, nil, nil
		answerCorrect, reasonCorrect = 0, 0
		evaluationMode = "tier"
		quizFrame.Visible = false
		evaluationFrame.Visible = true
		renderEvaluation()
	end

	kioskPrompt.Triggered:Connect(function(triggeredPlayer)
		if triggeredPlayer ~= player then return end
		level1Gui.Enabled = true
		overlay.Visible = true
		kioskFrame.Visible = true
		PlayerControl.Lock()
		if latihanCompleted then
			kioskMessage.Text = "Siap mengikuti evaluasi Level 1?\n\nAda 4 soal. Jawaban benar bernilai 25 dan nilai minimal untuk melanjutkan adalah 75."
			startEvaluation.Visible = true
			startEvaluation.Position = UDim2.new(0.52, 0, 0.72, 0)
			closeKiosk.Position = UDim2.new(0.08, 0, 0.72, 0)
			closeKiosk.Text = "Nanti dulu"
		else
			kioskMessage.Text = "Evaluasi belum dapat dimulai.\n\nSelesaikan latihan pesan utama dan informasi pendukung terlebih dahulu."
			startEvaluation.Visible = false
			closeKiosk.Position = UDim2.new(0.3, 0, 0.72, 0)
			closeKiosk.Text = "Kembali ke latihan"
		end
	end)

	closeKiosk.MouseButton1Click:Connect(closeKioskFrame)
	startEvaluation.MouseButton1Click:Connect(function()
		if not latihanCompleted then return end
		kioskFrame.Visible = false
		openEvaluation()
	end)
end
