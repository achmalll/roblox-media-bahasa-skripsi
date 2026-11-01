-- Source template; build with scripts/build-level2.cjs. Session-local learning state.
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Input = game:GetService("UserInputService")
local DATA = Http:JSONDecode([==[{"intro":"Selamat datang di Level 2 — Keterampilan Membaca.\r\n\r\nPada level ini, Anda akan membaca sebuah teks eksposisi berita yang membahas inovasi teknologi terbaru dalam bidang sistem operasi dan komputasi awan.\r\n\r\nBacalah teks dengan saksama dan pahami informasi yang disampaikan. Papan istilah tersedia bila diperlukan.\r\n\r\nSetelah membaca, kerjakan latihan, kemudian jawab empat soal untuk menguji pemahaman terhadap isi, bukti, dan simpulan berdasarkan berita.\r\n\r\nGunakan kemampuan literasi dan analisis Anda untuk menentukan jawaban yang paling tepat.\r\n\r\nTekan Mulai untuk menuju papan berita.","terms":["Istilah dalam bacaan\r\n\r\n1. Sistem operasi\r\n\r\nPerangkat lunak yang mengatur dan mengelola kerja perangkat, seperti menjalankan aplikasi, mengatur memori, serta menghubungkan perangkat keras dan perangkat lunak. Contohnya Android dan Windows.\r\n\r\n2. Sistem operasi ganda\r\n\r\nPenggunaan dua sistem operasi dalam satu perangkat. Pengguna dapat memanfaatkan keunggulan masing-masing sistem sesuai kebutuhan.\r\n\r\n3. Lokal / native\r\n\r\nSistem atau aplikasi dijalankan langsung pada perangkat. Pada bacaan ini, Android dijalankan lokal.","Komputasi awan / cloud\r\n\r\nTeknologi yang memungkinkan pengguna mengakses sistem atau layanan melalui internet tanpa harus menginstalnya secara langsung di perangkat. Proses komputasi dilakukan di server jarak jauh."],"pages":["Perkembangan teknologi perangkat pintar terus menghadirkan inovasi yang semakin mengaburkan batas antara tablet dan komputer. Salah satu inovasi terbaru yang menarik perhatian dunia teknologi datang dari operator telekomunikasi asal China, China Unicom, yang meluncurkan tablet terbaru bernama Cloud AI Pad. Perangkat ini menghadirkan terobosan berupa penggunaan dua sistem operasi dalam satu perangkat sekaligus. Tablet ini menjalankan sistem operasi Android dan Windows secara bersamaan dengan pendekatan yang berbeda dan saling melengkapi. Peluncuran Cloud AI Pad menunjukkan perkembangan teknologi sistem operasi yang semakin adaptif terhadap kebutuhan produktivitas dan fleksibilitas pengguna di era modern.","Secara teknis, kedua sistem operasi pada Cloud AI Pad dijalankan dengan cara yang berbeda. Sistem operasi Android dijalankan secara lokal langsung di perangkat tablet. Pendekatan ini memungkinkan pengguna mengakses berbagai aplikasi Android dengan respons yang cepat dan efisien, tanpa memerlukan koneksi internet yang stabil sebagai syarat utama. Di sisi lain, sistem operasi Windows dijalankan melalui teknologi komputasi awan atau cloud, sehingga pengguna dapat menikmati pengalaman kerja layaknya menggunakan komputer berbasis Windows tanpa harus menginstalnya secara langsung di perangkat. Perbedaan pendekatan ini mencerminkan strategi desain yang cermat dalam memaksimalkan kemampuan perangkat keras tablet sekaligus memanfaatkan infrastruktur cloud yang terus berkembang.","Dari sudut pandang pasar, pendekatan dual sistem operasi seperti yang diterapkan pada Cloud AI Pad masih tergolong jarang ditemui di pasar global. Umumnya, tablet hanya menggunakan satu sistem operasi utama, baik Android maupun Windows, secara native. Kehadiran dua sistem operasi dalam satu perangkat selama ini dianggap kompleks secara teknis dan berisiko menimbulkan konflik antarsistem. Namun, dengan konsep yang diterapkan oleh China Unicom ini, pengguna Cloud AI Pad dapat beralih antara platform Android yang fleksibel untuk kebutuhan sehari-hari dan Windows yang mendukung produktivitas kerja profesional, semuanya dalam satu perangkat yang sama. Hal ini menjadikan Cloud AI Pad sebagai perangkat yang berpotensi menjawab kebutuhan pengguna yang menginginkan fleksibilitas sekaligus produktivitas tinggi tanpa harus membawa dua perangkat berbeda.\n\nSelain keunggulan sistem operasi ganda, Cloud AI Pad juga dilengkapi dengan fitur kecerdasan buatan (artificial intelligence) yang terintegrasi langsung ke dalam perangkat melalui tombol khusus AI pada keyboard. Fitur ini terhubung dengan asisten cerdas berbasis model bahasa besar Yuanjing yang dikembangkan secara mandiri oleh China Unicom. Dengan adanya integrasi ini, pengguna dapat mengakses kemampuan kecerdasan buatan secara langsung dalam berbagai aktivitas kerja maupun belajar. Kehadiran Cloud AI Pad menegaskan bahwa inovasi sistem operasi tidak lagi hanya berfokus pada pengembangan perangkat lunak semata, tetapi telah berkembang ke arah integrasi menyeluruh antara teknologi cloud, kecerdasan buatan, dan perangkat keras untuk mendukung kebutuhan pengguna modern yang semakin beragam dan dinamis."],"headings":["Perangkat dan gagasan utama","Cara kerja kedua sistem","Manfaat dan fitur pendukung"],"evidence":["Salah satu inovasi terbaru yang menarik perhatian dunia teknologi datang dari operator telekomunikasi asal China, China Unicom, yang meluncurkan tablet terbaru bernama Cloud AI Pad.","Sistem operasi Android dijalankan secara lokal langsung di perangkat tablet.","Di sisi lain, sistem operasi Windows dijalankan melalui teknologi komputasi awan atau cloud, sehingga pengguna dapat menikmati pengalaman kerja layaknya menggunakan komputer berbasis Windows tanpa harus menginstalnya secara langsung di perangkat.","Selain keunggulan sistem operasi ganda, Cloud AI Pad juga dilengkapi dengan fitur kecerdasan buatan (artificial intelligence) yang terintegrasi langsung ke dalam perangkat melalui tombol khusus AI pada keyboard."],"pairEvidence":["Sistem operasi Android dijalankan secara lokal langsung di perangkat tablet. Di sisi lain, sistem operasi Windows dijalankan melalui teknologi komputasi awan atau cloud, sehingga pengguna dapat menikmati pengalaman kerja layaknya menggunakan komputer berbasis Windows tanpa harus menginstalnya secara langsung di perangkat.","Namun, dengan konsep yang diterapkan oleh China Unicom ini, pengguna Cloud AI Pad dapat beralih antara platform Android yang fleksibel untuk kebutuhan sehari-hari dan Windows yang mendukung produktivitas kerja profesional, semuanya dalam satu perangkat yang sama."],"conclusions":["Pada tablet dalam berita, dua OS tidak berarti keduanya dipasang langsung di perangkat.","Keunggulan yang ditawarkan adalah dua lingkungan yang saling melengkapi kebutuhan pengguna."],"questions":[{"number":1,"stem":"Berdasarkan teks, bagaimana perbedaan cara kerja sistem operasi Android dan Windows pada Cloud AI Pad?","options":["A. Android dijalankan secara lokal, sedangkan Windows dijalankan melalui cloud","B. Android dan Windows sama-sama dijalankan melalui cloud","C. Windows dijalankan secara lokal, sedangkan Android melalui cloud","D. Keduanya dijalankan secara native di perangkat tablet","E. Android dan Windows hanya dapat digunakan secara bergantian melalui restart"],"reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Teks menghubungkan tombol AI dengan lokasi eksekusi kedua sistem operasi.","B. Teks menyebut Windows dijalankan lokal dan Android diakses melalui cloud.","C. Teks menyebut Android dijalankan lokal dan Windows diakses melalui cloud.","D. Teks menyebut Android dan Windows dijalankan langsung pada perangkat tablet."],"key1":"Kunci tier 1: A. Batang, opsi, dan kunci mengikuti baseline Sanubari.","key2":"Kunci tier 2: C. Bukti penjelas: Teks menyebut Android lokal dan Windows melalui cloud.","feedback":[{"label":"Tier 1 pilihan A","message":"Benar. Android lokal dan Windows melalui cloud sesuai informasi teks."},{"label":"Tier 1 pilihan B","message":"Hanya Windows yang dinyatakan melalui cloud; Android dinyatakan lokal."},{"label":"Tier 1 pilihan C","message":"Letak kedua sistem tertukar: Android lokal, Windows melalui cloud."},{"label":"Tier 1 pilihan D","message":"Teks tidak menyatakan keduanya native di tablet; Windows diakses melalui cloud."},{"label":"Tier 1 pilihan E","message":"Teks tidak menyebut restart sebagai syarat perpindahan kedua sistem."},{"label":"Tier 2 pilihan A","message":"Alasan A memakai tombol AI, padahal soal menanyakan lokasi eksekusi OS."},{"label":"Tier 2 pilihan B","message":"Alasan B menukar posisi Android dan Windows dalam teks."},{"label":"Tier 2 pilihan C","message":"Alasan C tepat: teks membedakan Android lokal dan Windows cloud."},{"label":"Tier 2 pilihan D","message":"Alasan D mengabaikan bahwa Windows diakses melalui cloud."}]},{"number":2,"stem":"Berdasarkan teks, mengapa pendekatan dual sistem operasi yang diterapkan pada Cloud AI Pad dianggap sebagai inovasi yang signifikan dalam industri tablet saat ini?","options":["A. Karena tablet Cloud AI Pad merupakan satu-satunya perangkat yang pernah menggunakan sistem operasi Android","B. Karena penggunaan dua sistem operasi dalam satu perangkat masih jarang ditemui dan mampu menjawab kebutuhan fleksibilitas sekaligus produktivitas pengguna","C. Karena Cloud AI Pad menggantikan sistem operasi Windows dengan sistem operasi buatan China secara penuh","D. Karena tablet ini menggunakan satu sistem operasi dengan dua antarmuka yang berbeda secara tampilan","E. Karena Cloud AI Pad menjalankan Linux dan Windows secara bersamaan untuk pertama kalinya"],"reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Teks menekankan fleksibilitas Android dan produktivitas Windows dalam pendekatan ganda.","B. Teks menekankan penggunaan Android pada tablet untuk pertama kalinya dalam industri.","C. Teks menekankan dua antarmuka sebagai bukti adanya dua sistem operasi berbeda.","D. Teks menekankan penggantian Windows dengan Linux sebagai pembaruan utama perangkat tablet."],"key1":"Kunci tier 1: B. Batang, opsi, dan kunci mengikuti baseline Sanubari.","key2":"Kunci tier 2: A. Bukti penjelas: Teks menyebut satu perangkat memberi fleksibilitas Android dan produktivitas Windows dengan pendekatan ganda yang jarang ditemui.","feedback":[{"label":"Tier 1 pilihan A","message":"Teks tidak mengatakan Cloud AI Pad satu-satunya perangkat yang pernah memakai Android."},{"label":"Tier 1 pilihan B","message":"Benar. Alasan dalam teks adalah pendekatan ganda yang jarang ditemui serta fleksibilitas dan produktivitas."},{"label":"Tier 1 pilihan C","message":"Teks menyebut Windows melalui cloud, bukan penggantian Windows oleh OS China."},{"label":"Tier 1 pilihan D","message":"Dua antarmuka dari satu OS tidak sama dengan dua sistem yang dijelaskan teks."},{"label":"Tier 1 pilihan E","message":"Pasangan yang dibahas adalah Android dan Windows, bukan Linux dan Windows."},{"label":"Tier 2 pilihan A","message":"Alasan A tepat: bukti mencakup dua lingkungan, fleksibilitas, produktivitas, dan kelangkaan pendekatan ganda."},{"label":"Tier 2 pilihan B","message":"Alasan B mengklaim pemakaian Android pertama kali, yang tidak dinyatakan teks."},{"label":"Tier 2 pilihan C","message":"Alasan C menyamakan tampilan antarmuka dengan jumlah OS tanpa bukti."},{"label":"Tier 2 pilihan D","message":"Alasan D mengganti Windows dengan Linux, berbeda dari isi teks."}]},{"number":3,"stem":"Apa keunggulan penggunaan konsep dual sistem operasi pada Cloud AI Pad dibandingkan tablet pada umumnya?","options":["A. Tablet dapat menjalankan semua sistem operasi","B. Pengguna dapat memanfaatkan fleksibilitas Android dan produktivitas Windows dalam satu perangkat","C. Tablet dapat berfungsi tanpa perangkat keras tambahan","D. Sistem operasi tidak lagi memerlukan pembaruan perangkat lunak","E. Semua aplikasi dapat berjalan tanpa koneksi internet"],"reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Teks menjelaskan seluruh aplikasi kedua sistem dapat digunakan tanpa koneksi internet.","B. Teks mengaitkan dua sistem dalam satu perangkat dengan kebutuhan harian dan produktivitas.","C. Teks menjelaskan kedua sistem dapat berfungsi tanpa komponen fisik pada perangkat tablet.","D. Teks menjelaskan pembaruan kedua sistem tidak lagi diperlukan untuk mendukung produktivitas pengguna."],"key1":"Kunci tier 1: B. Batang, opsi, dan kunci mengikuti baseline Sanubari.","key2":"Kunci tier 2: B. Bukti penjelas: Teks mengaitkan Android dan Windows dalam satu perangkat dengan kebutuhan sehari-hari dan produktivitas.","feedback":[{"label":"Tier 1 pilihan A","message":"Teks hanya menyebut Android dan Windows; kemampuan menjalankan semua OS tidak dinyatakan."},{"label":"Tier 1 pilihan B","message":"Benar. Kedua lingkungan dalam satu perangkat mendukung fleksibilitas dan produktivitas."},{"label":"Tier 1 pilihan C","message":"Teks tidak menyimpulkan perangkat dapat berfungsi tanpa perangkat keras tambahan."},{"label":"Tier 1 pilihan D","message":"Tidak ada pernyataan bahwa dua OS menghapus kebutuhan pembaruan."},{"label":"Tier 1 pilihan E","message":"Windows melalui cloud bergantung koneksi; klaim semua aplikasi tanpa internet terlalu luas."},{"label":"Tier 2 pilihan A","message":"Alasan A menjanjikan semua aplikasi offline, melebihi informasi teks."},{"label":"Tier 2 pilihan B","message":"Alasan B tepat: fungsi kedua lingkungan dihubungkan dengan kebutuhan sehari-hari dan produktivitas."},{"label":"Tier 2 pilihan C","message":"Alasan C menyatakan perangkat tidak membutuhkan komponen fisik, yang tidak dijelaskan teks."},{"label":"Tier 2 pilihan D","message":"Alasan D menghapus kebutuhan pembaruan tanpa dukungan teks."}]},{"number":4,"stem":"Berdasarkan teks, Cloud AI Pad menjalankan Android secara lokal dan Windows melalui cloud. Analisislah implikasi dari pendekatan ini terhadap ketergantungan pengguna pada koneksi internet dalam penggunaan perangkat!","options":["A. Pengguna tidak membutuhkan koneksi internet sama sekali karena kedua sistem berjalan secara lokal","B. Pengguna sepenuhnya bergantung pada internet karena kedua sistem berjalan melalui cloud","C. Android berjalan lokal tanpa bergantung cloud untuk menjalankan OS, sedangkan akses Windows cloud bergantung koneksi; aplikasi Android tertentu tetap dapat memerlukan internet","D. Koneksi internet hanya diperlukan saat memperbarui sistem operasi Android","E. Ketergantungan pada internet tidak relevan karena fitur AI menggantikan fungsi koneksi"],"reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Teks menyebut eksekusi Android lokal menjamin semua aplikasinya selalu dapat berjalan offline.","B. Teks menyebut tombol AI menggantikan kebutuhan koneksi saat pengguna mengakses layanan Windows cloud.","C. Teks menyebut Android dan Windows sama-sama berjalan lokal tanpa bergantung pada layanan cloud.","D. Teks membedakan Android lokal dari Windows cloud, tanpa menjamin semua aplikasi Android offline."],"key1":"Kunci tier 1: C. Opsi C merupakan usulan koreksi baseline untuk ditelaah ahli.","key2":"Kunci tier 2: D. Bukti penjelas: Eksekusi Android lokal dibedakan dari akses Windows cloud yang bergantung koneksi, tanpa menjamin semua aplikasi Android offline.","feedback":[{"label":"Tier 1 pilihan A","message":"Windows melalui cloud sehingga kedua sistem tidak sepenuhnya lokal atau bebas internet."},{"label":"Tier 1 pilihan B","message":"Android dinyatakan lokal sehingga tidak benar bahwa kedua OS berjalan melalui cloud."},{"label":"Tier 1 pilihan C","message":"Benar. OS Android berjalan lokal, sementara Windows cloud bergantung koneksi. Aplikasi Android tertentu tetap dapat memerlukan internet."},{"label":"Tier 1 pilihan D","message":"Kebutuhan koneksi Windows cloud tidak terbatas pada pembaruan Android."},{"label":"Tier 1 pilihan E","message":"Tombol AI tidak dinyatakan menggantikan koneksi untuk layanan cloud."},{"label":"Tier 2 pilihan A","message":"Alasan A menyamakan OS lokal dengan seluruh layanan selalu offline."},{"label":"Tier 2 pilihan B","message":"Alasan B memberi fungsi pengganti internet kepada tombol AI tanpa dukungan teks."},{"label":"Tier 2 pilihan C","message":"Alasan C menempatkan Windows secara lokal, padahal teks menyebut cloud."},{"label":"Tier 2 pilihan D","message":"Alasan D tepat: kebutuhan koneksi dibedakan menurut lokasi eksekusi, tanpa menggeneralisasikan semua aplikasi Android."}]}]}]==])
local player = Players.LocalPlayer
-- Research records are server-timed; no player names or free text are sent.
local recordHttp = game:GetService("HttpService")
local function recordLearning(op, fields)
 local remote=game:GetService("ReplicatedStorage"):FindFirstChild("LearningRecordEvent")
 if not remote then return end
 fields=fields or {}; fields.op=op; fields.level=2; fields.id=fields.id or recordHttp:GenerateGUID(false)
 remote:FireServer(fields)
