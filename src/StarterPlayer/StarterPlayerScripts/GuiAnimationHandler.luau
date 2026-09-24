local TweenService = game:GetService("TweenService")

local GuiAnimation = {}

local DEFAULT_POSITION = UDim2.new(0.5, 0, 0.5, 0)
local HIDDEN_POSITION = UDim2.new(0.5, 0, 1.2, 0)

function GuiAnimation.Show(frame)

	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = HIDDEN_POSITION
	frame.Visible = true

	local tween = TweenService:Create(
		frame,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{Position = DEFAULT_POSITION}
	)

	tween:Play()
end

function GuiAnimation.Hide(frame, callback)

	local tween = TweenService:Create(
		frame,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{Position = HIDDEN_POSITION}
	)

	tween:Play()

	tween.Completed:Connect(function()
		frame.Visible = false
		if callback then
			callback()
		end
	end)
end

return GuiAnimation