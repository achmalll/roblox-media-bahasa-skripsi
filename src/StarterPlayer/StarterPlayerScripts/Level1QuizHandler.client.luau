local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local player = Players.LocalPlayer
local updateEvent = ReplicatedStorage:WaitForChild("UpdateLevel1Score")
local updateProgressEvent = ReplicatedStorage:WaitForChild("UpdateLevelProgress")

local PlayerControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerControlHandler"))

local level1Gui = player.PlayerGui:WaitForChild("Level1Gui")
local quizFrame = level1Gui:WaitForChild("quizFrame")
local audioPlayerMale = level1Gui:WaitForChild("audioPlayerMale")
local audioPlayerFemale = level1Gui:WaitForChild("audioPlayerFemale")

local questionLabel = quizFrame:WaitForChild("QuestionLabel")
local feedbackLabel = quizFrame:WaitForChild("FeedbackLabel")

--Script Baru
local resultBackground = quizFrame:WaitForChild("ResultBackground")
local audioChoose = level1Gui:WaitForChild("audioChoose")

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

local questions = {
	{
		question = "1. Berdasarkan narasi audio yang disampaikan, sistem operasi dapat diartikan sebagai …",
		options = {
			"A. Perangkat keras utama yang berfungsi menjalankan aplikasi",
			"B. Perangkat lunak yang berfungsi mengelola sumber daya komputer",
			"C. Program tambahan yang digunakan untuk mempercepat kinerja Komputer",
			"D. Sistem jaringan yang menghubungkan komputer dengan internet",
			"E. Media penyimpanan data yang digunakan oleh pengguna"
		},
		answer = 2
	},
	{
		question = "2. Salah satu peran utama sistem operasi menurut narasi audio adalah …",
		options = {
			"A. Menggantikan fungsi perangkat keras komputer",
			"B. Menyimpan seluruh data pengguna secara permanen",
			"C. Menjadi penghubung antara pengguna dan aplikasi",
			"D. Mengendalikan jaringan internet secara langsung",
			"E. Menjalankan aplikasi tanpa bantuan perangkat keras"
		},
		answer = 3
	},
	{
		question = "3. Implementasi nyata dari pemahaman fungsi sistem operasi dalam mengelola sumber daya komputer secara optimal adalah …",
		options = {
			"A. Mendesain ulang perangkat keras komputer agar seluruh aplikasi berjalan tanpa sistem operasi",
			"B. Mengatur alokasi prosesor dan memori agar aplikasi dan sistem dapat bekerja secara terpadu",
			"C. Menghubungkan komputer ke jaringan internet agar semua perangkat lunak dapat diperbarui secara otomatis",
			"D. Menambahkan perangkat penyimpanan eksternal untuk memperbesar kapasitas data pengguna",
			"E. Menginstal sebanyak mungkin aplikasi agar kinerja komputer meningkat secara maksimal"
		},
		answer = 2
	},
	{
		question = "4. Dalam narasi audio disebutkan bahwa sistem operasi berperan sebagai penghubung antara pengguna dan aplikasi. Apa yang akan terjadi pada sebuah sistem komputer apabila sistem operasi tidak mampu menjalankan peran tersebut dengan baik!",
		options = {
			"A. Aplikasi akan berjalan lebih cepat karena tidak ada perantara",
			"B. Pengguna dapat langsung mengakses perangkat keras tanpa hambatan",
			"C. Perangkat keras akan meningkatkan kinerjanya secara mandiri",
			"D. Sistem operasi akan digantikan secara otomatis oleh aplikasi lain",
			"E. Aplikasi tidak dapat berjalan dengan baik karena komunikasi antara pengguna dan perangkat terganggu "
		},
		answer = 5
	}
}

local currentQuestion = 1
local score = 0
local wrongCount = 0

--------------------------------------------------

local function resetButtonColors()
	for _, button in ipairs(buttons) do
		button.BackgroundColor3 = Color3.fromRGB(232, 210, 196)
		button.Active = true
	end
end

--------------------------------------------------

local function loadQuestion()

	resetButtonColors()
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

		lulusScore.Text = "Skor Anda: " .. score .. " / 100"

		lulusDetail.Text =
			"Jawaban Benar: " .. correctAnswers ..
			"\nJawaban Salah: " .. wrongAnswers ..
			"\n\nKamu telah memahami materi dengan baik.\n\nSilakan lanjut ke level 2 ya!"
		
		updateProgressEvent:FireServer(2)
		updateEvent:FireServer(score)
		

	else

		resultLulus.Visible = false
		resultUlang.Visible = true

		ulangTitle.Text = "KAMU PERLU MENGULANG :("

		ulangScore.Text = "Skor Anda: " .. score .. " / 100"

		ulangDetail.Text =
			"Jawaban Benar: " .. correctAnswers ..
			"\nJawaban Salah: " .. wrongAnswers ..
			"\n\nSilakan dengarkan kembali audio dan coba lagi ya"

	end
end

nextButton.MouseButton1Click:Connect(function()
	PlayerControl.Unlock()
	resultBackground.Visible = false
	quizFrame.Visible = false
	level1Gui.Enabled = false
	

	print("Menuju Level Berikutnya")

end)

retryButton.MouseButton1Click:Connect(function()

	resultBackground.Visible = false
	quizFrame.Visible = false

	-- kembali ke audio player
	audioChoose.Visible = true

end)

--------------------------------------------------

local function checkAnswer(selectedIndex)

	-- CEGAH DOUBLE CLICK
	if isAnswering then return end
	isAnswering = true
	
	local correctIndex = questions[currentQuestion].answer

	for _, button in ipairs(buttons) do
		button.Active = false
	end

	if selectedIndex == correctIndex then

		feedbackLabel.Text = "Jawaban Benar"
		feedbackLabel.BackgroundColor3 = Color3.fromRGB(120, 166, 33)
		buttons[selectedIndex].BackgroundColor3 = Color3.fromRGB(0,255,0)
		score += 25

	else

		feedbackLabel.Text = "Jawaban Salah"
		feedbackLabel.BackgroundColor3 = Color3.fromRGB(211, 60, 49)
		buttons[selectedIndex].BackgroundColor3 = Color3.fromRGB(255,0,0)
		wrongCount += 1

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

--------------------------------------------------

for index, button in ipairs(buttons) do
	button.MouseButton1Click:Connect(function()
		checkAnswer(index)
	end)
end

--------------------------------------------------

-- Panggil load pertama kali saat quiz muncul
quizFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if quizFrame.Visible then
		currentQuestion = 1
		score = 0
		wrongCount = 0
		loadQuestion()
	end
end)