local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local updateEvent = ReplicatedStorage:WaitForChild("UpdateLevel3Score")
local updateProgressEvent = ReplicatedStorage:WaitForChild("UpdateLevelProgress")


local PlayerControl = require(player.PlayerScripts:WaitForChild("PlayerControlHandler"))


local level3Gui = player.PlayerGui:WaitForChild("Level3Gui")
local quizFrame = level3Gui:WaitForChild("quizFrame")

local AbstractFrame = level3Gui:WaitForChild("AbstractFrame")

local questionLabel = quizFrame:WaitForChild("QuestionLabel")
local feedbackLabel = quizFrame:WaitForChild("FeedbackLabel")

local resultBackground = quizFrame:WaitForChild("ResultBackground")

local resultLulus = resultBackground:WaitForChild("ResultLulus")
local lulusTitle = resultLulus:WaitForChild("TitleLabel")
local lulusScore = resultLulus:WaitForChild("ScoreLabel")
local lulusDetail = resultLulus:WaitForChild("DetailLabel")
local nextButton = resultLulus:WaitForChild("NextButton")

local resultUlang = resultBackground:WaitForChild("ResultUlang")
local ulangTitle = resultUlang:WaitForChild("TitleLabel")
local ulangScore = resultUlang:WaitForChild("ScoreLabel")
local ulangDetail = resultUlang:WaitForChild("DetailLabel")
local retryButton = resultUlang:WaitForChild("RetryButton")

local isAnswering = false

local buttons = {
	quizFrame:WaitForChild("OptionA"),
	quizFrame:WaitForChild("OptionB"),
	quizFrame:WaitForChild("OptionC"),
	quizFrame:WaitForChild("OptionD"),
	quizFrame:WaitForChild("OptionE"),
}

--------------------------------------------------

local questions = {
	{
		question = "1. Menurut abstrak, faktor utama yang mendorong pergeseran dari model process-centric menuju data-centric adalah ...",
		options = {
			"A. Meningkatnya kebutuhan antarmuka grafis pada sistem operasi",
			"B. Perkembangan bahasa pemrograman tingkat tinggi",
			"C. Tuntutan kompatibilitas perangkat lunak lintas platform",
			"D. Tren perangkat keras seperti peningkatan kecepatan interkoneksi dan penyimpanan persisten",
			"E. Dominasi sistem operasi berbasis mobile"
		},
		answer = 4
	},
	{
		question = "2. Keunggulan utama pendekatan data-centric yang diperkenalkan melalui sistem Twizzler dibandingkan pendekatan tradisional adalah ...",
		options = {
			"A. Penggunaan kernel yang lebih kompleks untuk mengatur data",
			"B. Penggunaan model RPC yang lebih ketat dan terstruktur",
			"C. Penghapusan sepenuhnya peran kernel dalam sistem operasi",
			"D. Ketergantungan penuh pada teknologi virtualisasi",
			"E. Penyederhanaan jalur akses data dan pengurangan kebutuhan serialisasi"
		},
		answer = 5
	},
	{
		question = "3. Berdasarkan isi abstrak, mengapa model pemrograman tradisional dianggap kurang sesuai dengan perkembangan perangkat keras modern?",
		options = {
			"A. Karena model tradisional menimbulkan overhead dan keterbatasan yang menghambat pemanfaatan perangkat keras modern secara optimal",
			"B. Karena perangkat keras modern tidak lagi membutuhkan sistem operasi",
			"C. Karena perangkat keras modern hanya mendukung sistem operasi berbasis cloud",
			"D. Karena semua aplikasi modern menggunakan bahasa pemrograman baru",
			"E. Karena sistem operasi modern tidak memerlukan kernel"
		},
		answer = 1
	},
	{
		question = "4. Pendekatan data-centric yang diimplementasikan dalam Twizzler terbukti meningkatkan performa melalui penyederhanaan lapisan perangkat lunak. Evaluasilah apakah pendekatan ini layak dijadikan standar baru dalam pengembangan sistem operasi modern, berdasarkan argumen yang disajikan dalam abstrak!",
		options = {
			"A. Tidak layak, karena Twizzler hanya diuji pada studi kasus terbatas dan belum terbukti skalabilitasnya secara luas",
			"B. Layak, karena pendekatan data-centric mengurangi keterlibatan kernel, menghilangkan serialisasi, dan terbukti meningkatkan performa pada berbagai kasus yang diuji",
			"C. Tidak layak, karena model process-centric masih lebih andal untuk sistem operasi yang melayani pengguna umum",
			"D. Layak, namun hanya untuk sistem operasi berbasis cloud dan tidak relevan untuk perangkat lokal",
			"E. Tidak layak, karena abstrak tidak menyebutkan perbandingan langsung dengan sistem operasi komersial yang ada"
		},
		answer = 2
	}
}

