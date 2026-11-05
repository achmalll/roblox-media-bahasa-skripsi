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
-- Source template; build with scripts/build-level3.cjs. Session-local learning state.
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Input = game:GetService("UserInputService")
local DATA = Http:JSONDecode([==[{"intro":"Selamat datang di Level 3 — Keterampilan Membaca Lanjutan.\n\nPada level ini, Anda akan membaca sebuah teks abstrak ilmiah yang membahas evolusi sistem operasi modern serta pergeseran dari pendekatan process-centric menuju data-centric.\n\nBacalah dengan saksama dan perhatikan hubungan antargagasan dalam setiap paragraf. Papan istilah tersedia bila diperlukan.\n\nSetelah membaca, susun fungsi gagasan dan tuntaskan empat ronde pemeriksaan simpulan berdasarkan bukti, lalu kerjakan empat soal evaluasi.\n\nTekan Mulai untuk menuju meja abstrak.","terms":["Inersia sistem operasi\n\nKecenderungan sistem operasi dan model pemrograman lama mempertahankan desain serta pendekatan tradisional meskipun teknologi perangkat keras berkembang.\n\nOverhead\n\nBeban tambahan untuk mendukung proses utama; pada bacaan muncul melalui lapisan kompatibilitas, pengelolaan kernel atau serialisasi.\n\nThroughput dan latensi\n\nThroughput: jumlah pekerjaan/data yang diproses per satuan waktu. Latensi: waktu untuk merespons permintaan.","Kernel\n\nInti dari sistem operasi.\n\nPersistensi data\n\nKemampuan data tetap tersimpan meskipun sistem dimatikan atau proses selesai.\n\nMemori bersama\n\nMekanisme beberapa proses atau node mengakses area memori yang sama untuk pertukaran data."],"pages":["Sistem operasi dibangun dan dirancang berdasarkan dua kekuatan utama, yaitu kapabilitas perangkat keras dan tuntutan perangkat lunak. Namun, sistem operasi dan model pemrograman tradisional memiliki inersia, sehingga antarmuka untuk perangkat keras baru cenderung mengikuti desain antarmuka yang telah ada sebelumnya. Akibatnya, programmer menjadi terbatas dalam mengekspresikan bagian-bagian penting dari program mereka karena adanya lapisan kompatibilitas dan overhead yang terus dipertahankan, meskipun tuntutan terhadap throughput yang lebih tinggi dan latency yang lebih rendah terus meningkat. Oleh karena itu, abstraksi sistem operasi perlu berevolusi mengikuti perkembangan zaman, karena ketergantungan pada abstraksi lama yang berusia puluhan tahun serta perubahan yang bersifat inkremental berpotensi membatasi pemanfaatan perangkat keras modern hanya melalui antarmuka yang awalnya dirancang untuk media penyimpanan lama seperti pita magnetik dan spinning disk.","Saat ini, terdapat peluang untuk mengkaji bagaimana pertemuan berbagai tren dapat menggeser model pemrograman dari sudut pandang tradisional yang berpusat pada proses (process-centric) menuju pendekatan yang berpusat pada data (data-centric), di mana data menjadi entitas utama dalam sistem. Peluang ini muncul seiring dengan perkembangan perangkat keras yang secara langsung memengaruhi cara pandang terhadap jalur akses data serta tanggung jawab sistem operasi dan kernel. Meningkatnya kecepatan teknologi interkoneksi memperkecil jarak latensi antar node komputasi, sehingga meningkatkan efisiensi dan kegunaan shared memory. Selain itu, penyimpanan persisten yang sebelumnya berada di lapisan bawah hierarki memori kini bergerak ke lapisan yang lebih tinggi seiring meningkatnya kecepatan akses perangkat persisten. Kondisi ini menyebabkan overhead jalur akses data berbasis kernel tradisional menjadi faktor dominan dalam biaya akses data persisten. Di sisi lain, meningkatnya heterogenitas serta pemisahan (disaggregation) antara perangkat komputasi dan memori menuntut mobilitas data dan komputasi yang lebih tinggi agar perangkat lunak tetap skalabel, terdistribusi, dan memiliki kinerja tinggi.\n\nDisertasi ini memperkenalkan sistem operasi dan model pemrograman baru yang berorientasi pada data (data-centric), yang dirancang berdasarkan tren-tren tersebut. Pendekatan ini merumuskan ulang tujuan sistem operasi dan memungkinkan peninjauan kembali teknik pemrograman sistem klasik ke dalam model yang memfasilitasi berbagi data, alih-alih menghambatnya. Model pemrograman sistem tradisional umumnya melibatkan kompleksitas dan overhead yang signifikan dalam pengelolaan persistensi dan berbagi data, seperti operasi persistensi berbutir kasar yang mahal, model data RPC yang kaku, serta kebutuhan serialisasi. Sebaliknya, pendekatan data-centric ini mengurangi keterlibatan kernel dalam jalur akses data, menjadikan data bersifat mobile melalui referensi invarian yang tidak bergantung pada ruang alamat atau mesin, serta menghilangkan kebutuhan akan serialisasi.","Penelitian ini membahas motivasi dan tren perangkat keras yang melatarbelakangi perancangan sistem tersebut, mendefinisikan ruang desain berdasarkan tren tersebut, serta memperkenalkan Twizzler sebagai salah satu implementasi dalam ruang desain tersebut yang merepresentasikan prinsip-prinsip yang diusulkan. Evaluasi terhadap Twizzler dilakukan melalui studi kasus yang menunjukkan perilaku sistem, efektivitas, dan kegunaan model pemrograman yang dikembangkan, dengan membangun sejumlah perangkat lunak baru khusus untuk Twizzler. Selain itu, aplikasi berukuran besar yang telah di-porting juga digunakan untuk menunjukkan kinerja Twizzler dan model pemrogramannya, yang dalam banyak kasus menunjukkan peningkatan performa semata-mata karena penyederhanaan lapisan perangkat lunak."],"headings":["Masalah dan motivasi","Tren perangkat keras dan pendekatan","Implementasi dan evaluasi"],"questions":[{"number":1,"stem":"Menurut abstrak, faktor utama yang mendorong pergeseran dari model process-centric menuju data-centric adalah …","options":["A. Meningkatnya kebutuhan antarmuka grafis pada sistem operasi","B. Perkembangan bahasa pemrograman tingkat tinggi","C. Tuntutan kompatibilitas perangkat lunak lintas platform","D. Tren perangkat keras seperti peningkatan kecepatan interkoneksi dan penyimpanan persisten","E. Dominasi sistem operasi berbasis mobile"],"key1":"Kunci tier 1: D. Batang, opsi, dan kunci mengikuti baseline Sanubari.","reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Abstrak menekankan perubahan antarmuka grafis sebagai pendorong perubahan model sistem operasi.","B. Abstrak menekankan kemunculan bahasa pemrograman baru sebagai pendorong perubahan model sistem operasi.","C. Abstrak mengaitkan perubahan model dengan interkoneksi cepat dan akses penyimpanan persisten.","D. Abstrak menekankan penggantian seluruh server oleh perangkat mobile sebagai pendorong perubahan model."],"key2":"Kunci tier 2: C. Bukti penjelas: Abstrak mengaitkan perubahan model dengan interkoneksi cepat dan akses penyimpanan persisten.","feedback":[{"label":"Tier 1 pilihan A","message":"Pendorong yang disebut abstrak adalah tren perangkat keras, bukan kebutuhan tampilan grafis."},{"label":"Tier 1 pilihan B","message":"Bahasa pemrograman baru bukan faktor utama yang disebut abstrak."},{"label":"Tier 1 pilihan C","message":"Kompatibilitas dibahas sebagai keterbatasan model lama, bukan tren utama yang ditanyakan."},{"label":"Tier 1 pilihan D","message":"Benar. Interkoneksi cepat dan penyimpanan persisten termasuk tren yang dibahas."},{"label":"Tier 1 pilihan E","message":"Dominasi OS mobile tidak menjadi pendorong yang dinyatakan abstrak."},{"label":"Tier 2 pilihan A","message":"Alasan A berfokus pada grafis yang tidak menjadi motivasi utama abstrak."},{"label":"Tier 2 pilihan B","message":"Alasan B berfokus pada bahasa pemrograman yang tidak menjadi tren utama pada teks."},{"label":"Tier 2 pilihan C","message":"Alasan C tepat: perubahan model dikaitkan dengan interkoneksi dan penyimpanan persisten."},{"label":"Tier 2 pilihan D","message":"Alasan D menambahkan penggantian semua server oleh mobile tanpa bukti."}]},{"number":2,"stem":"Keunggulan utama pendekatan data-centric yang diperkenalkan melalui sistem Twizzler dibandingkan pendekatan tradisional adalah …","options":["A. Penggunaan kernel yang lebih kompleks untuk mengatur data","B. Penggunaan model RPC yang lebih ketat dan terstruktur","C. Penghapusan sepenuhnya peran kernel dalam sistem operasi","D. Ketergantungan penuh pada teknologi virtualisasi","E. Penyederhanaan jalur akses data dan pengurangan kebutuhan serialisasi"],"key1":"Kunci tier 1: E. Batang, opsi, dan kunci mengikuti baseline Sanubari.","reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Abstrak menjelaskan penyederhanaan akses data dan penghilangan kebutuhan serialisasi.","B. Abstrak menjelaskan penghapusan seluruh peran kernel dalam pengelolaan sistem komputer.","C. Abstrak menjelaskan pengetatan mekanisme RPC dalam pertukaran data antarprogram komputer.","D. Abstrak menjelaskan kewajiban virtualisasi untuk menjalankan setiap aplikasi dalam sistem."],"key2":"Kunci tier 2: A. Bukti penjelas: Abstrak menjelaskan penyederhanaan jalur akses data dan hilangnya kebutuhan serialisasi dalam pendekatan yang dibahas.","feedback":[{"label":"Tier 1 pilihan A","message":"Abstrak menekankan penyederhanaan akses data, bukan membuat kernel lebih kompleks."},{"label":"Tier 1 pilihan B","message":"RPC yang kaku disebut sebagai beban model tradisional, bukan keunggulan pendekatan baru."},{"label":"Tier 1 pilihan C","message":"Mengurangi keterlibatan kernel pada jalur akses data tidak berarti seluruh fungsi kernel dihapus."},{"label":"Tier 1 pilihan D","message":"Ketergantungan penuh pada virtualisasi bukan keunggulan yang disebut abstrak."},{"label":"Tier 1 pilihan E","message":"Benar. Penyederhanaan akses data dan pengurangan kebutuhan serialisasi sesuai abstrak."},{"label":"Tier 2 pilihan A","message":"Alasan A tepat: akses data dan serialisasi merupakan perubahan yang dijelaskan."},{"label":"Tier 2 pilihan B","message":"Alasan B melebihkan pengurangan keterlibatan kernel menjadi penghapusan semua perannya."},{"label":"Tier 2 pilihan C","message":"Alasan C memilih RPC yang kaku, padahal kekakuan itu disebut sebagai beban tradisional."},{"label":"Tier 2 pilihan D","message":"Alasan D mensyaratkan virtualisasi pada semua aplikasi tanpa dukungan abstrak."}]},{"number":3,"stem":"Mengapa model pemrograman tradisional dianggap kurang sesuai dengan perkembangan perangkat keras modern?","options":["A. Karena model tradisional menimbulkan overhead dan keterbatasan yang menghambat pemanfaatan perangkat keras modern secara optimal","B. Karena perangkat keras modern tidak lagi membutuhkan sistem operasi","C. Karena perangkat keras modern hanya mendukung sistem operasi berbasis cloud","D. Karena semua aplikasi modern menggunakan bahasa pemrograman baru","E. Karena sistem operasi modern tidak memerlukan kernel"],"key1":"Kunci tier 1: A. Batang, opsi, dan kunci mengikuti baseline Sanubari.","reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Abstrak menyatakan perangkat modern dapat bekerja tanpa menggunakan sistem operasi.","B. Abstrak mengaitkan lapisan kompatibilitas dan overhead dengan keterbatasan perangkat baru.","C. Abstrak menyatakan perangkat modern hanya dapat bekerja melalui layanan berbasis cloud.","D. Abstrak menyatakan antarmuka lama selalu optimal untuk memanfaatkan kemampuan perangkat modern."],"key2":"Kunci tier 2: B. Bukti penjelas: Abstrak mengaitkan lapisan kompatibilitas dan overhead model lama dengan keterbatasan pemanfaatan perangkat baru.","feedback":[{"label":"Tier 1 pilihan A","message":"Benar. Lapisan kompatibilitas dan overhead membatasi pemanfaatan perangkat keras modern."},{"label":"Tier 1 pilihan B","message":"Abstrak mengusulkan perubahan pendekatan OS, bukan menghapus kebutuhan OS."},{"label":"Tier 1 pilihan C","message":"Pembahasan perangkat keras modern tidak dibatasi pada perangkat berbasis cloud."},{"label":"Tier 1 pilihan D","message":"Abstrak tidak mengaitkan masalah utama dengan semua aplikasi memakai bahasa baru."},{"label":"Tier 1 pilihan E","message":"Abstrak mengkritik jalur akses dan overhead, bukan menyatakan kernel tidak diperlukan."},{"label":"Tier 2 pilihan A","message":"Alasan A mengubah kritik model lama menjadi klaim semua perangkat tanpa OS."},{"label":"Tier 2 pilihan B","message":"Alasan B tepat: keterbatasan dijelaskan melalui lapisan kompatibilitas dan overhead."},{"label":"Tier 2 pilihan C","message":"Alasan C membatasi perangkat modern pada cloud tanpa dukungan abstrak."},{"label":"Tier 2 pilihan D","message":"Alasan D bertentangan dengan kritik terhadap antarmuka lama dalam teks."}]},{"number":4,"stem":"Berdasarkan evaluasi yang dijelaskan dalam abstrak, kesimpulan manakah yang paling dapat dipertanggungjawabkan?","options":["A. Twizzler harus mengganti semua OS modern.","B. Kinerja Twizzler selalu unggul pada seluruh aplikasi.","C. Studi kasus dan beberapa aplikasi menunjukkan kegunaan serta peningkatan kinerja pada konteks yang diuji.","D. Seluruh peran kernel sudah tidak diperlukan.","E. Semua komputer telah memakai Twizzler."],"key1":"Kunci tier 1: C. Soal dan kunci merupakan usulan pengganti baseline untuk ditelaah ahli.","reasonStem":"Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?","reasons":["A. Abstrak melaporkan pengujian seluruh aplikasi dan mesin sehingga hasilnya dapat digeneralisasikan.","B. Abstrak menetapkan Twizzler sebagai standar wajib yang harus diterapkan pada seluruh komputer.","C. Abstrak membuktikan seluruh OS komersial lebih lambat daripada Twizzler dalam setiap kondisi.","D. Abstrak melaporkan kasus dan aplikasi tertentu sehingga kesimpulannya belum berlaku universal."],"key2":"Kunci tier 2: D. Bukti penjelas: Abstrak melaporkan studi kasus dan aplikasi tertentu sehingga generalisasi universal belum dapat disimpulkan.","feedback":[{"label":"Tier 1 pilihan A","message":"Studi kasus belum membenarkan kewajiban mengganti semua OS modern."},{"label":"Tier 1 pilihan B","message":"Hasil pada beberapa aplikasi tidak berarti selalu unggul pada seluruh aplikasi."},{"label":"Tier 1 pilihan C","message":"Benar. Kesimpulan dibatasi pada kegunaan dan peningkatan kinerja dalam konteks yang diuji."},{"label":"Tier 1 pilihan D","message":"Pengurangan keterlibatan kernel pada akses data tidak menghapus seluruh peran kernel."},{"label":"Tier 1 pilihan E","message":"Abstrak tidak menyatakan semua komputer telah menggunakan Twizzler."},{"label":"Tier 2 pilihan A","message":"Alasan A memperluas pengujian beberapa kasus menjadi seluruh aplikasi dan mesin."},{"label":"Tier 2 pilihan B","message":"Alasan B menambahkan penetapan standar wajib yang tidak disimpulkan abstrak."},{"label":"Tier 2 pilihan C","message":"Alasan C mengklaim perbandingan universal dengan semua OS komersial tanpa bukti."},{"label":"Tier 2 pilihan D","message":"Alasan D tepat: bukti studi kasus membatasi cakupan kesimpulan yang dapat ditarik."}]}],"rounds":[{"id":1,"title":"Kendala dalam bacaan","paragraph":1,"skill":"Menemukan akibat yang dinyatakan teks dan membedakannya dari akibat yang dibesar-besarkan.","instruction":"Coret akibat yang berlebihan. Tunjuk kalimat tentang keterbatasan programmer.","sourceIds":[1,3],"parts":["Lapisan kompatibilitas dan overhead membatasi programmer dalam mengekspresikan bagian penting program,","meskipun tuntutan throughput lebih tinggi dan latensi lebih rendah meningkat;","akibatnya peningkatan perangkat keras tidak memberi manfaat apa pun."],"keyPart":3,"keyEvidence":2,"final":"Lapisan kompatibilitas dan overhead membatasi programmer dalam mengekspresikan bagian penting program, meskipun tuntutan throughput lebih tinggi dan latensi lebih rendah meningkat.","hint":"Bacaan menjelaskan keterbatasan, bukan ketiadaan seluruh manfaat perangkat keras.","wrongEvidence":"Kalimat yang dipilih menjelaskan dasar perancangan sistem. Cari akibat lapisan kompatibilitas terhadap programmer.","proof":"programmer menjadi terbatas","evidence":["Sistem operasi dibangun dan dirancang berdasarkan dua kekuatan utama, yaitu kapabilitas perangkat keras dan tuntutan perangkat lunak.","Akibatnya, programmer menjadi terbatas dalam mengekspresikan bagian-bagian penting dari program mereka karena adanya lapisan kompatibilitas dan overhead yang terus dipertahankan, meskipun tuntutan terhadap throughput yang lebih tinggi dan latency yang lebih rendah terus meningkat."]},{"id":2,"title":"Peluang bukan hasil yang sudah terjadi","paragraph":2,"skill":"Membedakan status peluang kajian dari klaim bahwa perubahan telah berlaku menyeluruh.","instruction":"Coret klaim perubahan yang sudah pasti terjadi. Tunjuk kalimat tentang peluang pergeseran model.","sourceIds":[1,2],"parts":["Peralihan ke data-centric telah terjadi pada seluruh sistem operasi;","abstrak menyebut peluang mengkaji pergeseran model pemrograman","seiring pertemuan berbagai tren perangkat keras."],"keyPart":1,"keyEvidence":1,"final":"Abstrak menyebut peluang mengkaji pergeseran model pemrograman seiring pertemuan berbagai tren perangkat keras.","hint":"Perhatikan status pernyataan: peluang untuk mengkaji tidak sama dengan perubahan menyeluruh yang telah selesai.","wrongEvidence":"Kalimat itu menjelaskan latar perkembangan perangkat keras. Cari kalimat yang menyatakan status peluang dan arah pergeseran model.","proof":"terdapat peluang untuk mengkaji","evidence":["Saat ini, terdapat peluang untuk mengkaji bagaimana pertemuan berbagai tren dapat menggeser model pemrograman dari sudut pandang tradisional yang berpusat pada proses (process-centric) menuju pendekatan yang berpusat pada data (data-centric), di mana data menjadi entitas utama dalam sistem.","Peluang ini muncul seiring dengan perkembangan perangkat keras yang secara langsung memengaruhi cara pandang terhadap jalur akses data serta tanggung jawab sistem operasi dan kernel."]},{"id":3,"title":"Batas perubahan yang diusulkan","paragraph":3,"skill":"Menghubungkan dua perubahan yang disebut teks dan menolak generalisasi di luar cakupannya.","instruction":"Coret perubahan yang tidak didukung. Tunjuk kalimat yang menyebut kernel dan serialisasi.","sourceIds":[2,4],"parts":["Pendekatan data-centric mengurangi keterlibatan kernel dalam jalur akses data,","menghilangkan seluruh kompleksitas dan biaya dalam setiap sistem operasi,","serta menghilangkan kebutuhan serialisasi pada model yang dijelaskan."],"keyPart":2,"keyEvidence":2,"final":"Pendekatan data-centric mengurangi keterlibatan kernel dalam jalur akses data serta menghilangkan kebutuhan serialisasi pada model yang dijelaskan.","hint":"Teks menyebut perubahan tertentu, bukan penghapusan seluruh kompleksitas dan biaya pada setiap sistem.","wrongEvidence":"Kalimat itu menyebut tujuan memfasilitasi berbagi data. Cari kalimat yang memuat dua perubahan khusus: kernel dan serialisasi.","proof":"mengurangi keterlibatan kernel","evidence":["Pendekatan ini merumuskan ulang tujuan sistem operasi dan memungkinkan peninjauan kembali teknik pemrograman sistem klasik ke dalam model yang memfasilitasi berbagi data, alih-alih menghambatnya.","Sebaliknya, pendekatan data-centric ini mengurangi keterlibatan kernel dalam jalur akses data, menjadikan data bersifat mobile melalui referensi invarian yang tidak bergantung pada ruang alamat atau mesin, serta menghilangkan kebutuhan akan serialisasi."]},{"id":4,"title":"Hasil penelitian dan batas simpulan","paragraph":4,"skill":"Membedakan hasil kinerja yang dilaporkan dari rekomendasi universal yang tidak didukung.","instruction":"Coret rekomendasi yang melampaui bukti. Tunjuk kalimat yang mendukung hasil kinerja.","sourceIds":[2,3],"parts":["Pada banyak kasus yang dilaporkan,","Twizzler menunjukkan peningkatan performa;","karena itu seluruh sistem operasi wajib diganti."],"keyPart":3,"keyEvidence":2,"final":"Pada banyak kasus yang dilaporkan, Twizzler menunjukkan peningkatan performa.","hint":"Hasil pada banyak kasus tidak menetapkan kewajiban mengganti seluruh sistem operasi.","wrongEvidence":"Kalimat itu menjelaskan pengujian melalui studi kasus. Cari kalimat yang secara khusus menyebut hasil peningkatan kinerja.","proof":"dalam banyak kasus","evidence":["Evaluasi terhadap Twizzler dilakukan melalui studi kasus yang menunjukkan perilaku sistem, efektivitas, dan kegunaan model pemrograman yang dikembangkan, dengan membangun sejumlah perangkat lunak baru khusus untuk Twizzler.","Selain itu, aplikasi berukuran besar yang telah di-porting juga digunakan untuk menunjukkan kinerja Twizzler dan model pemrogramannya, yang dalam banyak kasus menunjukkan peningkatan performa semata-mata karena penyederhanaan lapisan perangkat lunak."]}],"cards":["Lapisan kompatibilitas dan overhead membatasi pemanfaatan perangkat keras modern.","Pendekatan data-centric dirancang untuk memudahkan berbagi data dan mengurangi beban akses data.","Twizzler dievaluasi melalui studi kasus dan aplikasi yang di-porting."]}]==])
local player = Players.LocalPlayer
-- Research records are server-timed; no player names or free text are sent.
local recordHttp = game:GetService("HttpService")
local function recordLearning(op, fields)
 local remote=game:GetService("ReplicatedStorage"):FindFirstChild("LearningRecordEvent")
 if not remote then return end
 fields=fields or {}; fields.op=op; fields.level=3; fields.id=fields.id or recordHttp:GenerateGUID(false)
 remote:FireServer(fields)
