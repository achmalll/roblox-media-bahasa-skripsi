-- Level 2: three interaction shells only; no score or learning progress changes.
task.spawn(function()
	local Players = game:GetService("Players")
	local Input = game:GetService("UserInputService")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local folder = workspace:WaitForChild("Level2Development", 30)
	if not folder then warn("[L2 Shell] Level2Development missing"); return end
	local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerControlHandler"))
	local gui = Instance.new("ScreenGui")
	gui.Name = "Level2InteractionShells"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 50
	gui.Enabled = false
	gui.Parent = playerGui
	local overlay = Instance.new("TextButton")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.4
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Modal = true
	overlay.Parent = gui
	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.82, 0.78)
	panel.BackgroundColor3 = Color3.fromRGB(244, 221, 205)
	panel.BorderSizePixel = 0
	panel.Parent = overlay
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(1000, 650)
	constraint.Parent = panel
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = panel
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(209, 156, 116)
	stroke.Thickness = 3
	stroke.Parent = panel
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(24, 18)
	title.Size = UDim2.new(1, -48, 0, 88)
	title.TextSize = 28
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = Color3.fromRGB(71, 32, 3)
	title.TextWrapped = true
	title.Parent = panel
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Position = UDim2.fromOffset(24, 116)
	content.Size = UDim2.new(1, -48, 1, -204)
	content.Parent = panel
	local close = Instance.new("TextButton")
	close.AnchorPoint = Vector2.new(0.5, 1)
	close.Position = UDim2.new(0.5, 0, 1, -20)
	close.Size = UDim2.new(0.55, 0, 0, 52)
	close.Text = "Tutup"
	close.TextSize = 24
	close.Font = Enum.Font.GothamBold
	close.TextColor3 = Color3.new(1, 1, 1)
	close.BackgroundColor3 = Color3.fromRGB(153, 59, 42)
	close.Parent = panel
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 10)
	closeCorner.Parent = close
	local prompts = {}
	local function dismiss()
		if not gui.Enabled then return end
		gui.Enabled = false
		controls.Unlock()
		for _, prompt in ipairs(prompts) do prompt.Enabled = true end
	end
	close.Activated:Connect(dismiss)
	Input.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Escape and gui.Enabled then dismiss() end
	end)
	player.CharacterAdded:Connect(dismiss)
	local function watchCharacter(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then humanoid.Died:Connect(dismiss) end
	end
	player.CharacterAdded:Connect(watchCharacter)
	if player.Character then task.spawn(watchCharacter, player.Character) end
	local stations = {
		{ model = "L2_PapanBukti", title = "Latihan 1 — Bukti Teks", action = "Buka latihan" },
		{ model = "L2_PapanPasangan", title = "Latihan 2 — Simpulan dan Bukti", action = "Buka latihan" },
		{ model = "L2_KiosEvaluasi", title = "Evaluasi Level 2", action = "Buka evaluasi" },
	}
	for _, station in ipairs(stations) do
		local model = folder:WaitForChild(station.model, 15)
		if not model or not model:IsA("Model") then warn("[L2 Shell] Missing model " .. station.model); continue end
		local part = model:FindFirstChildWhichIsA("BasePart", true)
		if not part then warn("[L2 Shell] No BasePart " .. station.model); continue end
		-- Attachment is centered on the station, independent of which part is first.
		local bounds = model:GetBoundingBox()
		local attachment = Instance.new("Attachment")
		attachment.Name = "L2InteractionAnchor"
		attachment.Position = part.CFrame:PointToObjectSpace(bounds.Position)
		attachment.Parent = part
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "L2ShellPrompt"
		prompt.ActionText = station.action
		prompt.ObjectText = station.title
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 1
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = attachment
		table.insert(prompts, prompt)
		prompt.Triggered:Connect(function(who)
			if who and who ~= player then return end
			if gui.Enabled then return end
			title.Text = station.title
			gui.Enabled = true
			controls.Lock()
			for _, other in ipairs(prompts) do other.Enabled = false end
		end)
	end
	print("[L2 Shell] Ready: " .. #prompts .. " prompts; empty modals only")
end)


-- Existing Level 2 flow below remains intact.
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