--------------------------------------------------

local currentQuestion = 1
local score = 0

--------------------------------------------------

local function resetButtons()
	for _, button in ipairs(buttons) do
		button.BackgroundColor3 = Color3.fromRGB(232,210,196)
		button.Active = true
	end
end

--------------------------------------------------

local function loadQuestion()

	resetButtons()
	feedbackLabel.Text = ""

	local q = questions[currentQuestion]
	questionLabel.Text = q.question

	for i, button in ipairs(buttons) do
		button.Text = q.options[i]
	end
end

--------------------------------------------------

local function finishQuiz()

	resultBackground.Visible = true

	local totalQuestions = #questions
	local correctAnswers = score / 25
	local wrongAnswers = totalQuestions - correctAnswers

	if score >= 75 then

		resultLulus.Visible = true
		resultUlang.Visible = false
		
		lulusTitle.Text = "SELAMAT!"

		resultLulus.ScoreLabel.Text = "Skor Anda: " .. score .. " / 100"
		lulusDetail.Text =
			"Jawaban Benar: " .. correctAnswers ..
			"\nJawaban Salah: " .. wrongAnswers ..
			"\n\nKamu telah memahami materi dengan baik.\n\nSilakan lanjut ke gedung tengah untuk mendapatkan hadiah!" 

		updateProgressEvent:FireServer(4)

		updateEvent:FireServer(score)

	else

		resultLulus.Visible = false
		resultUlang.Visible = true

		ulangTitle.Text = "KAMU PERLU MENGULANG :("

		ulangScore.Text = "Skor Anda: " .. score .. " / 100"

		ulangDetail.Text =
			"Jawaban Benar: " .. correctAnswers ..
			"\nJawaban Salah: " .. wrongAnswers ..
			"\n\nSilakan baca kembali dan coba lagi ya"
	end
end

--------------------------------------------------

local function checkAnswer(selectedIndex)
	
	if isAnswering then return end
	isAnswering = true

	local correctIndex = questions[currentQuestion].answer

	for _, button in ipairs(buttons) do
		button.Active = false
	end

	if selectedIndex == correctIndex then
		score += 25
		feedbackLabel.Text = "Jawaban Benar"
		feedbackLabel.BackgroundColor3 = Color3.fromRGB(120, 166, 33)
		buttons[selectedIndex].BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		feedbackLabel.Text = "Jawaban Salah"
		feedbackLabel.BackgroundColor3 = Color3.fromRGB(211, 60, 49)
		buttons[selectedIndex].BackgroundColor3 = Color3.fromRGB(255,0,0)
	end

	task.wait(3)

	feedbackLabel.BackgroundColor3 = Color3.fromRGB(244, 221, 205)

	currentQuestion += 1

	if currentQuestion > #questions then
		finishQuiz()
	else
		loadQuestion()
	end
	
	isAnswering = false
end

nextButton.MouseButton1Click:Connect(function()
	PlayerControl.Unlock()
	resultBackground.Visible = false
	quizFrame.Visible = false
	level3Gui.Enabled = false


	print("Menuju Level Berikutnya")

end)

retryButton.MouseButton1Click:Connect(function()

	resultBackground.Visible = false
	quizFrame.Visible = false

	AbstractFrame.Visible = true

end)

--------------------------------------------------

for index, button in ipairs(buttons) do
	button.MouseButton1Click:Connect(function()
		checkAnswer(index)
	end)
end

--------------------------------------------------

quizFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if quizFrame.Visible then
		currentQuestion = 1
		score = 0
		loadQuestion()
	end
end)