end

local pg = player:WaitForChild("PlayerGui")
local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerControlHandler"))
local event = game:GetService("ReplicatedStorage"):WaitForChild("UpdateLevel2Score")
local progress = player:WaitForChild("leaderstats"):WaitForChild("LevelProgress")
local state = {intro=false,pages={},page=1,selected={},done1=false,done2=false,slots={},errors1=0,errors2=0,help1=false,help2=false}
local attempt, result, activePrompt, drag, dragBoard
local stations = {
 {path={"Space 2","Budi"},key="intro",title="Pemandu Level 2",action="Bicara"},
 {path={"Space 2","L2_PapanBerita"},key="news",title="Berita Cloud AI Pad",action="Baca berita"},
 {path={"Space 2","Infoboard"},key="terms",title="Istilah dalam bacaan",action="Lihat istilah"},
 {path={"Level2Development","L2_PapanBukti"},key="evidence",title="Latihan 1 — Bukti Teks",action="Buka latihan"},
 {path={"Level2Development","L2_PapanPasangan"},key="pairs",title="Latihan 2 — Simpulan dan Bukti",action="Buka latihan"},
 {path={"Kursi Baru"},key="pairs",title="Latihan 2 — Simpulan dan Bukti",action="Buka latihan"},
 {path={"Level2Development","L2_KiosEvaluasi"},key="exam",title="Evaluasi Level 2",action="Buka evaluasi"},
}
local function find(path)
 local o=workspace
 for _,n in ipairs(path) do o=o and o:FindFirstChild(n) end
 return o