end

local pg = player:WaitForChild("PlayerGui")
local legacy=pg:WaitForChild("Level3Gui"); legacy.Enabled=false
local readingScroll={}

local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerControlHandler"))
local event = game:GetService("ReplicatedStorage"):WaitForChild("UpdateLevel3Score")
local progress = player:WaitForChild("leaderstats"):WaitForChild("LevelProgress")
local state = {intro=false,pages={},page=1,selected={},done1=false,done2=false,slots={},errors1=0,errors2=0,help1=false,help2=false,round=1,rounds={}}
local attempt, result, activePrompt, drag, dragBoard
local stations = {
 {path={"Space 3",""},key="intro",title="Pemandu Level 3",action="Bicara"},
 {path={"Level3Development","meja baca"},key="news",title="Abstrak Twizzler",action="Baca abstrak"},
 {path={"Space 3","Infoboard"},key="terms",title="Istilah dalam abstrak",action="Lihat istilah"},
 {path={"Level3Development","latihan 1"},key="evidence",title="Latihan 1 — Fungsi gagasan",action="Buka latihan"},
 {path={"Level3Development","latihan 2"},key="pairs",title="Latihan 2 — Batas simpulan",action="Buka latihan"},
 {path={"Level3Development","L3_NPC_PemanduBaca"},key="news",title="Pemandu abstrak",action="Baca abstrak"},
 {path={"Level3Development","L3_NPC_FungsiGagasan"},key="evidence",title="Fungsi gagasan",action="Buka latihan"},
 {path={"Level3Development","L3_NPC_BatasSimpulan"},key="pairs",title="Batas simpulan",action="Buka latihan"},
 {path={"Level3Development","L3_NPC_EvaluasiPria"},key="exam",title="Evaluasi Level 3",action="Buka evaluasi"},
 {path={"Level3Development","L3_NPC_EvaluasiWanita"},key="exam",title="Evaluasi Level 3",action="Buka evaluasi"},
 {path={"Level3Development","Evaluasi"},key="exam",title="Evaluasi Level 3",action="Buka evaluasi"},
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
gui.Name="Level3Learning"; gui.ResetOnSpawn=false; gui.DisplayOrder=60; gui.Enabled=false; gui.Parent=pg
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
noticeGui.Name="L3StageNotice"; noticeGui.ResetOnSpawn=false; noticeGui.DisplayOrder=70; noticeGui.Parent=pg
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
 player:SetAttribute("L3LearningOpen",false)
 refreshGuide()
end
local function message(heading,value)
 clear(heading); local sc=list(); text(sc,value); return sc
end
-- FLOW_RULES_BEGIN: shared verbatim with the Luau flow regression harness.
local function functionsCorrect(slots)
 return slots[1]==1 and slots[2]==2 and slots[3]==3
end
local function editorCorrect(r,part,evidence)
 return part==r.keyPart,evidence==r.keyEvidence
end
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
 if progress.Value<3 then return "Selesaikan Level 2 dengan nilai minimal 75 terlebih dahulu." end
 if key=="intro" or key=="terms" then return nil end
 if not state.intro then return "Temui pemandu Level 3 dan tekan Mulai terlebih dahulu." end
 if key=="news" then return nil end
 if not allRead() then return "Baca abstrak terlebih dahulu. Bagian "..unreadPage().."/3 belum dikunjungi. Ikuti panah ke meja abstrak." end
 if key=="evidence" then return nil end
 if not state.done1 then return "Selesaikan Latihan 1 — Fungsi gagasan terlebih dahulu. Ikuti panah ke papan gagasan." end
 if key=="pairs" then return nil end
 if not state.done2 then return "Selesaikan Latihan 2 — Batas simpulan terlebih dahulu. Ikuti panah ke papan batas simpulan." end
 return nil
end
-- FLOW_RULES_END
refreshGuide=function()
 if progress.Value~=3 then player:SetAttribute("L3GuideTarget",nil); return end
 local destination
 for _,s in ipairs(stations) do if s.key==stage() then
  local o=stationObject(s)
  local part=partOf(o)
  if part then
   destination=s.prompt and s.prompt.Parent and s.prompt.Parent:IsA("Attachment") and s.prompt.Parent.WorldPosition or part.Position
   break
  end
 end end
 player:SetAttribute("L3GuideStage",stage())
 player:SetAttribute("L3GuideTarget",destination)
end
local function terms(back,page)
 page=page or 1
 clear("Istilah dalam bacaan — "..page.."/2"); local sc=list()
 text(sc,DATA.terms[page])
 if page==1 then navigation(nil,nil,"Lanjut",function() terms(back,2) end)
 else navigation("Kembali",function() terms(back,1) end,"Tutup",dismiss) end
end
news=function(back)
 clear("Abstrak Twizzler — "..state.page.."/3"); state.pages[state.page]=true
 local page=state.page
 local sc=list(); text(sc,DATA.headings[page],26); text(sc,DATA.pages[page])
 task.defer(function() if sc.Parent then sc.CanvasPosition=readingScroll[page] or Vector2.new() end end)
 sc:GetPropertyChangedSignal("CanvasPosition"):Connect(function() readingScroll[page]=sc.CanvasPosition end)
 local previous=state.page>1 and function() state.page-=1; news(back) end or back
 local nextLabel=state.page<3 and "Lanjut" or (back and "Kembali ke latihan" or (state.reviewNews and "Ke kios evaluasi" or "Ke papan gagasan"))
 local nextAction=state.page<3 and function() state.page+=1; news(back) end or back or function() state.reviewNews=false; dismiss() end
 navigation(state.page>1 and "Kembali" or (back and "Kembali ke latihan" or nil),previous,nextLabel,nextAction)
end
local function box(pos,size,value)
 local b=Instance.new("TextLabel"); b.Position=pos; b.Size=size; b.Text=value; b.TextWrapped=true
 b.Font=Enum.Font.Gotham; b.TextSize=20; b.TextColor3=brown; b.BackgroundColor3=Color3.fromRGB(250,239,230); b.Parent=body
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,10); return b
end
local function inside(point,o)
 local p,s=o.AbsolutePosition,o.AbsoluteSize
 return point.X>=p.X and point.Y>=p.Y and point.X<=p.X+s.X and point.Y<=p.Y+s.Y
