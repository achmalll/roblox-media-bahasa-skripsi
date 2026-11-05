local UI = (function()
-- Inlined into the three managed clients by build-responsive-ui.cjs.
-- Keep readable type and scroll overflow instead of shrinking the entire interface.
local UI = {}
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local cream = Color3.fromRGB(246,224,207)
local ink = Color3.fromRGB(70,47,37)
local autoConnections=setmetatable({},{__mode="k"})
function UI.screen(gui)
 gui.IgnoreGuiInset=true
 gui.ScreenInsets=Enum.ScreenInsets.None
 gui.ClipToDeviceSafeArea=false
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
end
function UI.font(width,heading)
 return heading and (width<600 and 24 or 32) or (width<600 and 20 or 24)
end
function UI.height(label,width,padding)
 local value=label.Text:gsub("<[^>]*>","")
 return math.ceil(TextService:GetTextSize(value,label.TextSize,label.Font,Vector2.new(math.max(80,width),100000)).Y)+(padding or 0)
end
function UI.fit(frame,callback,maxHeight)
 for _,c in ipairs(frame:GetChildren()) do
  if c:IsA("UISizeConstraint") or c:IsA("UIAspectRatioConstraint") or c:IsA("UIScale") then c:Destroy() end
 end
 local gui=frame:FindFirstAncestorWhichIsA("ScreenGui")
 if gui then UI.screen(gui) end
 frame.AnchorPoint=Vector2.new(.5,.5); frame.Position=UDim2.fromScale(.5,.5)
 local function resize()
  if not frame.Parent then return end
  local camera=workspace.CurrentCamera
  if not camera then return end
  local v=camera.ViewportSize
  local top,bottom=GuiService:GetGuiInset()
  -- ScreenInsets.None is only for the shade. Interactive panels stay inside
  -- hardware cutouts and core UI, including landscape camera notches.
  local ok,full,safe=pcall(function()
   return GuiService:GetInsetArea(Enum.ScreenInsets.None),GuiService:GetInsetArea(Enum.ScreenInsets.CoreUISafeInsets)
  end)
  if ok then
   top=Vector2.new(math.max(0,safe.Min.X-full.Min.X),math.max(0,safe.Min.Y-full.Min.Y))
   bottom=Vector2.new(math.max(0,full.Max.X-safe.Max.X),math.max(0,full.Max.Y-safe.Max.Y))
  end
  local horizontal=math.max(12,top.X,bottom.X)
  local vertical=math.max(12,top.Y,bottom.Y)+8
  frame.Size=UDim2.fromOffset(math.min(1080,math.max(100,v.X-horizontal*2)),math.min(maxHeight or 800,math.max(100,v.Y-vertical*2)))
  if callback then callback(frame.AbsoluteSize.X,frame.AbsoluteSize.Y) end
 end
 local cameraConnection
 local function watchCamera()
  if cameraConnection then cameraConnection:Disconnect() end
  if workspace.CurrentCamera then cameraConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
  resize()
 end
 local connection=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
 local frameConnection=frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
  if callback then callback(frame.AbsoluteSize.X,frame.AbsoluteSize.Y) end
 end)
 frame.Destroying:Connect(function()
  connection:Disconnect(); frameConnection:Disconnect()
  if cameraConnection then cameraConnection:Disconnect() end
 end)
 watchCamera()
 return resize
end
function UI.scroll(parent,name)
 local sc=Instance.new("ScrollingFrame")
 sc.Name=name or "ReadingArea"; sc.BackgroundTransparency=1; sc.BorderSizePixel=0
 sc.Size=UDim2.fromScale(1,1); sc.CanvasSize=UDim2.new(); sc.AutomaticCanvasSize=Enum.AutomaticSize.Y
 sc.ScrollingDirection=Enum.ScrollingDirection.Y; sc.ScrollBarThickness=8; sc.ScrollBarImageColor3=Color3.fromRGB(153,59,42); sc.Active=true
 sc.Parent=parent
 local layout=Instance.new("UIListLayout",sc); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,14)
 local pad=Instance.new("UIPadding",sc); pad.PaddingRight=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,18)
 return sc