end
local function stationObject(s)
 if not s.namedBoard then return find(s.path) end
 local match
 for _,o in ipairs(workspace:GetDescendants()) do
  if o.Name==s.path[1] and (o:IsA("Model") or o:IsA("BasePart")) then
   if match then return nil end -- Never choose an arbitrary duplicate board.
   match=o
  end
 end
 return match
end
local function partOf(o)
 if not o then return nil end
 if o:IsA("BasePart") then return o end
 return o:FindFirstChild("HumanoidRootPart",true) or o:FindFirstChildWhichIsA("Seat",true) or o:FindFirstChildWhichIsA("BasePart",true)
end
local cream,brown,brick=Color3.fromRGB(244,221,205),Color3.fromRGB(71,32,3),Color3.fromRGB(153,59,42)
local gui=Instance.new("ScreenGui")
gui.Name="Level2Learning"; gui.ResetOnSpawn=false; gui.DisplayOrder=60; gui.Enabled=false; gui.Parent=pg
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local overlay=Instance.new("TextButton")
overlay.Text=""; overlay.Modal=true; overlay.AutoButtonColor=false; overlay.BackgroundColor3=Color3.new(0,0,0)
overlay.BackgroundTransparency=.4; overlay.Size=UDim2.fromScale(1,1); overlay.Parent=gui
local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5); panel.Position=UDim2.fromScale(.5,.5); panel.Size=UDim2.fromScale(.92,.9)
panel.BackgroundColor3=cream; panel.Parent=overlay
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,16)
local stroke=Instance.new("UIStroke",panel); stroke.Color=Color3.fromRGB(209,156,116); stroke.Thickness=3
local limit=Instance.new("UISizeConstraint",panel); limit.MaxSize=Vector2.new(1180,850)
local title=Instance.new("TextLabel")
title.Position=UDim2.fromOffset(20,12); title.Size=UDim2.new(1,-100,0,65); title.BackgroundTransparency=1
title.TextColor3=brown; title.TextSize=28; title.Font=Enum.Font.GothamBold; title.TextWrapped=true; title.Parent=panel
local close=Instance.new("TextButton")
close.Text="×"; close.TextSize=32; close.Size=UDim2.fromOffset(54,54); close.Position=UDim2.new(1,-68,0,16)
close.BackgroundColor3=brick; close.TextColor3=Color3.new(1,1,1); close.Parent=panel
Instance.new("UICorner",close).CornerRadius=UDim.new(0,10)
local body=Instance.new("Frame")
body.Position=UDim2.fromOffset(20,86); body.Size=UDim2.new(1,-40,1,-104); body.BackgroundTransparency=1; body.Parent=panel
local render,news,evidence,pairView,exam,question,resultView
local refreshGuide=function() end
local noticeGui=Instance.new("ScreenGui")
noticeGui.Name="L2StageNotice"; noticeGui.ResetOnSpawn=false; noticeGui.DisplayOrder=70; noticeGui.Parent=pg
local notice=Instance.new("TextLabel")
notice.AnchorPoint=Vector2.new(.5,0); notice.Position=UDim2.fromScale(.5,.1); notice.Size=UDim2.new(.8,0,0,100)
notice.BackgroundColor3=cream; notice.TextColor3=brown; notice.TextSize=23; notice.Font=Enum.Font.GothamBold
notice.TextWrapped=true; notice.Visible=false; notice.Parent=noticeGui
Instance.new("UICorner",notice).CornerRadius=UDim.new(0,12)
local noticeVersion=0
local function alert(value)
 noticeVersion+=1; local version=noticeVersion
 notice.Text=value; notice.Visible=true
 task.delay(5,function() if noticeVersion==version then notice.Visible=false end end)
