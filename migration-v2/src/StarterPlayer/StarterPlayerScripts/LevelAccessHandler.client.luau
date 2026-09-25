local Players = game:GetService("Players")
local player = Players.LocalPlayer

local space2Wall = workspace:WaitForChild("Space2DoorBlock")
local space2Wall2 = workspace:WaitForChild("Space2DoorBlock2")
local space3Wall = workspace:WaitForChild("Space3DoorBlock")
local space3Wall2 = workspace:WaitForChild("Space3DoorBlock2")
local apresiasiWall = workspace:WaitForChild("ApresiasiDoorBlock")
local apresiasiWall2 = workspace:WaitForChild("ApresiasiDoorBlock2")

local space1Answers = workspace:WaitForChild("Space1Answers")	
local space2Answers = workspace:WaitForChild("Space2Answers")
local space3Answers = workspace:WaitForChild("Space3Answers")

local function updateAccess()

	local progress = player.leaderstats.LevelProgress.Value

	-- Space 2
	if progress >= 2 then
		space2Wall.Transparency = 1
		space2Wall.CanCollide = false
		space2Wall2.Transparency = 1
		space2Wall2.CanCollide = false
	else
		space2Wall.Transparency = 0.8
		space2Wall.CanCollide = true
		space2Wall2.Transparency = 0.8
		space2Wall2.CanCollide = true
	end

	-- Space 3
	if progress >= 3 then
		space3Wall.Transparency = 1
		space3Wall.CanCollide = false
		space3Wall2.Transparency = 1
		space3Wall2.CanCollide = false
	else
		space3Wall.Transparency = 0.8
		space3Wall.CanCollide = true
		space3Wall2.Transparency = 0.8
		space3Wall2.CanCollide = true
	end

	-- Apresiasi
	if progress >= 4 then
		apresiasiWall.Transparency = 1
		apresiasiWall.CanCollide = false
		apresiasiWall2.Transparency = 1
		apresiasiWall2.CanCollide = false
	else
		apresiasiWall.Transparency = 0.8
		apresiasiWall.CanCollide = true
		apresiasiWall2.Transparency = 0.8
		apresiasiWall2.CanCollide = true
	end
	
	-- ================= SPACE 1 ANSWERS =================
	if progress >= 2 then
		space1Answers.Transparency = 1
		space1Answers.CanCollide = false

		-- Jika ada ProximityPrompt di dalamnya
		local prompt = space1Answers:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Enabled = false
		end
	else
		space1Answers.Transparency = 0
		space1Answers.CanCollide = true

		local prompt = space1Answers:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Enabled = true
		end
	end
	
	-- ================= SPACE 2 ANSWERS =================
	if progress >= 3 then
		space2Answers.Transparency = 1
		space2Answers.CanCollide = false

		-- Jika ada ProximityPrompt di dalamnya
		local prompt = space2Answers:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Enabled = false
		end
	else
		space2Answers.Transparency = 0
		space2Answers.CanCollide = true

		local prompt = space2Answers:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Enabled = true
		end
	end
	
	
	-- ================= SPACE 3 ANSWERS =================
	
	if progress >= 4 then
		space3Answers.Transparency = 1
		space3Answers.CanCollide = false

		-- Jika ada ProximityPrompt di dalamnya
		local prompt = space3Answers:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Enabled = false
		end
	else
		space3Answers.Transparency = 0
		space3Answers.CanCollide = true

		local prompt = space3Answers:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Enabled = true
		end
	end
	
	
	
	

end



-- Tunggu leaderstats
player:WaitForChild("leaderstats"):WaitForChild("LevelProgress")

updateAccess()

player.leaderstats.LevelProgress.Changed:Connect(function()
	updateAccess()
end)

