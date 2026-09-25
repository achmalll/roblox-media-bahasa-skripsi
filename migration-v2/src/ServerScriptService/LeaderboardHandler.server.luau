game.Players.PlayerAdded:Connect(function(player)

	--------------------------------------------------
	-- LEADERBOARD (YANG TAMPIL DI TAB)
	--------------------------------------------------

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local totalScore = Instance.new("IntValue")
	totalScore.Name = "TotalScore"
	totalScore.Value = 0
	totalScore.Parent = leaderstats

	local levelProgress = Instance.new("IntValue")
	levelProgress.Name = "LevelProgress"
	levelProgress.Value = 1
	levelProgress.Parent = leaderstats


	--------------------------------------------------
	-- FOLDER PENYIMPANAN SCORE PER LEVEL
	--------------------------------------------------

	local scoreFolder = Instance.new("Folder")
	scoreFolder.Name = "PlayerScores"
	scoreFolder.Parent = player

	local level1Score = Instance.new("IntValue")
	level1Score.Name = "Level1Score"
	level1Score.Value = 0
	level1Score.Parent = scoreFolder

	local level2Score = Instance.new("IntValue")
	level2Score.Name = "Level2Score"
	level2Score.Value = 0
	level2Score.Parent = scoreFolder

	local level3Score = Instance.new("IntValue")
	level3Score.Name = "Level3Score"
	level3Score.Value = 0
	level3Score.Parent = scoreFolder


	--------------------------------------------------
	-- AUTO UPDATE TOTAL SCORE
	--------------------------------------------------

	local function updateTotal()
		totalScore.Value =
			level1Score.Value +
			level2Score.Value +
			level3Score.Value
	end

	level1Score.Changed:Connect(updateTotal)
	level2Score.Changed:Connect(updateTotal)
	level3Score.Changed:Connect(updateTotal)

end)