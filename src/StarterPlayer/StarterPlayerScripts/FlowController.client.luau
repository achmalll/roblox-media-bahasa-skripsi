local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local flowGui = playerGui:WaitForChild("FlowGui")

local maps = flowGui:WaitForChild("mapsFrame")
local space1 = flowGui:WaitForChild("space1Frame")
local space2 = flowGui:WaitForChild("space2Frame")
local space3 = flowGui:WaitForChild("space3Frame")
local space4 = flowGui:WaitForChild("hall4Frame")

-- Module
local GuiAnimation = require(player.PlayerScripts:WaitForChild("GuiAnimationHandler"))
local PlayerControl = require(player.PlayerScripts:WaitForChild("PlayerControlHandler"))

-- =========================
-- Ambil ProximityPrompt dengan aman
-- =========================

local halamanDepan = workspace:WaitForChild("Halaman depan")
local papanModel = halamanDepan:WaitForChild("papanInformasi")

-- cari prompt di seluruh isi model
local prompt = papanModel:WaitForChild("ProximityPrompt",10)

if not prompt then
	prompt = papanModel:FindFirstChildWhichIsA("ProximityPrompt", true)
end

if not prompt then
	warn("ProximityPrompt tidak ditemukan!")
	return
end


-- =========================
-- Function Helper
-- =========================

local function hideAll()

	maps.Visible = false
	space1.Visible = false
	space2.Visible = false
	space3.Visible = false
	space4.Visible = false

end


local function openFlow()

	flowGui.Enabled = true
	hideAll()

	GuiAnimation.Show(maps)

	PlayerControl.Lock()

end


local function closeFlow()

	PlayerControl.Unlock()
	flowGui.Enabled = false

end


-- =========================
-- Trigger dari papan
-- =========================

prompt.Triggered:Connect(function(triggeredPlayer)

	if triggeredPlayer == player then
		openFlow()
	end

end)


-- =========================
-- NAVIGASI MAP
-- =========================

maps.next.MouseButton1Click:Connect(function()

	hideAll()
	space1.Visible = true
	PlayerControl.Lock()

end)

maps.close.MouseButton1Click:Connect(closeFlow)


-- =========================
-- NAVIGASI SPACE 1
-- =========================

space1.next.MouseButton1Click:Connect(function()

	hideAll()
	space2.Visible = true
	PlayerControl.Lock()

end)

space1.prev.MouseButton1Click:Connect(function()

	hideAll()
	maps.Visible = true
	PlayerControl.Lock()

end)

space1.close.MouseButton1Click:Connect(closeFlow)


-- =========================
-- NAVIGASI SPACE 2
-- =========================

space2.next.MouseButton1Click:Connect(function()

	hideAll()
	space3.Visible = true
	PlayerControl.Lock()

end)

space2.prev.MouseButton1Click:Connect(function()

	hideAll()
	space1.Visible = true
	PlayerControl.Lock()

end)

space2.close.MouseButton1Click:Connect(closeFlow)


-- =========================
-- NAVIGASI SPACE 3
-- =========================
space3.next.MouseButton1Click:Connect(function()

	hideAll()
	space4.Visible = true
	PlayerControl.Lock()

end)

space3.prev.MouseButton1Click:Connect(function()

	hideAll()
	space2.Visible = true
	PlayerControl.Lock()

end)

space3.close.MouseButton1Click:Connect(closeFlow)

-- =========================
-- NAVIGASI SPACE 4
-- =========================

space4.prev.MouseButton1Click:Connect(function()

	hideAll()
	space3.Visible = true
	PlayerControl.Lock()

end)

space4.close.MouseButton1Click:Connect(closeFlow)