end
local evaluationFooter,evaluationStatus
local function clear(heading)
 if evaluationFooter then evaluationFooter:Destroy(); evaluationFooter=nil end
 if evaluationStatus then evaluationStatus:Destroy(); evaluationStatus=nil end
 panel.Size=UDim2.fromScale(.92,.9); panel.BackgroundColor3=cream
 stroke.Color=Color3.fromRGB(209,156,116); stroke.Thickness=3
 title.Position=UDim2.fromOffset(20,12); title.Size=UDim2.new(1,-100,0,65); title.TextSize=28; title.TextColor3=brown
 body.Position=UDim2.fromOffset(20,86); body.Size=UDim2.new(1,-40,1,-104)
 drag=nil; dragBoard=nil; body:ClearAllChildren(); title.Text=heading
end
local function list()
 local sc=Instance.new("ScrollingFrame")
 sc.Size=UDim2.fromScale(1,1); sc.BackgroundTransparency=1; sc.BorderSizePixel=0; sc.ScrollBarThickness=8
 sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; sc.CanvasSize=UDim2.new(); sc.Parent=body
 local pad=Instance.new("UIPadding",sc); pad.PaddingRight=UDim.new(0,14); pad.PaddingBottom=UDim.new(0,12)
 local layout=Instance.new("UIListLayout",sc); layout.Padding=UDim.new(0,12); layout.SortOrder=Enum.SortOrder.LayoutOrder
 return sc