end
local selectedFunctionCard
-- Shuffle once per session; IDs and answer mapping stay stable for recording.
local functionOrder={1,2,3}
for i=#functionOrder,2,-1 do local j=math.random(i); functionOrder[i],functionOrder[j]=functionOrder[j],functionOrder[i] end
if functionOrder[1]==1 and functionOrder[2]==2 then functionOrder={3,1,2} end
evidence=function(feedback)
 clear("Latihan 1 — Fungsi gagasan"); local sc=list()
 text(sc,"Pilih satu kartu gagasan, lalu pilih fungsi yang sesuai. Kartu yang sudah terpasang akan berubah warna dan diberi tanda ✓. Ulangi sampai ketiga gagasan memiliki fungsi. Setelah selesai, tekan Periksa.",18)
 local functionNames={"Masalah","Pendekatan","Evaluasi"}
 local cardState={
  idle={bg=Color3.fromRGB(253,249,242),border=Color3.fromRGB(211,204,196),thickness=1.5,badge={"Belum dipasangkan",Color3.fromRGB(150,140,130),Color3.fromRGB(243,238,231)}},
  selected={bg=Color3.fromRGB(228,239,251),border=Color3.fromRGB(46,108,171),thickness=2.5,badge={"◉ Dipilih",Color3.fromRGB(46,108,171),Color3.fromRGB(215,232,249)}},
  paired={bg=Color3.fromRGB(253,249,242),border=Color3.fromRGB(211,204,196),thickness=1.5},
  correct={bg=Color3.fromRGB(233,246,235),border=Color3.fromRGB(88,158,96),thickness=2.5,dim=0.12},
  wrong={bg=Color3.fromRGB(252,232,230),border=Color3.fromRGB(190,64,52),thickness=2,badge={"✗ Belum tepat — pilih fungsi lain",Color3.fromRGB(178,52,42),Color3.fromRGB(249,224,222)}},
 }
 local function gagasanCard(i,status,badgeText,badgeColor,badgeBg)
  local st=cardState[status]
  local card=Instance.new("TextButton")
  card.Text=""; card.AutoButtonColor=not st.dim
  card.Size=UDim2.new(1,0,0,0); card.AutomaticSize=Enum.AutomaticSize.Y
  card.BackgroundColor3=st.bg; card.BorderSizePixel=0
  card.LayoutOrder=#sc:GetChildren(); card.Parent=sc
  Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
  local stroke=Instance.new("UIStroke",card); stroke.Color=st.border; stroke.Thickness=st.thickness
  local pad=Instance.new("UIPadding",card)
  pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12); pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,14)
  local layout=Instance.new("UIListLayout",card); layout.Padding=UDim.new(0,8)
  local body=Instance.new("TextLabel")
  body.Text=DATA.cards[i]; body.Font=Enum.Font.Gotham; body.TextSize=UI.font(panel.AbsoluteSize.X)
  body.TextColor3=brown; body.TextTransparency=st.dim or 0
  body.TextWrapped=true; body.TextXAlignment=Enum.TextXAlignment.Left; body.BackgroundTransparency=1
  body.Size=UDim2.new(1,0,0,0); body.LayoutOrder=1; body.Parent=card
  UI.autoText(body,0,0)
  if badgeText then
   local row=Instance.new("Frame")
   row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,24); row.LayoutOrder=2; row.Parent=card
   local badge=Instance.new("TextLabel")
   badge.Text=badgeText; badge.Font=Enum.Font.GothamBold; badge.TextSize=16
   badge.TextColor3=badgeColor; badge.BackgroundColor3=badgeBg; badge.BorderSizePixel=0
   badge.AnchorPoint=Vector2.new(1,0.5); badge.Position=UDim2.new(1,0,0.5,0)
   badge.Size=UDim2.new(0,0,1,-2); badge.AutomaticSize=Enum.AutomaticSize.X
   badge.TextXAlignment=Enum.TextXAlignment.Center; badge.TextYAlignment=Enum.TextYAlignment.Center
   badge.Parent=row
   local bpad=Instance.new("UIPadding",badge); bpad.PaddingLeft=UDim.new(0,10); bpad.PaddingRight=UDim.new(0,10)
   Instance.new("UICorner",badge).CornerRadius=UDim.new(1,0)
  end
  card.Activated:Connect(function()
   if not state.done1 then selectedFunctionCard=i; evidence() end
  end)
 end
 for _,i in ipairs(functionOrder) do
  local status
  if state.done1 or (state.check1 and state.check1[i]) then status="correct"
  elseif selectedFunctionCard==i then status="selected"
  elseif state.check1 and state.check1[i]==false then status="wrong"
  elseif state.slots[i] then status="paired"
  else status="idle" end
  local slotLabel=state.slots[i] and functionNames[state.slots[i]]
  local badge
  if status=="correct" then badge={"✓ Terpasang: "..slotLabel,Color3.fromRGB(42,122,52),Color3.fromRGB(219,240,224)}
  elseif status=="paired" then badge={"Terpasang: "..slotLabel,Color3.fromRGB(125,102,90),Color3.fromRGB(241,233,226)} end
  local badgeText,badgeColor,badgeBg
  if badge then badgeText,badgeColor,badgeBg=badge[1],badge[2],badge[3]
  elseif cardState[status].badge then badgeText,badgeColor,badgeBg=table.unpack(cardState[status].badge) end
  gagasanCard(i,status,badgeText,badgeColor,badgeBg)
 end
 text(sc,"PILIH FUNGSI TUJUAN",22).Font=Enum.Font.GothamBold
 for i,label in ipairs(functionNames) do
  local b=button(sc,label,function()
   if state.done1 then return end
   if not selectedFunctionCard then evidence("Ketuk satu kartu gagasan dahulu, lalu ketuk fungsinya."); return end
   for j=1,3 do
    if state.slots[j]==i then
     state.slots[j]=nil
     if state.check1 then state.check1[j]=nil end
    end
   end
   state.slots[selectedFunctionCard]=i
   if state.check1 then state.check1[selectedFunctionCard]=nil end
   selectedFunctionCard=nil; evidence()
  end)
  b.BackgroundColor3=Color3.fromRGB(255,247,237)
  b.TextXAlignment=Enum.TextXAlignment.Center
  local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(211,204,196); s.Thickness=1.5
 end
 navigation("Baca abstrak",function() news(function() evidence() end) end,state.done1 and "Ke Latihan 2" or "Periksa",function()
  if state.done1 then dismiss(); return end
  local correct=functionsCorrect(state.slots)
  recordLearning("practice",{activity="functions",choices={state.slots[1],state.slots[2],state.slots[3]},help=state.errors1>=2})
  state.check1={state.slots[1]==1,state.slots[2]==2,state.slots[3]==3}
  if correct then state.done1=true; evidence() else
   state.errors1+=1
   evidence(state.errors1>=2 and "BELUM TEPAT — Kendala ialah masalah; data-centric ialah pendekatan; studi kasus ialah evaluasi. Pasangkan kembali." or "BELUM TEPAT — Tinjau fungsi setiap gagasan dalam abstrak, lalu pasangkan kembali.")
  end
 end,state.done1 or (state.slots[1]~=nil and state.slots[2]~=nil and state.slots[3]~=nil))
 practiceStatus(state.done1 and "SELESAI — Ketiga fungsi gagasan tepat." or feedback or (selectedFunctionCard and "Gagasan dipilih. Ketuk fungsi tujuannya di bawah." or "Ketuk satu kartu gagasan, lalu ketuk fungsi tujuannya di bawah."),state.done1,feedback~=nil)
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
   local occupied=false; for j=1,3 do if j~=d.index and state.slots[j]==i then occupied=true end end
   if not occupied then state.slots[d.index]=i end; evidence(); return
  end end
  if inside(point,dragBoard.home) then state.slots[d.index]=nil end
 end
 evidence()
