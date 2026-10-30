-- Run once in Studio Command Bar in Edit mode, then Save WORKING.
assert(not game:GetService("RunService"):IsRunning() and game:GetService("StudioTestService").EditModeActive, "Stop Play first")
local kiosk = workspace:WaitForChild("Level1Development"):WaitForChild("L1_KiosEvaluasi")
game:GetService("ChangeHistoryService"):SetWaypoint("Before L1 kiosk stability fix")
local total, fixed = 0, 0
for _, part in ipairs(kiosk:GetDescendants()) do
	if part:IsA("BasePart") then
		total += 1
		if not part.Anchored then part.Anchored = true; fixed += 1 end
	end
end
workspace:WaitForChild("Space1Answers"):WaitForChild("ProximityPrompt").Enabled = false
game:GetService("ChangeHistoryService"):SetWaypoint("L1 kiosk anchored and shared tutor prompt retired")
print("L1 fix: kiosk parts", total, "newly anchored", fixed, "shared prompt disabled")
