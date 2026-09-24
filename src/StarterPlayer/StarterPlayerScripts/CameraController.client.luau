local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tunggu sampai character siap
player.CharacterAdded:Connect(function()
	player.CameraMinZoomDistance = 5   -- jarak minimal zoom (dekat)
	player.CameraMaxZoomDistance = 20  -- jarak maksimal zoom (jauh)
end)

-- Set juga saat pertama kali join
player.CameraMinZoomDistance = 5
player.CameraMaxZoomDistance = 20