end)
pairView=function(feedback)
 local r=DATA.rounds[state.round]
 local v=state.rounds[state.round] or {errors=0}; state.rounds[state.round]=v
 -- A single provided source replaces the separate evidence-choice task.
 v.evidence=r.keyEvidence
 clear("Latihan 2 — Ronde "..state.round.."/4: "..r.title); local sc=list()
 text(sc,"Baca kutipan sumber di bawah. Dari tiga bagian draf, ketuk SATU bagian yang tidak didukung kutipan atau membuat simpulan berlebihan. Bagian terpilih akan dicoret. Tekan Periksa; ketuk bagian lain untuk mengganti pilihan.")
 text(sc,"KUTIPAN SUMBER — ABSTRAK TWIZZLER",22).Font=Enum.Font.GothamBold
 text(sc,r.evidence[r.keyEvidence])
 text(sc,"DRAF SIMPULAN — pilih bagian yang perlu dicoret",22).Font=Enum.Font.GothamBold
 for i,part in ipairs(r.parts) do
  local b=button(sc,(v.part==i and "CORET: " or "")..part,function()
   if not v.done then v.part=v.part~=i and i or nil; pairView() end
  end)
  b.RichText=true; if v.part==i then b.Text="<s>"..part.."</s>" end
  b.BackgroundColor3=v.part==i and Color3.fromRGB(120,50,40) or Color3.fromRGB(125,102,90)
 end
 if v.done then text(sc,"Hasil revisi: "..r.final) end
 navigation("Baca abstrak",function() news(function() pairView() end) end,v.done and (state.round==4 and "Ke kios evaluasi" or "Ronde berikutnya") or "Periksa",function()
  if v.done then
   if state.round<4 then state.round+=1; pairView() else dismiss() end; return
  end
  local revision,proof=editorCorrect(r,v.part,v.evidence)
  recordLearning("practice",{activity="editor",variant="provided_source_v2",round=state.round,choices={v.part},help=v.errors>=2})
  if revision and proof then
   v.done=true; state.done2=true
   for i=1,4 do if not state.rounds[i] or not state.rounds[i].done then state.done2=false end end
   pairView()
  else
   v.errors+=1
   local f="BELUM TEPAT — "..r.hint.." Baca kembali kutipan, lalu ganti bagian yang dicoret."
   if v.errors>=2 then f..=" Bantuan frasa: “"..r.proof.."”. Pilih kembali dan Periksa." end
   pairView(f)
  end
 end,v.done or (v.part~=nil and v.evidence~=nil))
 practiceStatus(v.done and "SELESAI — Bagian yang melampaui sumber sudah dicoret. Baca hasil revisi, lalu lanjutkan." or feedback or "Ketuk satu bagian draf yang perlu dicoret, lalu tekan Periksa.",v.done,feedback~=nil)