end
function UI.autoText(item,minHeight,padding)
 if autoConnections[item] then for _,c in ipairs(autoConnections[item]) do c:Disconnect() end end
 item.TextScaled=false; item.TextWrapped=true; item.TextTruncate=Enum.TextTruncate.None
 item.AutomaticSize=Enum.AutomaticSize.None
 local busy=false
 local function resize()
  if busy or not item.Parent then return end
  busy=true
  local width=item.AbsoluteSize.X
  item.Size=UDim2.new(item.Size.X.Scale,item.Size.X.Offset,0,math.max(minHeight or 0,UI.height(item,width-(padding or 0),padding or 0)))
  busy=false
 end
 autoConnections[item]={item:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize),item:GetPropertyChangedSignal("Text"):Connect(resize),item:GetPropertyChangedSignal("TextSize"):Connect(resize)}
 task.defer(resize)
 return item
end
function UI.label(parent,value,size,bold)
 local t=Instance.new("TextLabel"); t.Text=value; t.TextSize=size or 24
 t.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
 t.BackgroundTransparency=1; t.TextColor3=ink; t.TextXAlignment=Enum.TextXAlignment.Left
 t.TextYAlignment=Enum.TextYAlignment.Top; t.Size=UDim2.new(1,0,0,0)
 t.LayoutOrder=#parent:GetChildren(); t.Parent=parent
 return UI.autoText(t,0,4)
end
function UI.action(item,label)
 if item:IsA("ImageButton") then item.Image="" end
 item.BackgroundTransparency=0; item.BackgroundColor3=Color3.fromRGB(153,59,42)
 local text=item:IsA("TextButton") and item or item:FindFirstChildWhichIsA("TextLabel")
 if not text then text=Instance.new("TextLabel",item) end
 text.Text=label; text.TextColor3=Color3.new(1,1,1); text.TextSize=20; text.Font=Enum.Font.GothamBold
 text.TextScaled=false; text.TextWrapped=true; text.TextXAlignment=Enum.TextXAlignment.Center; text.TextYAlignment=Enum.TextYAlignment.Center
 text.TextTruncate=Enum.TextTruncate.None
 if text~=item then
  for _,c in ipairs(text:GetChildren()) do if c:IsA("UIScale") or c:IsA("UISizeConstraint") or c:IsA("UIAspectRatioConstraint") then c:Destroy() end end
  text.AnchorPoint=Vector2.zero; text.Rotation=0; text.AutomaticSize=Enum.AutomaticSize.None
  text.BackgroundTransparency=1; text.Position=UDim2.new(); text.Size=UDim2.fromScale(1,1)
 end
 if not item:FindFirstChildOfClass("UICorner") then Instance.new("UICorner",item).CornerRadius=UDim.new(0,10) end
