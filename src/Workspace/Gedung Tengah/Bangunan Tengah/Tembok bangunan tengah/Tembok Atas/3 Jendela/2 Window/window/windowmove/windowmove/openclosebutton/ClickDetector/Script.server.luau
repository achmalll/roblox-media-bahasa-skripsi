local model = script.Parent.Parent.Parent.Parent
local windowParts = script.Parent.Parent.Parent.Parent:GetDescendants() 
local click = script.Parent

local lock = script.Parent.Parent.Parent.Parent.Parent["inner frame"].lock.button.ClickDetector

local currentlyopen = false

-- sounds
local open = script.Parent.Parent.Parent["open sound"]
local close = script.Parent.Parent.Parent["close sound"]

local TweenService = game:GetService("TweenService")

local tweeninfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

-- Tables to store tweens
local openTweens = {}
local closedTweens = {}

for _, part in pairs(windowParts) do
	if part:IsA("BasePart") then  -- Ensure it's a part that can be tweened
		local open = {}
		local closed = {}

		open.CFrame = part.CFrame * CFrame.new(0, 2.3, 0)  -- Move the part up
		closed.CFrame = part.CFrame  -- Keep the original position

		openTweens[part] = TweenService:Create(part, tweeninfo, open)
		closedTweens[part] = TweenService:Create(part, tweeninfo, closed)
	end
end

click.MouseClick:Connect(function()
	if currentlyopen == false then
		for _, tween in pairs(openTweens) do
			tween:Play()
		end
		open:Play()
		currentlyopen = true
		lock.MaxActivationDistance = 0
	else
		for _, tween in pairs(closedTweens) do
			tween:Play()
		end
		close:Play()
		currentlyopen = false
		lock.MaxActivationDistance = 32
	end

end)