end

resultView=function()
 local sc=evaluationClear("Hasil Evaluasi Level 3",result.unlocked and "Gedung tengah terbuka. Tutup hasil dan ikuti panah." or "Nilai minimal 75. Pelajari kembali abstrak, lalu kembali ke kios untuk mencoba lagi.")
 local passed=result.score>=75
 title.Text="Level 3 — "..(passed and "Lulus" or "Belum lulus")
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
 if result.unlocked then evaluationAction("Ke gedung tengah",dismiss)
 else
  evaluationAction("Belajar lagi",function()
   beginReview(); dismiss()
   alert("Ikuti panah ke meja abstrak di sisi kiri. Tahan E untuk membaca kembali.")
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
 local sc=evaluationClear("Siap mengikuti evaluasi Level 3?","Jawaban benar bernilai 25. Nilai minimal untuk melanjutkan adalah 75.")
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
  clear("Level 3 — Membaca Lanjutan"); local sc=list(); text(sc,"SELAMAT DATANG",20).TextColor3=brick
  text(sc,"Baca abstrak, kenali fungsi gagasan, lalu periksa batas simpulan.",30).Font=Enum.Font.GothamBold
  text(sc,"1. Baca tiga bagian abstrak Twizzler.\n\n2. Pasangkan tiga gagasan dengan fungsinya.\n\n3. Pada empat ronde, baca kutipan dan coret bagian draf yang melampaui sumber.\n\n4. Jawab empat soal evaluasi beserta alasannya. Nilai minimal 75 membuka aula apresiasi.")
  navigation(nil,nil,"Mulai",function()
   state.intro=true; dismiss()
  end); return
 end
 if key=="news" then state.page=state.reviewNews and 1 or unreadPage(); news() elseif key=="evidence" then evidence() elseif key=="pairs" then pairView() else exam() end
end
local function bind(s)
 local obj=stationObject(s); if not obj then return end
 if s.prompt and s.prompt:IsDescendantOf(obj) then return end
 local part=partOf(obj); if not part then return end
 local a=Instance.new("Attachment"); a.Name="L3LearningAnchor"
 if obj:IsA("Model") and s.key~="intro" and s.path[1]~="Kursi Baru" then
  local bounds,size=obj:GetBoundingBox(); a.Position=part.CFrame:PointToObjectSpace(Vector3.new(bounds.Position.X,bounds.Position.Y-size.Y/2+3,bounds.Position.Z))
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
 p.Name="L3LearningPrompt"; p.ActionText=s.action; p.ObjectText=s.title; p.KeyboardKeyCode=Enum.KeyCode.E
 p.Exclusivity=Enum.ProximityPromptExclusivity.OnePerButton; p.HoldDuration=1; p.MaxActivationDistance=10; p.RequiresLineOfSight=false; p.Enabled=not gui.Enabled; p.Parent=a; s.prompt=p
 p.Triggered:Connect(function(who)
  if who and who~=player then return end; if gui.Enabled then return end
  local reason=prerequisite(s.key)
  if reason then alert(reason); refreshGuide(); return end
  hideNotice()
  recordLearning("start")
  activePrompt=p; gui.Enabled=true; player:SetAttribute("L3LearningOpen",true); controls.Lock(); prompts(false); render(s.key)
 end)
 print("[L3 Learning] Bound: "..table.concat(s.path,"/"))
end
local retired=setmetatable({}, {__mode="k"})
local function retireLegacy()
 for _,path in ipairs({{"Space3Answers"},{"Space 3","Infoboard"}}) do
  local o=find(path)
  if o then for _,p in ipairs(o:GetDescendants()) do
   if p:IsA("ProximityPrompt") and p.Name~="L3LearningPrompt" and not retired[p] then
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
print("[L3 Learning] Ready — intro/news/evidence/pairs/evaluation")