end
-- Reuse existing buttons and their event handlers while replacing legacy fixed text geometry.
function UI.legacy(frame,heading,copy,actionNames)
 local actions={}
 for _,spec in ipairs(actionNames) do
  local b=frame:FindFirstChild(spec[1])
  if b then actions[b]=true; UI.action(b,spec[2]); b.Visible=true end
 end
 for _,c in ipairs(frame:GetChildren()) do if c:IsA("GuiObject") and not actions[c] then c.Visible=false end end
 local sc=UI.scroll(frame,"ResponsiveContent")
 local title=UI.label(frame,heading,32,true)
 local copyLabel=UI.label(sc,copy,24)
 local scrollHint=UI.label(sc,"Gulir ke bawah untuk membaca seluruh isi.",18)
 scrollHint.LayoutOrder=-1; scrollHint.TextColor3=Color3.fromRGB(125,85,65)
 frame.BackgroundColor3=cream
 UI.fit(frame,function(w,h)
  local footer={}
  for _,spec in ipairs(actionNames) do
   local b=frame:FindFirstChild(spec[1])
   if b then
    b.AnchorPoint=Vector2.zero
    if spec[1]=="close" then
     UI.action(b,"×"); b.Position=UDim2.new(1,-64,0,16); b.Size=UDim2.fromOffset(48,48)
    else table.insert(footer,b) end
   end
  end
  for i,b in ipairs(footer) do
   b.Position=UDim2.new((i-1)/#footer,20,1,-72)
   b.Size=UDim2.new(1/#footer,-40/#footer-8,0,56)
  end
  title.TextSize=h<300 and 22 or UI.font(w,true)
  title.TextWrapped=h>=300; title.TextTruncate=h<300 and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
  local titleHeight=h<300 and 44 or math.max(48,UI.height(title,w-100,4))
  title.Position=UDim2.fromOffset(20,16); title.Size=UDim2.new(1,-88,0,titleHeight)
  sc.Position=UDim2.fromOffset(20,titleHeight+30)
  sc.Size=UDim2.new(1,-40,1,-(titleHeight+30+(next(footer) and 88 or 20)))
  copyLabel.TextSize=UI.font(w); scrollHint.TextSize=18
 end)
 return sc
end
-- The guide's original photos, banner and arrow artwork are location cues.
-- Preserve its desktop arrangement; only stack the photo on narrow portrait screens.
function UI.guide(frame,heading,copy)
 local body=frame:FindFirstChild("TextLabel")
 local photo=frame:FindFirstChild("ImageLabel")
 local banner=frame:FindFirstChild("Title ")
 if not body then return end
 local original={position=body.Position,size=body.Size,anchor=body.AnchorPoint}
 local photoOriginal=photo and {position=photo.Position,size=photo.Size,anchor=photo.AnchorPoint,ratio=math.max(.5,photo.AbsoluteSize.X/math.max(1,photo.AbsoluteSize.Y))}
 local bannerOriginal=banner and {position=banner.Position,size=banner.Size,anchor=banner.AnchorPoint}
 local artwork={}
 for _,name in ipairs({"prev","next","close"}) do
  local b=frame:FindFirstChild(name)
  if b then artwork[name]={button=b,position=b.Position,size=b.Size,anchor=b.AnchorPoint} end
 end
 local sc=UI.scroll(frame,"GuideReading")
 -- Legacy label constraints can cap its height even inside a scrolling frame.
 for _,c in ipairs(body:GetChildren()) do
  if c:IsA("UISizeConstraint") or c:IsA("UIAspectRatioConstraint") or c:IsA("UIScale") or c:IsA("UIPadding") then c:Destroy() end
 end
 body.Parent=sc; body.Text=copy; body.AnchorPoint=Vector2.zero; body.Position=UDim2.new(); body.Size=UDim2.new(1,-14,0,0)
 body.LayoutOrder=2; body.Visible=true; body.BackgroundTransparency=1; body.TextXAlignment=Enum.TextXAlignment.Left
 body.TextYAlignment=Enum.TextYAlignment.Top; body.Font=Enum.Font.Gotham; body.LineHeight=1; body.RichText=false
 UI.autoText(body,0,4)
 local layout=sc:FindFirstChildOfClass("UIListLayout")
 local narrow=false
 local function alignReading()
  layout.VerticalAlignment=not narrow and layout.AbsoluteContentSize.Y<=sc.AbsoluteSize.Y-18 and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
 end
 layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(alignReading)
 sc:GetPropertyChangedSignal("AbsoluteSize"):Connect(alignReading)
 local bannerText=banner and banner:FindFirstChildWhichIsA("TextLabel")
 if bannerText then bannerText.Text=heading end
 UI.fit(frame,function(w,h)
  narrow=w<600
  body.TextSize=h<500 and 20 or UI.font(w)
  if narrow then
   sc.AnchorPoint=Vector2.zero; sc.Position=UDim2.fromOffset(20,92); sc.Size=UDim2.new(1,-40,1,-172)
   if photo then
    photo.Parent=sc; photo.AnchorPoint=Vector2.zero; photo.Position=UDim2.new(); photo.LayoutOrder=1
    photo.Size=UDim2.new(1,-12,0,math.min(300,(w-52)/photoOriginal.ratio)); photo.Visible=true
   end
  else
   sc.AnchorPoint=Vector2.new(original.anchor.X,0)
   sc.Position=UDim2.new(original.position.X.Scale,original.position.X.Offset,0,80)
   sc.Size=UDim2.new(original.size.X.Scale,original.size.X.Offset,1,-160)
   if photo then photo.Parent=frame; photo.Position=photoOriginal.position; photo.Size=photoOriginal.size; photo.AnchorPoint=photoOriginal.anchor; photo.Visible=true end
  end
  if banner then
   banner.Visible=true
   if narrow then banner.AnchorPoint=Vector2.new(.5,0); banner.Position=UDim2.new(.5,-12,0,10); banner.Size=UDim2.new(1,-100,0,68)
   else banner.AnchorPoint=bannerOriginal.anchor; banner.Position=bannerOriginal.position; banner.Size=bannerOriginal.size end
  end
  for name,record in pairs(artwork) do
   local b=record.button
   if narrow or h<440 then
    b.AnchorPoint=Vector2.zero; b.Size=UDim2.fromOffset(48,48)
    b.Position=name=="close" and UDim2.new(1,-60,0,12) or (name=="prev" and UDim2.new(0,20,1,-64) or UDim2.new(1,-68,1,-64))
   else b.AnchorPoint=record.anchor; b.Position=record.position; b.Size=record.size end
  end
  alignReading()
 end,650)
end
-- Access notices stay until acknowledged and have room for a concrete next step.
function UI.notice(gui,name)
 UI.screen(gui)
 local shade=Instance.new("Frame",gui); shade.Name=name; shade.Size=UDim2.fromScale(1,1)
 shade.BackgroundColor3=Color3.new(0,0,0); shade.BackgroundTransparency=.35; shade.Visible=false; shade.Active=true
 local panel=Instance.new("Frame",shade); panel.BackgroundColor3=cream
 Instance.new("UICorner",panel).CornerRadius=UDim.new(0,16)
 local sc=UI.scroll(panel)
 UI.label(sc,"Belum bisa dibuka",28,true)
 local message=UI.label(sc,"",22)
 local close=Instance.new("TextButton",sc); close.Size=UDim2.new(1,0,0,52); close.LayoutOrder=100
 UI.action(close,"Mengerti — kembali belajar")
 close.Activated:Connect(function() shade.Visible=false end)
 UI.fit(panel,function()
  sc.Position=UDim2.fromOffset(20,20); sc.Size=UDim2.new(1,-40,1,-40)
 end,420)
 return function(value) message.Text=value; sc.CanvasPosition=Vector2.zero; shade.Visible=true end,function() shade.Visible=false end
end
return UI

end)()
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
 return o:FindFirstChild("Surface") or o:FindFirstChild("HumanoidRootPart",true) or o:FindFirstChildWhichIsA("Seat",true) or o:FindFirstChildWhichIsA("BasePart",true)
end
local cream,brown,brick=Color3.fromRGB(244,221,205),Color3.fromRGB(71,32,3),Color3.fromRGB(153,59,42)
local gui=Instance.new("ScreenGui")
gui.Name="Level2Learning"; gui.ResetOnSpawn=false; gui.DisplayOrder=60; gui.Enabled=false; gui.Parent=pg
UI.screen(gui)
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
local showNotice,hideNotice=UI.notice(noticeGui,"AccessNotice")
local function alert(value)
 showNotice(value.."\n\nSelesaikan langkah tersebut, lalu kembali ke titik ini. Ikuti panah petunjuk; di HP, tahan tombol interaksi pada layar.")
end
local evaluationFooter,evaluationStatus,navigationFooter,practiceFeedback
local evaluationButtons={}
local readingList
local readingPosition=Vector2.zero
local function arrange()
 local w,h=panel.AbsoluteSize.X,panel.AbsoluteSize.Y
 title.TextSize=h<300 and 22 or UI.font(w,true)
 title.TextWrapped=h>=300; title.TextTruncate=h<300 and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
 local titleH=h<300 and 48 or math.max(48,UI.height(title,w-100,8))
 title.Position=UDim2.fromOffset(16,12); title.Size=UDim2.new(1,-88,0,titleH)
 close.Size=UDim2.fromOffset(48,48); close.Position=UDim2.new(1,-62,0,12)
 local footer=navigationFooter or evaluationFooter
 local footerH=footer and 64 or 0
 body.Position=UDim2.fromOffset(16,titleH+26); body.Size=UDim2.new(1,-32,1,-(titleH+42+footerH))
 if footer then footer.Position=UDim2.new(0,16,1,-68); footer.Size=UDim2.new(1,-32,0,52) end
end
UI.fit(panel,arrange)
title:GetPropertyChangedSignal("Text"):Connect(arrange)
local function clear(heading)
 readingPosition=readingList and title.Text==heading and readingList.CanvasPosition or Vector2.zero
 if navigationFooter then navigationFooter:Destroy(); navigationFooter=nil end
 if evaluationFooter then evaluationFooter:Destroy(); evaluationFooter=nil end
 practiceFeedback=nil; evaluationStatus=nil; evaluationButtons={}; readingList=nil
 drag=nil; dragBoard=nil; body:ClearAllChildren(); title.Text=heading
 arrange()
end
local function list()
 readingList=UI.scroll(body)
 if panel.AbsoluteSize.Y<300 then local heading=UI.label(readingList,title.Text,22,true); heading.LayoutOrder=-30 end
 local sc=readingList; local position=readingPosition
 task.defer(function() if sc.Parent then sc.CanvasPosition=position end end)
 return readingList
end
local function text(parent,value,size)
 return UI.label(parent,value,size or UI.font(panel.AbsoluteSize.X))
end
local function button(parent,label,callback,enabled)
 local b=Instance.new("TextButton")
 b.Text=label; b.Size=UDim2.new(1,0,0,56); b.TextWrapped=true
 b.TextSize=UI.font(panel.AbsoluteSize.X); b.Font=Enum.Font.Gotham
 b.TextColor3=brown; b.TextXAlignment=Enum.TextXAlignment.Left
 b.BackgroundColor3=enabled==false and Color3.fromRGB(215,208,202) or Color3.fromRGB(255,247,237)
 b.Active=enabled~=false; b.AutoButtonColor=enabled~=false; b.LayoutOrder=#parent:GetChildren(); b.Parent=parent
 local pad=Instance.new("UIPadding",b)
 pad.PaddingTop=UDim.new(0,14); pad.PaddingBottom=UDim.new(0,14); pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,14)
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
 UI.autoText(b,56,32)
 b.Activated:Connect(function() if enabled~=false then callback() end end)
 return b
