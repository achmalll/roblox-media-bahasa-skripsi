local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local PlayerControl = require(player.PlayerScripts:WaitForChild("PlayerControlHandler"))
local GuiAnimation = require(player.PlayerScripts:WaitForChild("GuiAnimationHandler"))
local level1Gui = playerGui:WaitForChild("Level1Gui")
local introFrame = level1Gui:WaitForChild("space1IntroFrame")
local audiochoose = level1Gui:WaitForChild("audioChoose")
local audioPlayerMale = level1Gui:WaitForChild("audioPlayerMale")
local audioPlayerFemale = level1Gui:WaitForChild("audioPlayerFemale")
local quizFrame = level1Gui:WaitForChild("quizFrame")
local overlay = level1Gui:WaitForChild("BackgroundOverlay")
local latihanCompleted = false
local spacePart = workspace:WaitForChild("Space1Answers")
local prompt = spacePart:WaitForChild("ProximityPrompt")

-- 04B / 06B1 / 06B2: male dahulu; female menyusul.
local clips = {
	{ id = "101781033507422", title = "Pengertian dan sumber daya" },
	{ id = "95164082214235", title = "Peran dan contoh sistem operasi" },
	{ id = "134699797461072", title = "Tujuan dan manfaat pemahaman" },
}
local completed = {false, false, false}
local positions = {0, 0, 0}
local activeClip = 1
local infoVisited = false
local loadVersion = 0
local pendingPlay = false
local loaded = false
local paused = false
local sound = audioPlayerMale:WaitForChild("NarationSound")
sound:Stop()
sound.Looped = false
sound.SoundId = "rbxassetid://" .. clips[1].id
audioPlayerFemale:WaitForChild("NarationSound"):Stop()
audiochoose.Visible = false
audioPlayerFemale.Visible = false
-- Existing panel/frame/border retained; controls replace the old quiz/audio choice UI at runtime.
for _, child in ipairs(audioPlayerMale:GetChildren()) do
	if child:IsA("GuiObject") then child.Visible = false end
end
local root = Instance.new("Frame")
root.Name = "L1SegmentedAudio"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundTransparency = 1
root.ZIndex = 30
root.Parent = audioPlayerMale
-- Keep the baseline cream/brown shell; constrain the wide audio panel on desktop.
audioPlayerMale.AnchorPoint = Vector2.new(.5,.5)
audioPlayerMale.Position = UDim2.fromScale(.5,.5)
audioPlayerMale.Size = UDim2.fromScale(.86,.72)
local panelBounds = Instance.new("UISizeConstraint")
panelBounds.MaxSize = Vector2.new(860,560)
panelBounds.MinSize = Vector2.new(280,240)
panelBounds.Parent = audioPlayerMale
local function control(class, name, text, x, y, w, h)
	local item = Instance.new(class)
	item.Name = name
	item.Position = UDim2.fromScale(x, y)
	item.Size = UDim2.fromScale(w, h)
	item.BackgroundColor3 = Color3.fromRGB(155, 72, 48)
	item.BackgroundTransparency = class == "TextLabel" and 1 or 0
	item.TextColor3 = class == "TextLabel" and Color3.fromRGB(71, 32, 3) or Color3.new(1,1,1)
	item.Font = Enum.Font.GothamBold
	item.TextSize = 20
	item.TextWrapped = true
	item.Text = text
	item.ZIndex = 31
	item.Parent = root
	if class == "TextButton" then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = item
	end
	return item
end
local badge = control("TextLabel", "Segment", "", .08,.07,.72,.06)
badge.TextSize = 16
badge.TextXAlignment = Enum.TextXAlignment.Left
badge.TextColor3 = Color3.fromRGB(155,72,48)
local heading = control("TextLabel", "Heading", "", .08,.15,.76,.14)
heading.TextSize = 26
heading.TextXAlignment = Enum.TextXAlignment.Left
local status = control("TextLabel", "Status", "", .08,.32,.84,.13)
status.Font = Enum.Font.Gotham
status.TextSize = 18
status.TextXAlignment = Enum.TextXAlignment.Left
local bar = Instance.new("Frame")
bar.Name = "ClipProgress"
bar.Position = UDim2.fromScale(.08,.50)
bar.Size = UDim2.fromScale(.84,.022)
bar.BorderSizePixel = 0
bar.BackgroundColor3 = Color3.fromRGB(209,156,116)
bar.ZIndex = 31
bar.Parent = root
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0,1)
fill.BackgroundColor3 = Color3.fromRGB(155,72,48)
fill.BorderSizePixel = 0
fill.ZIndex = 32
fill.Parent = bar
for _, target in ipairs({bar,fill}) do
	local rounded = Instance.new("UICorner")
	rounded.CornerRadius = UDim.new(1,0)
	rounded.Parent = target