end
local function text(parent,value,size)
 local t=Instance.new("TextLabel")
 t.Text=value; t.Size=UDim2.new(1,0,0,0); t.AutomaticSize=Enum.AutomaticSize.Y; t.BackgroundTransparency=1
 t.TextSize=size or 24; t.Font=Enum.Font.Gotham
 t.TextColor3=evaluationFooter and Color3.fromRGB(70,47,37) or brown; t.TextWrapped=true
 t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Top; t.LayoutOrder=#parent:GetChildren(); t.Parent=parent
 return t
end
local function button(parent,label,callback,enabled)
 local b=Instance.new("TextButton")
 b.Text=label; b.Size=UDim2.new(1,0,0,56); b.AutomaticSize=Enum.AutomaticSize.Y; b.TextWrapped=true
 b.TextSize=23; b.Font=Enum.Font.GothamBold; b.TextColor3=Color3.new(1,1,1)
 b.BackgroundColor3=enabled==false and Color3.fromRGB(125,115,110) or brick
 b.Active=enabled~=false; b.AutoButtonColor=enabled~=false; b.LayoutOrder=#parent:GetChildren(); b.Parent=parent
 local pad=Instance.new("UIPadding",b)
 pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12)
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
 b.Activated:Connect(function() if enabled~=false then callback() end end)
 return b
end
-- Match Level 1: cream frame, large heading, scrollable reading area and fixed actions.
local function evaluationClear(heading,statusText)
 clear(heading)
 panel.Size=UDim2.fromScale(.88,.92); panel.BackgroundColor3=Color3.fromRGB(246,224,207)
 stroke.Color=Color3.fromRGB(154,103,76); stroke.Thickness=2
 title.Position=UDim2.fromScale(.06,.025); title.Size=UDim2.fromScale(.80,.10)
 title.TextSize=32; title.TextColor3=Color3.fromRGB(70,47,37)
 body.Position=UDim2.fromScale(.07,.15); body.Size=UDim2.fromScale(.86,.57)
 evaluationStatus=Instance.new("TextLabel")
 evaluationStatus.Position=UDim2.fromScale(.07,.74); evaluationStatus.Size=UDim2.fromScale(.86,.11)
 evaluationStatus.BackgroundTransparency=1; evaluationStatus.TextWrapped=true; evaluationStatus.TextSize=24
 evaluationStatus.Font=Enum.Font.Gotham; evaluationStatus.TextColor3=Color3.fromRGB(100,70,55)
 evaluationStatus.Text=statusText or ""; evaluationStatus.Parent=panel
 evaluationFooter=Instance.new("Frame")
 evaluationFooter.BackgroundTransparency=1; evaluationFooter.Position=UDim2.fromScale(.07,.87)
 evaluationFooter.Size=UDim2.fromScale(.86,.08); evaluationFooter.Parent=panel
 local layout=Instance.new("UIListLayout",evaluationFooter)
 layout.FillDirection=Enum.FillDirection.Horizontal; layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
 layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,12)
 local sc=list(); sc.ScrollBarThickness=6
 sc:FindFirstChildOfClass("UIListLayout").Padding=UDim.new(0,20)
 return sc
end
local function evaluationAction(label,callback,enabled)
 local b=button(evaluationFooter,label,callback,enabled)
 b.AutomaticSize=Enum.AutomaticSize.None; b.Size=UDim2.new(.46,-6,1,0); b.TextSize=24
 if enabled==false then b.BackgroundColor3=Color3.fromRGB(150,140,135) end
 return b
end
local function prompts(enabled)
 for _,s in ipairs(stations) do if s.prompt and s.prompt.Parent then s.prompt.Enabled=enabled end end
end
local function dismiss()
 gui.Enabled=false; drag=nil; activePrompt=nil; controls.Unlock(); prompts(true)
 player:SetAttribute("L2LearningOpen",false)
 refreshGuide()
end
local function message(heading,value)
 clear(heading); local sc=list(); text(sc,value); return sc
end
-- FLOW_RULES_BEGIN: shared verbatim with the Luau flow regression harness.
local function allRead() return state.pages[1] and state.pages[2] and state.pages[3] end
local function beginReview()
 state.reviewNews=true; state.page=1
end
local function unreadPage()
 for i=1,3 do if not state.pages[i] then return i end end
 return state.page
end
local function stage()
 if state.reviewNews then return "news" end
 if not state.intro then return "intro" end
 if not allRead() then return "news" end
 if not state.done1 then return "evidence" end
 if not state.done2 then return "pairs" end
 return "exam"
end
local function prerequisite(key)
 if progress.Value<2 then return "Selesaikan Level 1 dengan nilai minimal 75 terlebih dahulu." end
 if key=="intro" or key=="terms" then return nil end
 if not state.intro then return "Temui pemandu Level 2 dan tekan Mulai terlebih dahulu." end
 if key=="news" then return nil end
 if not allRead() then return "Baca berita terlebih dahulu. Bagian "..unreadPage().."/3 belum dikunjungi. Ikuti panah ke papan berita." end
 if key=="evidence" then return nil end
 if not state.done1 then return "Selesaikan Latihan 1 — Bukti Teks terlebih dahulu. Ikuti panah ke meja bukti." end
 if key=="pairs" then return nil end
 if not state.done2 then return "Selesaikan Latihan 2 — Simpulan dan Bukti terlebih dahulu. Ikuti panah ke latihan pasangan." end
 return nil
end
-- FLOW_RULES_END
refreshGuide=function()
 if progress.Value~=2 then player:SetAttribute("L2GuideTarget",nil); return end
 local destination
 for _,s in ipairs(stations) do if s.key==stage() then
  local o=stationObject(s)
  local part=partOf(o)
  if part then
   destination=s.prompt and s.prompt.Parent and s.prompt.Parent:IsA("Attachment") and s.prompt.Parent.WorldPosition or part.Position
   break
  end
 end end
 player:SetAttribute("L2GuideStage",stage())
 player:SetAttribute("L2GuideTarget",destination)