end
local function footerButton(parent,label,callback,enabled,right)
 local b=Instance.new("TextButton",parent); UI.action(b,label)
 b.Active=enabled~=false; b.AutoButtonColor=enabled~=false
 b.BackgroundColor3=enabled==false and Color3.fromRGB(140,132,125) or (right and brick or Color3.fromRGB(125,102,90))
 b.Size=UDim2.new(.49,-2,1,0); b.AnchorPoint=Vector2.new(right and 1 or 0,0); b.Position=UDim2.fromScale(right and 1 or 0,0)
 b.TextSize=panel.AbsoluteSize.X<500 and 18 or 21
 b.Activated:Connect(function() if enabled~=false then callback() end end)
 return b
end
local function navigation(leftLabel,leftAction,rightLabel,rightAction,rightEnabled)
 navigationFooter=Instance.new("Frame",panel); navigationFooter.BackgroundTransparency=1
 if leftLabel then footerButton(navigationFooter,leftLabel,leftAction,true,false) end
 if rightLabel then footerButton(navigationFooter,rightLabel,rightAction,rightEnabled,true) end
 arrange()
end
local function practiceStatus(value,done,warning)
 practiceFeedback=text(readingList or list(),value,UI.font(panel.AbsoluteSize.X))
 if done or warning then local sc=readingList; task.defer(function() if sc and sc.Parent then sc.CanvasPosition=Vector2.zero end end) end
 practiceFeedback.Name="PracticeStatus"; practiceFeedback.LayoutOrder=-20
 practiceFeedback.Font=Enum.Font.GothamBold; practiceFeedback.BackgroundTransparency=0
 practiceFeedback.BackgroundColor3=done and Color3.fromRGB(220,240,218) or (warning and Color3.fromRGB(255,233,215) or Color3.fromRGB(250,239,230))
 local pad=Instance.new("UIPadding",practiceFeedback); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12)
 UI.autoText(practiceFeedback,52,28)
 Instance.new("UICorner",practiceFeedback).CornerRadius=UDim.new(0,10)