end
local timeLabel = control("TextLabel", "Time", "0:00 / 0:00", .08,.54,.84,.06)
timeLabel.TextSize = 16
timeLabel.TextXAlignment = Enum.TextXAlignment.Right
local play = control("TextButton", "PlayPause", "Putar", .30,.63,.40,.11)
local nextButton = control("TextButton", "Next", "", .20,.79,.60,.11)
local back = control("TextButton", "Previous", "Kembali ke audio 2", .20,.915,.60,.055)
back.TextSize = 16
back.BackgroundTransparency = 1
back.TextColor3 = Color3.fromRGB(71,32,3)
local close = control("TextButton", "Close", "×", .88,.04,.065,.085)
close.TextSize = 22
local function hideAll()
	if audioPlayerMale.Visible then
		positions[activeClip] = sound.TimePosition
		sound:Pause()
		paused = true
	end
	pendingPlay = false
	introFrame.Visible = false
	audiochoose.Visible = false
	audioPlayerMale.Visible = false
	audioPlayerFemale.Visible = false
end
local function closeAudio()
	hideAll()
	level1Gui.Enabled = false
	overlay.Visible = false
	PlayerControl.Unlock()
end
local function refresh()
	badge.Text = "LEVEL 1  /  AUDIO " .. activeClip .. " DARI 3"
	heading.Text = clips[activeClip].title
	play.Text = sound.IsPlaying and "Jeda" or (completed[activeClip] and "Putar ulang" or "Putar")
	nextButton.Text = ({"Ke papan informasi", "Lanjut ke audio 3", "Ke papan latihan"})[activeClip]
	nextButton.Active = completed[activeClip]
	nextButton.AutoButtonColor = completed[activeClip]
	nextButton.BackgroundTransparency = completed[activeClip] and 0 or .55
	back.Visible = activeClip == 3
end
local function openAudio(index)
	hideAll()
	activeClip = index
	loadVersion += 1
	local version = loadVersion
	sound:Stop()
	loaded = false
	paused = false
	sound.SoundId = "rbxassetid://" .. clips[index].id
	fill.Size = UDim2.fromScale(completed[index] and 1 or 0, 1)
	status.Text = "Memuat audio…"
	audioPlayerMale.Visible = true
	level1Gui.Enabled = true
	overlay.Visible = true
	PlayerControl.Lock()
	refresh()
	task.spawn(function()
		local deadline = os.clock() + 20
		repeat task.wait(.1) until version ~= loadVersion or sound.IsLoaded or os.clock() >= deadline
		if version ~= loadVersion then return end
		loaded = sound.IsLoaded
		if loaded then
			sound.TimePosition = completed[index] and 0 or positions[index]
			status.Text = completed[index] and "Audio ini sudah selesai. Bisa diputar ulang." or "Tekan Putar untuk mendengarkan."
			if pendingPlay and audioPlayerMale.Visible then
				sound:Play()
				sound.TimePosition = completed[index] and 0 or positions[index]
				pendingPlay = false
			end
		else
			status.Text = "Audio belum siap. Tekan Coba lagi; periksa koneksi atau izin audio jika tetap gagal."
			play.Text = "Coba lagi"
		end
	end)
end
play.MouseButton1Click:Connect(function()
	if not sound.IsLoaded then openAudio(activeClip); pendingPlay = true; return end
	loaded = true
	if sound.IsPlaying then
		positions[activeClip] = sound.TimePosition
		sound:Pause(); paused = true
	elseif completed[activeClip] then
		sound.TimePosition = 0; sound:Play(); paused = false
	elseif paused then sound:Resume(); paused = false
	else sound:Play(); sound.TimePosition = positions[activeClip] end
	status.Text = sound.IsPlaying and "Dengarkan sampai selesai untuk melanjutkan." or "Dijeda. Tekan Putar untuk melanjutkan."
	refresh()
end)
sound.Ended:Connect(function()
	completed[activeClip] = true
	positions[activeClip] = 0
	paused = false
	status.Text = "Audio " .. activeClip .. " selesai. Silakan lanjut."
	fill.Size = UDim2.fromScale(1,1)
	refresh()
end)
RunService.RenderStepped:Connect(function()
	if not audioPlayerMale.Visible then return end
	local duration = sound.TimeLength
	local position = sound.TimePosition
	if completed[activeClip] and not sound.IsPlaying and not paused then position = duration end
	local function clock(seconds) return string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60)) end
	timeLabel.Text = clock(position) .. " / " .. clock(duration)
	if duration > 0 then fill.Size = UDim2.fromScale(completed[activeClip] and not sound.IsPlaying and not paused and 1 or math.clamp(position / duration,0,1),1) end
