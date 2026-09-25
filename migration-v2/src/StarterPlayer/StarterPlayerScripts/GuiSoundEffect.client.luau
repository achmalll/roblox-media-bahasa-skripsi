local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local clickSoundTemplate = ReplicatedStorage:WaitForChild("ButtonClickSound")

-- function kasih sound ke button
local function setupButton(button)

	-- clone sound ke button
	local sound = clickSoundTemplate:Clone()
	sound.Parent = button

	button.MouseButton1Click:Connect(function()
		sound:Play()
	end)

end

-- scan semua GUI
local function scanGui(gui)

	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextButton") or obj:IsA("ImageButton") then
			setupButton(obj)
		end
	end

end

-- jalankan awal
for _, gui in ipairs(playerGui:GetChildren()) do
	scanGui(gui)
end

-- jika ada GUI baru muncul
playerGui.ChildAdded:Connect(function(gui)
	task.wait(0.5)
	scanGui(gui)
end)