end
local function evaluationClear(heading,statusText)
 clear(heading)
 local sc=list()
 evaluationStatus=text(sc,statusText or "",UI.font(panel.AbsoluteSize.X)); evaluationStatus.LayoutOrder=-10
 evaluationStatus.TextColor3=Color3.fromRGB(100,70,55)
 evaluationFooter=Instance.new("Frame",panel); evaluationFooter.BackgroundTransparency=1
 arrange()
 return sc
end
local function evaluationAction(label,callback,enabled)
 local b=footerButton(evaluationFooter,label,callback,enabled,true)
 table.insert(evaluationButtons,b)
 if #evaluationButtons==2 then
  local secondary=evaluationButtons[1]; secondary.AnchorPoint=Vector2.zero; secondary.Position=UDim2.new()
  secondary.BackgroundColor3=Color3.fromRGB(125,102,90)
 end
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
 if page==1 then navigation(nil,nil,"Lanjut",function() terms(back,2) end)
 else navigation("Kembali",function() terms(back,1) end,"Tutup",dismiss) end
end
news=function(back)
 clear("Berita Cloud AI Pad — "..state.page.."/3"); state.pages[state.page]=true
 local sc=list(); text(sc,DATA.headings[state.page],26); text(sc,DATA.pages[state.page])
 local previous=state.page>1 and function() state.page-=1; news(back) end or back
 local nextLabel=state.page<3 and "Lanjut" or (back and "Kembali ke latihan" or (state.reviewNews and "Ke kios evaluasi" or "Ke meja bukti"))
 local nextAction=state.page<3 and function() state.page+=1; news(back) end or back or function() state.reviewNews=false; dismiss() end
 navigation(state.page>1 and "Kembali" or (back and "Kembali ke latihan" or nil),previous,nextLabel,nextAction)
end
local function selectedCount()
 local n=0; for i=1,4 do if state.selected[i] then n+=1 end end; return n