end)
close.MouseButton1Click:Connect(closeAudio)
back.MouseButton1Click:Connect(function() openAudio(2) end)
nextButton.MouseButton1Click:Connect(function()
	if not completed[activeClip] then return end
	if activeClip == 2 then openAudio(3) else closeAudio() end
end)
introFrame.mulaibtn.MouseButton1Click:Connect(function() openAudio(1) end)
introFrame:WaitForChild("close").MouseButton1Click:Connect(closeAudio)
local function tutor1()
	hideAll()
	level1Gui.Enabled = true
	overlay.Visible = true
	GuiAnimation.Show(introFrame)
	PlayerControl.Lock()
end
local function tutor2()
	if not completed[1] or not infoVisited then
		openAudio(1)
		status.Text = completed[1] and "Kunjungi papan informasi sebelum Tutor 2." or "Selesaikan audio 1 di Tutor 1 dahulu."
		return
	end
	openAudio(completed[2] and 3 or 2)
end
-- Resolve only the two nearby humanoids, using entrance-to-tutors direction for left/right.
-- No permanent NPC names/positions are changed. Ambiguous discovery leaves the baseline prompt available.
local candidates = {}
for _, item in ipairs(workspace:GetDescendants()) do
	if item:IsA("Humanoid") and item.Parent:IsA("Model") and not Players:GetPlayerFromCharacter(item.Parent) then
		local part = item.Parent:FindFirstChild("HumanoidRootPart") or item.Parent:FindFirstChild("Head")
		if part and part:IsA("BasePart") and (part.Position - spacePart.Position).Magnitude < 25 then
			table.insert(candidates, {model=item.Parent, part=part})
		end
	end
end
if #candidates == 2 then
	local midpoint = (candidates[1].part.Position + candidates[2].part.Position) / 2
	local spawn, distance
	for _, item in ipairs(workspace:GetDescendants()) do
		if item:IsA("SpawnLocation") then
			local d = (item.Position - midpoint).Magnitude
			if not distance or d < distance then spawn = item; distance = d end
		end
	end
	if spawn then
		local forward = midpoint - spawn.Position
		forward = Vector3.new(forward.X,0,forward.Z)
		if forward.Magnitude > .1 then
			local right = forward.Unit:Cross(Vector3.yAxis)
			table.sort(candidates, function(a,b) return a.part.Position:Dot(right) < b.part.Position:Dot(right) end)
			for index, npc in ipairs(candidates) do
				local npcPrompt = Instance.new("ProximityPrompt")
				npcPrompt.Name = "L1TutorAudioPrompt"
				npcPrompt.ActionText = "Bicara"
				npcPrompt.ObjectText = "Tutor " .. index
				npcPrompt.HoldDuration = 1
				npcPrompt.MaxActivationDistance = 10
				npcPrompt.RequiresLineOfSight = false
				npcPrompt.Parent = npc.part
				local openTutor = index == 1 and tutor1 or tutor2
				npcPrompt.Triggered:Connect(function(who) if who == player then openTutor() end end)
				print("L1 audio Tutor", index, npc.model:GetFullName(), npc.part.Position)
			end
			prompt.Enabled = false
		end
	end
else warn("L1 audio: expected two NPCs near Space1Answers; found", #candidates) end
prompt.Triggered:Connect(function(who) if who == player then tutor1() end end)

-- ===== Papan Informasi (L1_PapanInformasi) =====
local papanInfoFrame = level1Gui:WaitForChild("papanInfoFrame")
local papanPrompt = workspace:WaitForChild("Level1Development"):WaitForChild("L1_PapanInformasi"):WaitForChild("Animation 2"):WaitForChild("ProximityPrompt")

papanPrompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		if not completed[1] then
			openAudio(1)
			status.Text = "Selesaikan audio 1 dahulu sebelum membuka papan informasi."
			return
		end
		hideAll()
		infoVisited = true
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
		if not (completed[1] and completed[2] and completed[3]) then
			local remaining = not completed[1] and 1 or (not completed[2] and 2 or 3)
			if remaining > 1 and not infoVisited then
				openAudio(1)
				status.Text = "Kunjungi papan informasi setelah audio 1, lalu temui Tutor 2."
			else
				openAudio(remaining)
				status.Text = "Latihan terbuka setelah ketiga audio selesai. Selesaikan audio " .. remaining .. " dahulu."
			end
			return
		end
		hideAll()
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