end
local function terms(back,page)
 page=page or 1
 clear("Istilah dalam bacaan — "..page.."/2"); local sc=list()
 text(sc,DATA.terms[page])
 if page==1 then button(sc,"Lanjut",function() terms(back,2) end)
 else button(sc,"Halaman sebelumnya",function() terms(back,1) end) end
 if back then button(sc,"Kembali",back) end
end
news=function(back)
 clear("Berita Cloud AI Pad — "..state.page.."/3"); state.pages[state.page]=true
 local sc=list(); text(sc,DATA.headings[state.page],26); text(sc,DATA.pages[state.page])
 button(sc,"Istilah dalam bacaan",function() terms(function() news(back) end) end)
 if state.page>1 then button(sc,"Kembali",function() state.page-=1; news(back) end) end
 if state.page<3 then button(sc,"Lanjut",function() state.page+=1; news(back) end)
 elseif not back then button(sc,"Ke meja bukti",function() state.reviewNews=false; dismiss() end) end
 if back then button(sc,"Kembali ke latihan",back) end
end
local function selectedCount()
 local n=0; for i=1,4 do if state.selected[i] then n+=1 end end; return n
end
evidence=function(feedback)
 clear("Latihan 1 — Bukti Teks"); local sc=list()
 text(sc,"Tandai dua kalimat yang mendukung pernyataan: kedua sistem tidak dijalankan dengan cara yang sama.")
 for i,v in ipairs(DATA.evidence) do
  local b=button(sc,(state.selected[i] and "✓ " or "")..v,function()
   if state.done1 then return end
   if state.selected[i] then state.selected[i]=nil elseif selectedCount()<2 then state.selected[i]=true
   else evidence("Pilih dua kalimat saja."); return end
   evidence()
  end)
  if state.selected[i] then b.BackgroundColor3=Color3.fromRGB(97,100,63) end
 end
 if feedback then text(sc,feedback) end
 if state.done1 then
  text(sc,"Bukti sudah sesuai. Android dijalankan lokal, sedangkan Windows melalui cloud. Keduanya mendukung perbedaan cara menjalankan sistem.")
  button(sc,"Ke Latihan 2",dismiss)
 else
  button(sc,"Periksa",function()
   local choices={}; for i=1,4 do if state.selected[i] then table.insert(choices,i) end end
   recordLearning("practice",{activity="evidence",choices=choices,help=state.help1})
   if state.selected[2] and state.selected[3] then state.done1=true; evidence()
   else
    state.errors1+=1
    local f="Pertahankan bukti tentang cara menjalankan sistem. Nama pembuat dan tombol AI tidak menjelaskan perbedaan itu."
    if state.errors1>=2 then state.help1=true; f..=" Petunjuk: cari Android dijalankan secara lokal dan Windows melalui komputasi awan." end
    evidence(f)
   end
  end,selectedCount()==2)
 end
 button(sc,"Baca berita lengkap",function() news(function() evidence() end) end)
end
local function box(pos,size,value)
 local b=Instance.new("TextLabel"); b.Position=pos; b.Size=size; b.Text=value; b.TextWrapped=true
 b.Font=Enum.Font.Gotham; b.TextSize=20; b.TextColor3=brown; b.BackgroundColor3=Color3.fromRGB(250,239,230); b.Parent=body
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,10); return b
end
pairView=function(feedback)
 clear("Latihan 2 — Simpulan dan Bukti")
 local hint=box(UDim2.fromScale(0,0),UDim2.fromScale(1,.09),"Seret simpulan ke kotak bukti. Untuk mengganti, kembalikan kartu ke area kartu dahulu."); hint.BackgroundTransparency=1
 local home=box(UDim2.fromScale(0,.55),UDim2.fromScale(1,.25),"")
 local targets={}
 for i=1,2 do
  local quote=box(UDim2.fromScale((i-1)*.51,.1),UDim2.fromScale(.49,.27),DATA.pairEvidence[i])
  if state.help2 then
   quote.RichText=true
   quote.Text=quote.Text:gsub("secara lokal","<b>secara lokal</b>"):gsub("tanpa harus menginstalnya","<b>tanpa harus menginstalnya</b>"):gsub("sehari%-hari","<b>sehari-hari</b>"):gsub("produktivitas kerja profesional","<b>produktivitas kerja profesional</b>")
  end
  targets[i]=box(UDim2.fromScale((i-1)*.51,.39),UDim2.fromScale(.49,.14),"Lepaskan simpulan di sini")
 end
 for i=1,2 do
  local card=Instance.new("TextButton")
  card.Text=DATA.conclusions[i]; card.TextWrapped=true; card.TextSize=20; card.Font=Enum.Font.GothamBold
  card.TextColor3=Color3.new(1,1,1); card.BackgroundColor3=brick; card.Size=UDim2.fromScale(.49,.14)
  local slot=state.slots[i]
  card.Position=slot and UDim2.fromScale((slot-1)*.51,.39) or UDim2.fromScale(i==1 and .51 or 0,.57)
  card.ZIndex=3; card.Parent=body; Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
  card.InputBegan:Connect(function(input)
   if state.done2 or drag then return end
   if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
   drag={index=i,card=card,input=input,offset=Vector2.new(input.Position.X,input.Position.Y)-card.AbsolutePosition}
   card.ZIndex=10
  end)
 end
 local f=box(UDim2.fromScale(0,.81),UDim2.fromScale(1,.08),feedback or (state.done2 and "Simpulan sesuai dengan buktinya." or "Kedua kotak harus terisi sebelum Periksa.")); f.BackgroundTransparency=1
 local left=Instance.new("Frame"); left.BackgroundTransparency=1; left.Position=UDim2.fromScale(0,.91); left.Size=UDim2.fromScale(.49,.09); left.Parent=body
 local right=left:Clone(); right.Position=UDim2.fromScale(.51,.91); right.Parent=body
 local check=button(left,state.done2 and "Ke kios evaluasi" or "Periksa",function()
  if state.done2 then dismiss(); return end
  recordLearning("practice",{activity="pairs",choices={state.slots[1],state.slots[2]},help=state.help2})
  if state.slots[1]==1 and state.slots[2]==2 then state.done2=true; pairView()
  else
   state.errors2+=1
   local value="Tinjau hubungan isi: cara eksekusi mendukung instalasi; kebutuhan pengguna mendukung manfaat."
   if state.errors2>=2 then state.help2=true; value..=" Petunjuk: lokal/tanpa instalasi; sehari-hari/produktivitas." end
   pairView(value)
  end
 end,state.done2 or (state.slots[1]~=nil and state.slots[2]~=nil))
 local read=button(right,"Baca berita lengkap",function() if not drag then news(function() pairView() end) end end)
 for _,b in ipairs({check,read}) do b.Size=UDim2.fromScale(1,1); b.AutomaticSize=Enum.AutomaticSize.None; b.TextSize=20 end
 dragBoard={targets=targets,home=home}