end
evidence=function(feedback)
 clear("Latihan 1 — Bukti Teks"); local sc=list()
 text(sc,"Misi: temukan dua bukti",28).Font=Enum.Font.GothamBold
 text(sc,"Ketuk tepat dua kalimat yang membuktikan bahwa cara menjalankan Android dan Windows berbeda. Ketuk lagi untuk membatalkan pilihan. Setelah dua pilihan terisi, tekan Periksa.")
 text(sc,"Bukti dipilih: "..selectedCount().." / 2",20)
 for i,v in ipairs(DATA.evidence) do
  local b=button(sc,(state.selected[i] and "✓ " or "")..v,function()
   if state.done1 then return end
   if state.selected[i] then state.selected[i]=nil elseif selectedCount()<2 then state.selected[i]=true
   else evidence("Pilih dua kalimat saja."); return end
   evidence()
  end)
  b.TextXAlignment=Enum.TextXAlignment.Left; b.Font=Enum.Font.Gotham; b.TextColor3=Color3.fromRGB(48,32,25)
  b.TextStrokeTransparency=1; b.AutoButtonColor=false
  b.BackgroundColor3=state.selected[i] and Color3.fromRGB(185,212,232) or Color3.fromRGB(250,239,230)
  local outline=Instance.new("UIStroke",b); outline.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; outline.Color=state.selected[i] and Color3.fromRGB(66,117,156) or Color3.fromRGB(209,156,116); outline.Thickness=state.selected[i] and 3 or 1
 end
 if state.done1 then
  navigation(nil,nil,"Ke Latihan 2",dismiss)
 else
  navigation("Baca berita",function() news(function() evidence() end) end,"Periksa",function()
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
 practiceStatus(state.done1 and "SELESAI — Kedua bukti tepat. Android dijalankan lokal, sedangkan Windows melalui cloud." or (feedback and ("COBA LAGI — "..feedback) or ("Bukti dipilih: "..selectedCount().." / 2. Pilih dua bukti, lalu tekan Periksa.")),state.done1,feedback~=nil)
end
local function box(pos,size,value)
 local b=Instance.new("TextLabel"); b.Position=pos; b.Size=size; b.Text=value; b.TextWrapped=true
 b.Font=Enum.Font.Gotham; b.TextSize=20; b.TextColor3=brown; b.BackgroundColor3=Color3.fromRGB(250,239,230); b.Parent=body
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,10); return b
end
-- PAIR_SELECTION_BEGIN
local function choosePair(slots,index,value)
 local previous=slots[index]
 if previous==value then slots[index]=nil; return end
 local other=index==1 and 2 or 1
 if slots[other]==value then slots[other]=previous end
 slots[index]=value
