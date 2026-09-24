local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local updateEvent = ReplicatedStorage:WaitForChild("UpdateLevel2Score")
local updateProgressEvent = ReplicatedStorage:WaitForChild("UpdateLevelProgress")


local PlayerControl = require(player.PlayerScripts:WaitForChild("PlayerControlHandler"))

local level2Gui = player.PlayerGui:WaitForChild("Level2Gui")
local quizFrame = level2Gui:WaitForChild("quizFrame")

local newsFrame = level2Gui:WaitForChild("NewsScrollingFrame")

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
		question = "1. Berdasarkan teks, bagaimana perbedaan cara kerja sistem operasi Android dan Windows pada Cloud AI Pad?",
		options = {
			"A. Android dijalankan secara lokal, sedangkan Windows dijalankan melalui cloud",
			"B. Android dan Windows sama-sama dijalankan melalui cloud",
			"C. Windows dijalankan secara lokal, sedangkan Android melalui cloud",
			"D. Keduanya dijalankan secara native di perangkat tablet",
			"E. Android dan Windows hanya dapat digunakan secara bergantian melalui restart"
		},
		answer = 1
	},
	{
		question = "2. Berdasarkan teks, mengapa pendekatan dual sistem operasi yang diterapkan pada Cloud AI Pad dianggap sebagai inovasi yang signifikan dalam industri tablet saat ini?",
		options = {
			"A. Karena tablet Cloud AI Pad merupakan satu-satunya perangkat yang pernah menggunakan sistem operasi Android",
			"B. Karena penggunaan dua sistem operasi dalam satu perangkat masih jarang ditemui dan mampu menjawab kebutuhan fleksibilitas sekaligus produktivitas pengguna",
			"C. Karena Cloud AI Pad menggantikan sistem operasi Windows dengan sistem operasi buatan China secara penuh",
			"D. Karena tablet ini menggunakan satu sistem operasi dengan dua antarmuka yang berbeda secara tampilan",
			"E. Karena Cloud AI Pad menjalankan Linux dan Windows secara bersamaan untuk pertama kalinya"
		},
		answer = 2
	},
	{
		question = "3. Apa keunggulan penggunaan konsep dual sistem operasi pada Cloud AI Pad dibandingkan tablet pada umumnya?",
		options = {
			"A. Tablet dapat menjalankan semua sistem operasi",
			"B. Pengguna dapat memanfaatkan fleksibilitas Android dan produktivitas Windows dalam satu perangkat",
			"C. Tablet dapat berfungsi tanpa perangkat keras tambahan ",
			"D. Sistem operasi tidak lagi memerlukan pembaruan perangkat lunak",
			"E. Semua aplikasi dapat berjalan tanpa koneksi internet"
		},
		answer = 2
	},
	{
		question = "4. Berdasarkan teks, Cloud AI Pad menjalankan Android secara lokal dan Windows melalui cloud. Analisislah implikasi dari pendekatan ini terhadap ketergantungan pengguna pada koneksi internet dalam penggunaan perangkat!",
		options = {
			"A. Pengguna tidak membutuhkan koneksi internet sama sekali karena kedua sistem berjalan secara lokal",
			"B. Pengguna sepenuhnya bergantung pada internet karena kedua sistem berjalan melalui cloud",
			"C. Penggunaan Android tidak memerlukan internet, namun akses Windows bergantung pada ketersediaan koneksi cloud ",
			"D. Koneksi internet hanya diperlukan saat memperbarui sistem operasi Android",
			"E. Ketergantungan pada internet tidak relevan karena fitur AI menggantikan fungsi koneksi"
		},
		answer = 3
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
			"\n\nKamu telah memahami materi dengan baik.\n\nSilakan lanjut ke level 3 ya!"

		updateProgressEvent:FireServer(3)
		updateEvent:FireServer(score)

	else

		resultLulus.Visible = false
		resultUlang.Visible = true

		ulangTitle.Text = "KAMU PERLU MENGULANG :("

		ulangScore.Text = "Skor Anda: " .. score .. " / 100"

		ulangDetail.Text =
			"Jawaban Benar: " .. correctAnswers ..
			"\nJawaban Salah: " .. wrongAnswers ..
			"\n\nSilakan baca kembali berita dan coba lagi ya"
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
	level2Gui.Enabled = false


	print("Menuju Level Berikutnya")

end)

retryButton.MouseButton1Click:Connect(function()

	resultBackground.Visible = false
	quizFrame.Visible = false

	-- kembali ke audio player
	newsFrame.Visible = true

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