end
local function inside(point,o)
 local p,s=o.AbsolutePosition,o.AbsoluteSize
 return point.X>=p.X and point.Y>=p.Y and point.X<=p.X+s.X and point.Y<=p.Y+s.Y
end
Input.InputChanged:Connect(function(input)
 if not drag then return end
 if input.UserInputType~=Enum.UserInputType.MouseMovement and input~=drag.input then return end
 local p=Vector2.new(input.Position.X,input.Position.Y)-drag.offset-body.AbsolutePosition
 drag.card.Position=UDim2.fromOffset(p.X,p.Y)
end)
Input.InputEnded:Connect(function(input)
 if not drag or (input.UserInputType~=Enum.UserInputType.MouseButton1 and input~=drag.input) then return end
 local d=drag; drag=nil; local point=Vector2.new(input.Position.X,input.Position.Y)
 if dragBoard then
  for i,target in ipairs(dragBoard.targets) do if inside(point,target) then
   local other=d.index==1 and 2 or 1
   if state.slots[other]~=i then state.slots[d.index]=i end
   pairView(); return
  end end
  if inside(point,dragBoard.home) then state.slots[d.index]=nil end
 end
 pairView()
end)
resultView=function()
 local sc=evaluationClear("Hasil Evaluasi Level 2",result.unlocked and "Level 3 terbuka. Tutup hasil dan ikuti panah." or "Nilai minimal 75. Pelajari kembali berita, lalu kembali ke kios untuk mencoba lagi.")
 text(sc,"Skor jawaban: "..result.score.." / 100",34).Font=Enum.Font.GothamBold
 text(sc,"Ketepatan alasan: "..result.reasons.." / 4 (terpisah dari skor kemajuan)")
 text(sc,"Nilai terbaik sesi: "..result.best.." / 100")
 text(sc,result.unlocked and "Akses Level 3 sudah terbuka." or "Nilai minimal 75. Baca kembali materi dan coba lagi.")
 if result.unlocked then evaluationAction("Lanjut ke Level 3",dismiss)
 else
  evaluationAction("Belajar lagi",function()
   beginReview(); dismiss()
   alert("Ikuti panah ke papan berita di sisi kiri. Tahan E untuk membaca kembali.")
  end)
  evaluationAction("Coba lagi",function() state.reviewNews=false; result=nil; exam() end)
 end
end
local function submit()
 attempt.pending=true; attempt.payload={id=attempt.id,answers=attempt.answers,reasons=attempt.reasons}
 local sc=evaluationClear("Menyimpan hasil","Menunggu konfirmasi skor dari server…")
 text(sc,"Hasil evaluasi sedang dikirim."); event:FireServer(attempt.payload)
 local id=attempt.id
 task.delay(8,function()
  if attempt and attempt.id==id and attempt.pending then
   local sc=evaluationClear("Konfirmasi belum diterima","Kirim ulang percobaan yang sama untuk meminta konfirmasi.")
   text(sc,"Hasil belum dikonfirmasi server.")
   evaluationAction("Kirim ulang",function() event:FireServer(attempt.payload) end)
  end
 end)
end
question=function()
 local q=DATA.questions[attempt.index]
 local sc=evaluationClear("Evaluasi "..attempt.index.."/4 — "..(attempt.tier==1 and "Jawaban" or "Alasan"),attempt.feedback and "Baca penjelasan sebelum melanjutkan." or (attempt.selection and "Pilihan siap dikunci." or "Pilih satu opsi terlebih dahulu."))
 if attempt.feedback then
  text(sc,q.feedback[attempt.answers[attempt.index]].message)
  text(sc,q.feedback[5+attempt.reasons[attempt.index]].message)
  evaluationAction(attempt.index==4 and "Lihat hasil" or "Soal berikutnya",function()
   if attempt.index==4 then submit() else attempt.index+=1; attempt.tier=1; attempt.selection=nil; attempt.feedback=false; question() end
  end); return
 end
 text(sc,q.stem,26).Font=Enum.Font.GothamBold
 if attempt.tier==2 then text(sc,"Jawaban terkunci: "..q.options[attempt.answers[attempt.index]]); text(sc,q.reasonStem) end
 for i,v in ipairs(attempt.tier==1 and q.options or q.reasons) do
  local b=button(sc,v,function() attempt.selection=i; question() end)
  b.TextSize=24; b.Font=Enum.Font.Gotham; b.TextColor3=Color3.fromRGB(70,47,37)
  b.TextXAlignment=Enum.TextXAlignment.Left
  b.BackgroundColor3=attempt.selection==i and Color3.fromRGB(103,151,199) or Color3.fromRGB(232,210,196)
 end
 evaluationAction(attempt.tier==1 and "Kunci jawaban" or "Kirim jawaban",function()
  if attempt.tier==1 then attempt.answers[attempt.index]=attempt.selection; attempt.tier=2; attempt.selection=nil
  else attempt.reasons[attempt.index]=attempt.selection; attempt.feedback=true
   recordLearning("evaluation_item",{id=attempt.id..":"..attempt.index,attemptId=attempt.id,question=attempt.index,answer=attempt.answers[attempt.index],reason=attempt.reasons[attempt.index]})
  end
  question()
 end,attempt.selection~=nil)
end
exam=function()
 if result then resultView(); return end
 local sc=evaluationClear("Siap mengikuti evaluasi Level 2?","Jawaban benar bernilai 25. Nilai minimal untuk melanjutkan adalah 75.")
 text(sc,"Empat soal. Pilih jawaban, kunci, lalu pilih alasan. Penjelasan muncul setelah keduanya dikirim. Jawaban tepat bernilai 25; minimal 75 untuk melanjutkan. Alasan ditampilkan terpisah. Selama evaluasi materi dan bantuan tidak dibuka.")
 evaluationAction("Mulai evaluasi",function() state.reviewNews=false; attempt={id=Http:GenerateGUID(false),index=1,tier=1,answers={},reasons={}}; question() end)
 evaluationAction("Nanti dulu",dismiss)
