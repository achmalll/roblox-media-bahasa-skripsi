local windowbutton = script.Parent.Parent.Parent.Parent.Parent.windowmove.windowmove["open/closebutton"].ClickDetector
local click = script.Parent

local sound = script.Parent.Parent.Parent.click

local currentlylocked = false

-- this function wont work when window is open
click.MouseClick:Connect(function()
	-- toggle 
	if currentlylocked == false then
		currentlylocked = true
		windowbutton.MaxActivationDistance = 0
		sound:Play()
	else
		currentlylocked = false
		windowbutton.MaxActivationDistance = 32
		sound:Play()
	end
end)