end
-- PAIR_SELECTION_END
local pairPage=1
local conclusionOrder={2,1}
pairView=function(feedback)
 clear("Latihan 2 — Simpulan dan Bukti ("..(pairPage==1 and "A" or "B")..")"); local sc=list()
 local index=conclusionOrder[pairPage]
 local function badge(page)
  return (page==pairPage and "▶ " or "")..(page==1 and "A " or "B ")..(state.slots[conclusionOrder[page]] and "●" or "○")
 end
 local count=(state.slots[1] and 1 or 0)+(state.slots[2] and 1 or 0)
 text(sc,badge(1).."     "..badge(2).."     "..count.."/2 terisi",20).Font=Enum.Font.GothamBold
 local conclusion=text(sc,"SIMPULAN "..(pairPage==1 and "A" or "B").."\n"..DATA.conclusions[index],22)
 conclusion.Font=Enum.Font.GothamBold
 text(sc,"Pilih satu bukti yang mendukung simpulan ini.",20)
 for i,quote in ipairs(DATA.pairEvidence) do
  local selected=state.slots[index]==i
  local b=button(sc,(selected and "●  " or "○  ").."Bukti "..i..(selected and " — DIPILIH" or "").."\n"..quote,function()
   if state.done2 then return end
   local other=index==1 and 2 or 1
   local used=state.slots[other]==i
   choosePair(state.slots,index,i)
   pairView(used and "Pilihan diperbarui. Periksa kembali kedua pasangan sebelum mengirim." or nil)
  end)
  b.TextSize=panel.AbsoluteSize.X<600 and 18 or 20
  b.TextColor3=brown
  b.BackgroundColor3=selected and Color3.fromRGB(210,231,248) or Color3.fromRGB(255,247,237)
  local edge=Instance.new("UIStroke",b); edge.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  edge.Color=selected and Color3.fromRGB(40,100,155) or Color3.fromRGB(209,180,155); edge.Thickness=selected and 3 or 1
 end
 local statusText=state.done2 and "✓ Kedua pasangan tepat. Latihan selesai." or feedback or (state.slots[index] and "● Bukti dipilih. Kamu dapat mengganti pilihan sebelum Periksa." or "○ Belum ada bukti yang dipilih untuk simpulan ini.")
 local statusLabel=text(sc,statusText,18); statusLabel.Font=Enum.Font.GothamBold
 statusLabel.TextColor3=state.done2 and Color3.fromRGB(40,115,65) or Color3.fromRGB(55,80,105)
 if pairPage==1 then
  navigation("Baca berita",function() news(function() pairView() end) end,"Ke pasangan B →",function() pairPage=2; readingPosition=Vector2.zero; pairView() end,state.slots[index]~=nil)
 else
  navigation("← Pasangan A",function() pairPage=1; readingPosition=Vector2.zero; pairView() end,state.done2 and "Ke kios evaluasi" or (count<2 and "Lengkapi pasangan A" or "Periksa pasangan"),function()
   if state.done2 then dismiss(); return end
   if count<2 then pairPage=1; pairView(); return end
   recordLearning("practice",{activity="pairs",choices={state.slots[1],state.slots[2]},help=state.help2})
   if state.slots[1]==1 and state.slots[2]==2 then state.done2=true; pairView() else
    state.errors2+=1; if state.errors2>=2 then state.help2=true end
    pairView("BELUM TEPAT — Tinjau pasangan A dan B. Cari bukti cara menjalankan OS untuk simpulan pemasangan, dan bukti kebutuhan pengguna untuk simpulan manfaat.")
   end
  end,true)
 end
 if feedback or state.done2 then statusLabel.LayoutOrder=-15; task.defer(function() if sc.Parent then sc.CanvasPosition=Vector2.zero end end) end
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
 local passed=result.score>=75
 title.Text="Level 2 — "..(passed and "Lulus" or "Belum lulus")
 evaluationStatus.Text=passed and "Selamat! Nilai jawabanmu memenuhi batas kelulusan 75." or "Nilai jawabanmu belum mencapai 75. Kamu dapat belajar kembali atau mencoba evaluasi lagi."
 if passed then
  local oldGui=pg:FindFirstChild("Level1Gui")
  local oldQuiz=oldGui and oldGui:FindFirstChild("quizFrame")
  local background=oldQuiz and oldQuiz:FindFirstChild("ResultBackground")
  local success=background and background:FindFirstChild("ResultLulus")
  local original=success and success:FindFirstChildWhichIsA("ImageLabel")
  if original then local crown=original:Clone(); crown.Name="ResultCrown"; crown.BackgroundTransparency=1; crown.BorderSizePixel=0; crown.Size=UDim2.new(1,0,0,78); crown.ScaleType=Enum.ScaleType.Fit; crown.LayoutOrder=-20; crown.Visible=true; crown.Parent=sc end
 end
 local score=text(sc,result.score.." / 100",panel.AbsoluteSize.X<600 and 38 or 46)
 score.Font=Enum.Font.GothamBold; score.TextXAlignment=Enum.TextXAlignment.Center; score.BackgroundTransparency=1; score.BorderSizePixel=0
 UI.autoText(score,72,8)
 text(sc,"Jawaban tepat: "..(result.score/25).." dari 4     •     Alasan tepat: "..result.reasons.." dari 4",20)
 text(sc,"Kelulusan ditentukan oleh skor jawaban. Ketepatan alasan dicatat terpisah.",18)
 text(sc,"Nilai terbaik sesi: "..result.best.." / 100",18)
 if not passed and result.unlocked then text(sc,"Akses berikutnya tetap terbuka karena kamu sudah lulus pada percobaan sebelumnya.",18) end
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
 local sc=evaluationClear("Evaluasi "..attempt.index.."/4 — "..(attempt.tier==1 and "Jawaban" or "Alasan"),attempt.feedback and "Baca penjelasan sebelum melanjutkan." or (attempt.selection and "Pilihan siap dikonfirmasi." or "Pilih satu opsi terlebih dahulu."))
 if attempt.feedback then
  text(sc,q.feedback[attempt.answers[attempt.index]].message)
  text(sc,q.feedback[5+attempt.reasons[attempt.index]].message)
  evaluationAction(attempt.index==4 and "Lihat hasil" or "Soal berikutnya",function()
   if attempt.index==4 then submit() else attempt.index+=1; attempt.tier=1; attempt.selection=nil; attempt.feedback=false; question() end
  end); return
 end
 text(sc,q.stem,26).Font=Enum.Font.GothamBold
 if attempt.tier==2 then text(sc,"Jawaban yang dipilih: "..q.options[attempt.answers[attempt.index]]); text(sc,q.reasonStem) end
 for i,v in ipairs(attempt.tier==1 and q.options or q.reasons) do
  local b=button(sc,v,function() attempt.selection=i; question() end)
  b.TextSize=24; b.Font=Enum.Font.Gotham; b.TextColor3=Color3.fromRGB(70,47,37)
  b.TextXAlignment=Enum.TextXAlignment.Left
  b.BackgroundColor3=attempt.selection==i and Color3.fromRGB(103,151,199) or Color3.fromRGB(232,210,196)
 end
 evaluationAction(attempt.tier==1 and "Lanjut ke alasan" or "Kirim jawaban",function()
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
 text(sc,"Empat soal. Pilih jawaban, tekan Lanjut ke alasan, lalu pilih alasan. Penjelasan muncul setelah keduanya dikirim. Jawaban tepat bernilai 25; minimal 75 untuk melanjutkan. Alasan ditampilkan terpisah. Selama evaluasi materi dan bantuan tidak dibuka.")
 evaluationAction("Nanti dulu",dismiss)
 evaluationAction("Mulai evaluasi",function() state.reviewNews=false; attempt={id=Http:GenerateGUID(false),index=1,tier=1,answers={},reasons={}}; question() end)
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
  evaluationAction("Batalkan percobaan",function() attempt=nil; dismiss() end); evaluationAction("Lanjut mengerjakan",question)
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
  clear("Level 2 — Keterampilan Membaca"); local sc=list(); text(sc,"SELAMAT DATANG",20).TextColor3=brick
  text(sc,"Baca berita, temukan bukti, lalu tarik simpulan.",30).Font=Enum.Font.GothamBold
  text(sc,"1. Baca tiga bagian berita Cloud AI Pad.\n\n2. Pilih dua bukti teks, lalu pasangkan simpulan dengan bukti.\n\n3. Jawab empat soal evaluasi beserta alasannya. Raih nilai minimal 75 untuk membuka Level 3.")
  navigation(nil,nil,"Mulai",function()
   state.intro=true; dismiss()
  end); return
 end
 if key=="news" then state.page=state.reviewNews and 1 or unreadPage(); news() elseif key=="evidence" then evidence() elseif key=="pairs" then pairView() else exam() end
end
local function bind(s)
 local obj=stationObject(s); if not obj then return end
 if s.prompt and s.prompt:IsDescendantOf(obj) then return end
 if s.key=="exam" then
  for _,clothing in ipairs(obj:GetDescendants()) do
   if clothing:IsA("Shirt") then clothing.ShirtTemplate="http://www.roblox.com/asset/?id=10285081830"
   elseif clothing:IsA("Pants") then clothing.PantsTemplate="http://www.roblox.com/asset/?id=10297918623" end
  end
 end
 local part=partOf(obj); if not part then return end
 local a=Instance.new("Attachment"); a.Name="L2LearningAnchor"
 if obj:IsA("Model") and s.key~="intro" and s.path[1]~="Kursi Baru" then
  local bounds=obj:GetBoundingBox(); a.Position=part.CFrame:PointToObjectSpace(bounds.Position)
 else a.Position=Vector3.new(0,1,0) end
 if s.key=="news" and obj:IsA("MeshPart") then
  -- The existing news board is one tall MeshPart, not a Model. Keep E reachable
  -- from the floor rather than placing it above the centre of the whole mesh.
  local cf,size=part.CFrame,part.Size
  local halfHeight=(math.abs(cf.RightVector.Y)*size.X+math.abs(cf.UpVector.Y)*size.Y+math.abs(cf.LookVector.Y)*size.Z)/2
  a.Position=cf:PointToObjectSpace(part.Position-Vector3.new(0,math.max(0,halfHeight-3),0))
 end
 a.Parent=part

 local p=Instance.new("ProximityPrompt")
 p.Name="L2LearningPrompt"; p.ActionText=s.action; p.ObjectText=s.title; p.KeyboardKeyCode=Enum.KeyCode.E
 p.HoldDuration=1; p.MaxActivationDistance=10; p.RequiresLineOfSight=false; p.Enabled=not gui.Enabled; p.Parent=a; s.prompt=p
 p.Triggered:Connect(function(who)
  if who and who~=player then return end; if gui.Enabled then return end
  local reason=prerequisite(s.key)
  if reason then alert(reason); refreshGuide(); return end
  hideNotice()
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