end
event.OnClientEvent:Connect(function(response)
 if not attempt or not attempt.pending or typeof(response)~="table" or response.id~=attempt.id then return end
 if response.error then attempt=nil; local sc=evaluationClear("Hasil belum disimpan",response.error); evaluationAction("Tutup",dismiss); return end
 result=response; attempt=nil; resultView()
end)
local function closeRequested()
 if attempt then
  if attempt.pending then return end
  local sc=evaluationClear("Keluar dari evaluasi?","Percobaan yang belum selesai akan dibatalkan tanpa nilai akhir.")
  text(sc,"Pilih lanjut untuk kembali ke soal yang sedang dikerjakan.")
  evaluationAction("Lanjut mengerjakan",question); evaluationAction("Batalkan percobaan",function() attempt=nil; dismiss() end)
 else dismiss() end
end
close.Activated:Connect(closeRequested)
Input.InputBegan:Connect(function(input) if input.KeyCode==Enum.KeyCode.Escape and gui.Enabled then closeRequested() end end)
local function resetCharacter(character)
 if attempt and not attempt.pending then attempt=nil end; dismiss()
 task.spawn(function()
  local h=character:WaitForChild("Humanoid",10)
  if h then h.Died:Connect(function() if attempt and not attempt.pending then attempt=nil end; dismiss() end) end
 end)
end
player.CharacterAdded:Connect(resetCharacter)
if player.Character then resetCharacter(player.Character) end
render=function(key)
 if key=="terms" then terms(); return end
 if key=="intro" then
  clear("Level 2 — Keterampilan Membaca"); local sc=list(); text(sc,DATA.intro)
  button(sc,"Mulai — menuju papan berita",function()
   state.intro=true; dismiss(); alert("Ikuti panah ke papan Berita Cloud AI Pad di sisi kiri. Tahan E untuk membaca.")
  end); return
 end
 if key=="news" then state.page=state.reviewNews and 1 or unreadPage(); news() elseif key=="evidence" then evidence() elseif key=="pairs" then pairView() else exam() end
end
local function bind(s)
 local obj=stationObject(s); if not obj then return end
 if s.prompt and s.prompt:IsDescendantOf(obj) then return end
 local part=partOf(obj); if not part then return end
 local a=Instance.new("Attachment"); a.Name="L2LearningAnchor"
 if obj:IsA("Model") and s.key~="intro" and s.path[1]~="Kursi Baru" then
  local bounds=obj:GetBoundingBox(); a.Position=part.CFrame:PointToObjectSpace(bounds.Position)
 else a.Position=Vector3.new(0,1,0) end
 if s.key=="news" then
  -- The existing news board is one tall MeshPart, not a Model. Keep E reachable
  -- from the floor rather than placing it above the centre of the whole mesh.
  local cf,size=part.CFrame,part.Size
  local halfHeight=(math.abs(cf.RightVector.Y)*size.X+math.abs(cf.UpVector.Y)*size.Y+math.abs(cf.LookVector.Y)*size.Z)/2
  a.Position=cf:PointToObjectSpace(part.Position-Vector3.new(0,math.max(0,halfHeight-3),0))
 end
 a.Parent=part
 if s.key=="news" then
  -- Text follows the board surface and perspective, rather than a screen-sized billboard.
  for _,child in ipairs(part:GetChildren()) do
   if child.Name=="L2NewsSign" and child:IsA("SurfaceGui") then child:Destroy() end
  end
  for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
   local sign=Instance.new("SurfaceGui")
   sign.Name="L2NewsSign"; sign.Adornee=part; sign.Face=face
   sign.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; sign.CanvasSize=Vector2.new(900,870)
   sign.MaxDistance=60; sign.AlwaysOnTop=false; sign.LightInfluence=1; sign.Parent=part
   local label=Instance.new("TextLabel")
   label.Position=UDim2.fromScale(.12,.12); label.Size=UDim2.fromScale(.76,.43)
   label.BackgroundTransparency=1; label.TextColor3=brown
   label.Font=Enum.Font.GothamBold; label.TextScaled=true; label.TextWrapped=true
   label.Text="BERITA\nCloud AI Pad\n\nTahan E untuk membaca"; label.Parent=sign
   local constraint=Instance.new("UITextSizeConstraint",label); constraint.MaxTextSize=60; constraint.MinTextSize=16
  end
 end
 local p=Instance.new("ProximityPrompt")
 p.Name="L2LearningPrompt"; p.ActionText=s.action; p.ObjectText=s.title; p.KeyboardKeyCode=Enum.KeyCode.E
 p.HoldDuration=1; p.MaxActivationDistance=10; p.RequiresLineOfSight=false; p.Enabled=not gui.Enabled; p.Parent=a; s.prompt=p
 p.Triggered:Connect(function(who)
  if who and who~=player then return end; if gui.Enabled then return end
  local reason=prerequisite(s.key)
  if reason then alert(reason); refreshGuide(); return end
  notice.Visible=false; noticeVersion+=1
  recordLearning("start")
  activePrompt=p; gui.Enabled=true; player:SetAttribute("L2LearningOpen",true); controls.Lock(); prompts(false); render(s.key)
 end)
 print("[L2 Learning] Bound: "..table.concat(s.path,"/"))
end
local retired=setmetatable({}, {__mode="k"})
local function retireLegacy()
 for _,path in ipairs({{"Space2Answers"},{"Space 2","Infoboard"}}) do
  local o=find(path)
  if o then for _,p in ipairs(o:GetDescendants()) do
   if p:IsA("ProximityPrompt") and p.Name~="L2LearningPrompt" and not retired[p] then
    retired[p]=true; p.Enabled=false
    p:GetPropertyChangedSignal("Enabled"):Connect(function() if p.Enabled then p.Enabled=false end end)
   end
  end end
 end
end
task.spawn(function()
 while script.Parent do
  retireLegacy(); for _,s in ipairs(stations) do bind(s) end
  if activePrompt and not activePrompt:IsDescendantOf(workspace) then
   if attempt and not attempt.pending then attempt=nil end; dismiss()
  end
  refreshGuide()
  task.wait(.5)
 end
end)
print("[L2 Learning] Ready — intro/news/evidence/pairs/evaluation")
