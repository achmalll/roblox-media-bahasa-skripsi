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

-- L1 visual tuning only: retain the cream/brown artwork and compact desktop controls.
UI.font=function(w,heading) return heading and (w<600 and 24 or 28) or (w<600 and 18 or 20) end
local baseFit=UI.fit
UI.fit=function(frame,callback,maxHeight)
 local resize=baseFit(frame,callback,maxHeight or 620)
 local cap=Instance.new("UISizeConstraint",frame); cap.MaxSize=Vector2.new(940,maxHeight or 620)
 return resize
end
UI.legacy=function(frame,heading,copy,actions)
 local buttons={}
 for _,spec in ipairs(actions) do local b=frame:FindFirstChild(spec[1]); if b then buttons[b]=spec[2] end end
 local banner=frame:FindFirstChild("Title ")
 for _,c in ipairs(frame:GetChildren()) do if c:IsA("GuiObject") and not buttons[c] and c~=banner then c.Visible=false end end
 local sc=UI.scroll(frame,"ReadingContent")
 local label=UI.label(sc,copy,20); label.TextXAlignment=Enum.TextXAlignment.Center
 local readingLayout=sc:FindFirstChildOfClass("UIListLayout")
 local function alignContent() readingLayout.VerticalAlignment=readingLayout.AbsoluteContentSize.Y<sc.AbsoluteSize.Y-20 and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top end
 readingLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(alignContent)
 local headingText
 if banner then
  banner.Visible=true; headingText=banner:FindFirstChildWhichIsA("TextLabel"); if headingText then headingText.Text=heading end
 else headingText=UI.label(frame,heading,28,true); headingText.TextXAlignment=Enum.TextXAlignment.Center end
 UI.fit(frame,function(w,h)
  local head=math.min(76,h*.2)
  if banner then banner.AnchorPoint=Vector2.new(.5,0); banner.Position=UDim2.fromScale(.5,0); banner.Size=UDim2.new(.78,0,0,head)
  elseif headingText then headingText.Position=UDim2.fromOffset(24,16); headingText.Size=UDim2.new(1,-48,0,head-12) end
  sc.Position=UDim2.fromOffset(28,head+12); sc.Size=UDim2.new(1,-56,1,-(head+100)); label.TextSize=UI.font(w)
  local layout=sc:FindFirstChildOfClass("UIListLayout")
  layout.VerticalAlignment=layout.AbsoluteContentSize.Y<sc.AbsoluteSize.Y-20 and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
  for b,text in pairs(buttons) do
   if b.Name=="close" then b.AnchorPoint=Vector2.zero; b.Position=UDim2.new(1,-60,0,12); b.Size=UDim2.fromOffset(44,44)
   else
    if b:IsA("TextButton") then UI.action(b,text) else local t=b:FindFirstChildWhichIsA("TextLabel"); if t then t.Text=text end end
    local label=b:IsA("TextButton") and b or b:FindFirstChildWhichIsA("TextLabel")
    local size=w<600 and 16 or 18
    local line=game:GetService("TextService"):GetTextSize(text,size,Enum.Font.GothamBold,Vector2.new(4096,256))
    local needed=line.X+44
    local room=w-56
    local oneLine=needed<=room
    if label then
     label.TextSize=size
     label.TextWrapped=not oneLine
     label.TextTruncate=Enum.TextTruncate.None
    end
    b.AnchorPoint=Vector2.new(.5,1); b.Position=UDim2.new(.5,0,1,-20)
    b.Size=UDim2.fromOffset(oneLine and math.max(needed,200) or room, oneLine and 48 or 60)
   end
  end
 end)
 return sc
end
-- Welcome panel only: same cream/brown artwork, concise centered copy and a proportional CTA.
function UI.welcome(frame,heading,paragraphs,actions)
 local buttons={}
 for _,spec in ipairs(actions) do local b=frame:FindFirstChild(spec[1]); if b then buttons[b]=spec[2] end end
 local banner=frame:FindFirstChild("Title ")
 for _,c in ipairs(frame:GetChildren()) do if c:IsA("GuiObject") and not buttons[c] and c~=banner then c.Visible=false end end
 local sc=UI.scroll(frame,"WelcomeContent")
 local layout=sc:FindFirstChildOfClass("UIListLayout")
 layout.Padding=UDim.new(0,18); layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
 local labels={}
 for i,line in ipairs(paragraphs) do
  local l=UI.label(sc,line,18)
  l.LayoutOrder=i; l.TextXAlignment=Enum.TextXAlignment.Center; l.Size=UDim2.new(1,-56,0,0)
  local cap=Instance.new("UISizeConstraint",l); cap.MaxSize=Vector2.new(560,math.huge)
  labels[i]=l
 end
 local function alignContent()
  layout.VerticalAlignment=layout.AbsoluteContentSize.Y<sc.AbsoluteSize.Y-20 and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
 end
 layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(alignContent)
 if banner then
  banner.Visible=true
  local headingText=banner:FindFirstChildWhichIsA("TextLabel")
  if headingText then headingText.Text=heading end
 end
 UI.fit(frame,function(w,h)
  local head=math.min(76,h*.2)
  if banner then banner.AnchorPoint=Vector2.new(.5,0); banner.Position=UDim2.fromScale(.5,0); banner.Size=UDim2.new(.78,0,0,head) end
  local body=w<600 and 16 or 18
  for _,l in ipairs(labels) do l.TextSize=body end
  sc.Position=UDim2.fromOffset(28,head+16); sc.Size=UDim2.new(1,-56,1,-(head+96))
  alignContent()
  for b,text in pairs(buttons) do
   UI.action(b,text)
   b.AnchorPoint=Vector2.new(.5,1); b.Position=UDim2.new(.5,0,1,-20)
   b.Size=UDim2.fromOffset(math.min(w-56,320),52)
  end
 end)
 return sc
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
-- Research records are server-timed; no player names or free text are sent.
local recordHttp = game:GetService("HttpService")
local function recordLearning(op, fields)
 local remote=game:GetService("ReplicatedStorage"):FindFirstChild("LearningRecordEvent")
 if not remote then return end
 fields=fields or {}; fields.op=op; fields.level=1; fields.id=fields.id or recordHttp:GenerateGUID(false)
 remote:FireServer(fields)
end

local playerGui = player:WaitForChild("PlayerGui")
local PlayerControl = require(player.PlayerScripts:WaitForChild("PlayerControlHandler"))
local GuiAnimation = require(player.PlayerScripts:WaitForChild("GuiAnimationHandler"))
local level1Gui = playerGui:WaitForChild("Level1Gui")
local introFrame = level1Gui:WaitForChild("space1IntroFrame")
local audiochoose = level1Gui:WaitForChild("audioChoose")
local audioPlayerMale = level1Gui:WaitForChild("audioPlayerMale")
local audioPlayerFemale = level1Gui:WaitForChild("audioPlayerFemale")
local quizFrame = level1Gui:WaitForChild("quizFrame")
local overlay = level1Gui:WaitForChild("BackgroundOverlay")
UI.screen(level1Gui); overlay.AnchorPoint=Vector2.zero; overlay.Position=UDim2.new(); overlay.Size=UDim2.fromScale(1,1)
local latihanCompleted = false
local spacePart = workspace:WaitForChild("Space1Answers")
local prompt = spacePart:WaitForChild("ProximityPrompt")
-- Retire the shared interaction; only the two tutor prompts may open L1 audio.
prompt.Enabled = false
-- LevelAccessHandler still toggles the legacy prompt when progress changes.
-- Keep that shared prompt retired without touching access rules for other levels.
prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
	if prompt.Enabled then prompt.Enabled = false end
end)

-- 04B / 06B1 / 06B2: audio 1 male; audio 2 dan 3 female.
local clips = {
	{ id = "101781033507422", title = "Pengertian dan sumber daya" },
	{ id = "123696295721871", title = "Peran dan contoh sistem operasi" },
	{ id = "92723692760063", title = "Tujuan dan manfaat pemahaman" },
}
local completed = {false, false, false}
local positions = {0, 0, 0}
local activeClip = 1
local infoVisited = false
local guideVisited = false
local evaluationPassed = false
local reviewingInfo = false
local guideTargets = { tutor1 = spacePart }
local flowGui = playerGui:WaitForChild("FlowGui")
local guideBoard = workspace:WaitForChild("Halaman depan"):WaitForChild("papanInformasi")
local guidePrompt = guideBoard:FindFirstChildWhichIsA("ProximityPrompt", true)
guideTargets.guide = guidePrompt and guidePrompt.Parent or (guideBoard:IsA("BasePart") and guideBoard or guideBoard:FindFirstChildWhichIsA("BasePart", true))
local function currentStage()
	if reviewingInfo then return "info", "Baca kembali papan informasi Level 1" end
	if not guideVisited then return "guide", "Baca papan panduan permainan" end
	if not completed[1] then return "tutor1", "Temui Tutor 1 — dengarkan audio 1" end
	if not infoVisited then return "info", "Baca papan informasi Level 1" end
	if not completed[2] then return "tutor2", "Temui Tutor 2 — dengarkan audio 2" end
	if not completed[3] then return "tutor2", "Lanjutkan audio 3 di Tutor 2" end
	if not latihanCompleted then return "latihan", "Selesaikan latihan dua kartu" end
	return "kiosk", evaluationPassed and "Evaluasi lulus — akses Level 2 menunggu verifikasi" or "Kerjakan evaluasi di kios Level 1"
end
local noticeGui = Instance.new("ScreenGui")
noticeGui.Name = "L1StageNotice"
noticeGui.ResetOnSpawn = false
noticeGui.DisplayOrder = 50
noticeGui.Parent = playerGui
local showNotice=UI.notice(noticeGui,"L1AccessNotice")
local function explainPrerequisite(message)
 local _,destination=currentStage()
 showNotice(message.."\n\nLangkah berikutnya: "..destination..".\nIkuti panah petunjuk. Di PC, tahan E; di HP, tahan tombol interaksi pada layar.")
end
UI.legacy(introFrame,"Level 1 — Keterampilan Menyimak","Selamat datang di Level 1! Di sini, kamu akan berlatih menyimak informasi tentang pengertian dan peran sistem operasi. Dengarkan audio pertama bersama Tutor 1, baca papan informasi, lalu lanjutkan audio kedua dan ketiga bersama Tutor 2.\n\nPerhatikan pesan utama dan rincian penting dalam audio. Informasi tersebut akan membantumu memasangkan kartu dalam latihan, kemudian menjawab empat soal evaluasi beserta alasannya.\n\nRaih nilai minimal 75 untuk membuka Level 2. Tekan Mulai ketika kamu siap mendengarkan audio pertama.",{{"mulaibtn","Mulai — dengarkan audio 1"},{"close","Tutup"}})
local guideCopy={
 mapsFrame={"Panduan Petualangan Bahasa","Jelajahi kampus melalui tiga level. Ikuti panah kuning menuju kegiatan berikutnya.\n\nPC: bergerak dengan WASD, arahkan kamera dengan mouse, lalu tahan E di dekat objek.\nHP: gunakan kontrol gerak dan kamera pada layar, lalu tahan tombol interaksi yang muncul.\n\nDi panel pembelajaran, ketuk pilihan dan gulir untuk membaca. Tutup panel untuk melanjutkan perjalanan."},
 space1Frame={"Level 1 — Menyimak","Di Level 1, kamu akan berlatih menyimak tiga bagian audio tentang sistem operasi. Temui Tutor 1 untuk audio pertama, baca papan informasi, lalu lanjutkan audio kedua dan ketiga bersama Tutor 2.\n\nGunakan informasi yang kamu dengar untuk menentukan pesan utama dan informasi pendukung dalam latihan. Perhatikan perbedaan antara inti pembahasan dan rincian penjelasnya.\n\nSetelah latihan selesai, kerjakan empat soal evaluasi beserta alasannya. Nilai minimal 75 membuka akses ke Level 2."},
 space2Frame={"Level 2 — Membaca","Di Level 2, kamu akan membaca berita Cloud AI Pad yang membahas penggunaan Android dan Windows dalam satu perangkat. Ikuti pemandu menuju papan berita dan baca ketiga bagiannya. Papan istilah tersedia untuk membantu memahami kosakata.\n\nSelanjutnya, pilih dua kalimat bukti dan pasangkan simpulan dengan bukti yang mendukungnya. Gunakan isi berita sebagai dasar, bukan perkiraan pribadi.\n\nTerakhir, kerjakan empat soal evaluasi beserta alasannya. Nilai minimal 75 membuka akses ke Level 3."},
 space3Frame={"Level 3 — Membaca Lanjutan","Di Level 3, kamu akan membaca tiga bagian abstrak ilmiah tentang Twizzler dan pendekatan data-centric. Perhatikan masalah yang dibahas, pendekatan yang diusulkan, serta cara peneliti mengevaluasinya. Papan istilah dapat membantu memahami istilah teknis.\n\nDalam latihan, pasangkan gagasan dengan fungsinya. Kemudian, selesaikan empat ronde dengan membaca kutipan sumber dan mencoret bagian draf yang melampaui informasi di dalamnya.\n\nUji pemahamanmu melalui empat soal evaluasi beserta alasannya. Nilai minimal 75 membuka aula apresiasi."},
 hall4Frame={"Aula Apresiasi","Aula apresiasi menjadi tujuan akhir setelah kamu menyelesaikan ketiga level pembelajaran. Masuklah ke gedung tengah dan datangi titik rekap untuk melihat nilai setiap level serta total nilai yang kamu peroleh.\n\nLanjutkan untuk melihat penghargaan dan mengambil medali sesuai hasil belajarmu. Ikuti panduan perlengkapan untuk memakai medali pada avatar.\n\nSebagai penutup perjalanan, kamu dapat berfoto di spot foto aula sambil mengenakan medali. Kegiatan foto ini bersifat opsional."},
}
for name,copy in pairs(guideCopy) do
 local frame=flowGui:WaitForChild(name)
 UI.guide(frame,copy[1],copy[2])
end

-- Visiting a guide page and closing it completes orientation, without forcing all five pages.
for _, pageName in ipairs({"mapsFrame", "space1Frame", "space2Frame", "space3Frame", "hall4Frame"}) do
	local page = flowGui:WaitForChild(pageName)
	page:WaitForChild("close").MouseButton1Click:Connect(function() guideVisited = true end)
end
RunService.Heartbeat:Connect(function()
	local stage, label = currentStage()
	local target = guideTargets[stage]
	local position
	if target and target:IsA("BasePart") then position = target.Position
	elseif target and target:IsA("Model") then position = target:GetPivot().Position end
	player:SetAttribute("L1GuideTarget", position)
	player:SetAttribute("L1GuideLabel", label)
	player:SetAttribute("L1GuideStage", stage)
end)
local loadVersion = 0
local pendingPlay = false
local loaded = false
local paused = false
local sound = audioPlayerMale:WaitForChild("NarationSound")
sound:Stop()
sound.Looped = false
sound.SoundId = "rbxassetid://" .. clips[1].id
audioPlayerFemale:WaitForChild("NarationSound"):Stop()
audiochoose.Visible = false
audioPlayerFemale.Visible = false
-- Existing panel/frame/border retained; controls replace the old quiz/audio choice UI at runtime.
for _, child in ipairs(audioPlayerMale:GetChildren()) do
	if child:IsA("GuiObject") then child.Visible = false end
end
local root = Instance.new("Frame")
root.Name = "L1SegmentedAudio"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundTransparency = 1
root.ZIndex = 30
root.Parent = audioPlayerMale
-- Keep the baseline cream/brown shell; constrain the wide audio panel on desktop.
audioPlayerMale.AnchorPoint = Vector2.new(.5,.5)
audioPlayerMale.Position = UDim2.fromScale(.5,.5)
audioPlayerMale.Size = UDim2.fromScale(.86,.72)
local panelBounds = Instance.new("UISizeConstraint")
panelBounds.MaxSize = Vector2.new(860,560)
panelBounds.MinSize = Vector2.new(280,240)
panelBounds.Parent = audioPlayerMale
local function control(class, name, text, x, y, w, h)
	local item = Instance.new(class)
	item.Name = name
	item.Position = UDim2.fromScale(x, y)
	item.Size = UDim2.fromScale(w, h)
	item.BackgroundColor3 = Color3.fromRGB(155, 72, 48)
	item.BackgroundTransparency = class == "TextLabel" and 1 or 0
	item.TextColor3 = class == "TextLabel" and Color3.fromRGB(71, 32, 3) or Color3.new(1,1,1)
	item.Font = Enum.Font.GothamBold
	item.TextSize = 20
	item.TextWrapped = true
	item.Text = text
	item.ZIndex = 31
	item.Parent = root
	if class == "TextButton" then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = item
	end
	return item
end
local badge = control("TextLabel", "Segment", "", .08,.07,.72,.06)
badge.TextSize = 16
badge.TextXAlignment = Enum.TextXAlignment.Left
badge.TextColor3 = Color3.fromRGB(155,72,48)
local heading = control("TextLabel", "Heading", "", .08,.15,.76,.14)
heading.TextSize = 26
heading.TextXAlignment = Enum.TextXAlignment.Left
local status = control("TextLabel", "Status", "", .08,.32,.84,.13)
status.Font = Enum.Font.Gotham
status.TextSize = 18
status.TextXAlignment = Enum.TextXAlignment.Left
local bar = Instance.new("Frame")
bar.Name = "ClipProgress"
bar.Position = UDim2.fromScale(.08,.50)
bar.Size = UDim2.fromScale(.84,.022)
bar.BorderSizePixel = 0
bar.BackgroundColor3 = Color3.fromRGB(209,156,116)
bar.ZIndex = 31
bar.Parent = root
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0,1)
fill.BackgroundColor3 = Color3.fromRGB(155,72,48)
fill.BorderSizePixel = 0
fill.ZIndex = 32
fill.Parent = bar
for _, target in ipairs({bar,fill}) do
	local rounded = Instance.new("UICorner")
	rounded.CornerRadius = UDim.new(1,0)
	rounded.Parent = target
end
local timeLabel = control("TextLabel", "Time", "0:00 / 0:00", .08,.54,.84,.06)
timeLabel.TextSize = 16
timeLabel.TextXAlignment = Enum.TextXAlignment.Right
local play = control("TextButton", "PlayPause", "Putar", .30,.63,.40,.11)
local nextButton = control("TextButton", "Next", "", .52,.79,.40,.11)
local back = control("TextButton", "Previous", "Kembali ke audio 2", .08,.79,.40,.11)
back.TextSize = 16
back.BackgroundTransparency = 0
back.BackgroundColor3 = Color3.fromRGB(125,102,90)
back.TextColor3 = Color3.new(1,1,1)
local close = control("TextButton", "Close", "×", .88,.04,.065,.085)
close.TextSize = 22
-- Keep the player controls in their original balanced composition.
UI.fit(audioPlayerMale,function(w,h)
 local compact=h<380
 badge.Position=UDim2.fromScale(.08,.07); badge.Size=UDim2.fromScale(.72,.08); badge.TextSize=16
 heading.Position=UDim2.fromScale(.08,.18); heading.Size=UDim2.fromScale(.78,.14); heading.TextSize=UI.font(w,true)
 status.Position=UDim2.fromScale(.08,.35); status.Size=UDim2.fromScale(.84,.12); status.TextSize=UI.font(w)
 bar.Position=UDim2.fromScale(.08,.51); bar.Size=UDim2.new(.84,0,0,10)
 timeLabel.Position=UDim2.fromScale(.08,.55); timeLabel.Size=UDim2.fromScale(.84,.07); timeLabel.TextSize=16
 play.Position=UDim2.fromScale(.32,.65); play.Size=UDim2.fromScale(.36,.12)
 back.Position=UDim2.fromScale(.08,.82); back.Size=UDim2.fromScale(.40,.12)
 nextButton.Position=UDim2.fromScale(.52,.82); nextButton.Size=UDim2.fromScale(.40,.12)
 close.Position=UDim2.new(1,-60,0,12); close.Size=UDim2.fromOffset(44,44)
 for _,button in ipairs({play,back,nextButton}) do button.TextSize=w<600 and 17 or 19 end
end,560)

local function hideAll()
	if audioPlayerMale.Visible then
		positions[activeClip] = sound.TimePosition
		sound:Pause()
		paused = true
	end
	pendingPlay = false
	introFrame.Visible = false
	audiochoose.Visible = false
	audioPlayerMale.Visible = false
	audioPlayerFemale.Visible = false
end
local function closeAudio()
	hideAll()
	level1Gui.Enabled = false
	overlay.Visible = false
	PlayerControl.Unlock()
end
local function refresh()
	badge.Text = "LEVEL 1  /  AUDIO " .. activeClip .. " DARI 3"
	heading.Text = clips[activeClip].title
	play.Text = sound.IsPlaying and "Jeda" or (completed[activeClip] and "Putar ulang" or "Putar")
	nextButton.Text = ({"Ke papan informasi", "Lanjut ke audio 3", "Ke papan latihan"})[activeClip]
	nextButton.Active = completed[activeClip]
	nextButton.AutoButtonColor = completed[activeClip]
	nextButton.BackgroundTransparency = completed[activeClip] and 0 or .55
	back.Visible = activeClip == 3
end
local function openAudio(index)
	hideAll()
	activeClip = index
	loadVersion += 1
	local version = loadVersion
	sound:Stop()
	loaded = false
	paused = false
	sound.SoundId = "rbxassetid://" .. clips[index].id
	print("[L1 Audio] Segmen", index, "SoundId", sound.SoundId)
	fill.Size = UDim2.fromScale(completed[index] and 1 or 0, 1)
	status.Text = "Memuat audio…"
	audioPlayerMale.Visible = true
	level1Gui.Enabled = true
	overlay.Visible = true
	PlayerControl.Lock()
	refresh()
	task.spawn(function()
		local deadline = os.clock() + 20
		repeat task.wait(.1) until version ~= loadVersion or sound.IsLoaded or os.clock() >= deadline
		if version ~= loadVersion then return end
		loaded = sound.IsLoaded
		if loaded then
			sound.TimePosition = completed[index] and 0 or positions[index]
			status.Text = completed[index] and "Audio ini sudah selesai. Bisa diputar ulang." or "Tekan Putar untuk mendengarkan."
			if pendingPlay and audioPlayerMale.Visible then
				sound:Play()
				sound.TimePosition = completed[index] and 0 or positions[index]
				pendingPlay = false
			end
		else
			status.Text = "Audio belum siap. Tekan Coba lagi; periksa koneksi atau izin audio jika tetap gagal."
			play.Text = "Coba lagi"
		end
	end)
end
play.MouseButton1Click:Connect(function()
	if not sound.IsLoaded then openAudio(activeClip); pendingPlay = true; return end
	loaded = true
	if sound.IsPlaying then
		positions[activeClip] = sound.TimePosition
		sound:Pause(); paused = true
	elseif completed[activeClip] then
		sound.TimePosition = 0; sound:Play(); paused = false
	elseif paused then sound:Resume(); paused = false
	else sound:Play(); sound.TimePosition = positions[activeClip] end
	status.Text = sound.IsPlaying and "Dengarkan sampai selesai untuk melanjutkan." or "Dijeda. Tekan Putar untuk melanjutkan."
	refresh()
end)
sound.Ended:Connect(function()
	completed[activeClip] = true
	positions[activeClip] = 0
	paused = false
	status.Text = "Audio " .. activeClip .. " selesai. Silakan lanjut."
	fill.Size = UDim2.fromScale(1,1)
	refresh()
end)
RunService.RenderStepped:Connect(function()
	if not audioPlayerMale.Visible then return end
	local duration = sound.TimeLength
	local position = sound.TimePosition
	if completed[activeClip] and not sound.IsPlaying and not paused then position = duration end
	local function clock(seconds) return string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60)) end
	timeLabel.Text = clock(position) .. " / " .. clock(duration)
	if duration > 0 then fill.Size = UDim2.fromScale(completed[activeClip] and not sound.IsPlaying and not paused and 1 or math.clamp(position / duration,0,1),1) end
end)
close.MouseButton1Click:Connect(closeAudio)
back.MouseButton1Click:Connect(function() openAudio(2) end)
nextButton.MouseButton1Click:Connect(function()
	if not completed[activeClip] then return end
	if activeClip == 2 then openAudio(3) else closeAudio() end
end)
introFrame.mulaibtn.MouseButton1Click:Connect(function() recordLearning("start"); openAudio(1) end)
introFrame:WaitForChild("close").MouseButton1Click:Connect(closeAudio)
local function tutor1()
	recordLearning("start")
	if not guideVisited then
		explainPrerequisite("Baca papan panduan dahulu sebelum mulai belajar.")
		return
	end
	hideAll()
	level1Gui.Enabled = true
	overlay.Visible = true
	GuiAnimation.Show(introFrame)
	PlayerControl.Lock()
end
local function tutor2()
	if not guideVisited or not completed[1] or not infoVisited then
		explainPrerequisite(completed[1] and "Baca papan informasi dahulu sebelum audio 2." or "Selesaikan audio 1 bersama Tutor 1 dahulu.")
		return
	end
	openAudio(completed[2] and 3 or 2)
end
-- Resolve only the two nearby humanoids, using entrance-to-tutors direction for left/right.
-- No permanent NPC names/positions are changed. Ambiguous discovery leaves the baseline prompt available.
local candidates = {}
for _, item in ipairs(workspace:GetDescendants()) do
	if item:IsA("Humanoid") and item.Parent:IsA("Model") and not Players:GetPlayerFromCharacter(item.Parent) then
		local part = item.Parent:FindFirstChild("HumanoidRootPart") or item.Parent:FindFirstChild("Head")
		if part and part:IsA("BasePart") and (part.Position - spacePart.Position).Magnitude < 25 then
			table.insert(candidates, {model=item.Parent, part=part})
		end
	end
end
if #candidates == 2 then
	local midpoint = (candidates[1].part.Position + candidates[2].part.Position) / 2
	local spawn, distance
	for _, item in ipairs(workspace:GetDescendants()) do
		if item:IsA("SpawnLocation") then
			local d = (item.Position - midpoint).Magnitude
			if not distance or d < distance then spawn = item; distance = d end
		end
	end
	if spawn then
		local forward = midpoint - spawn.Position
		forward = Vector3.new(forward.X,0,forward.Z)
		if forward.Magnitude > .1 then
			local right = forward.Unit:Cross(Vector3.yAxis)
			table.sort(candidates, function(a,b) return a.part.Position:Dot(right) < b.part.Position:Dot(right) end)
			for index, npc in ipairs(candidates) do
				guideTargets[index == 1 and "tutor1" or "tutor2"] = npc.part
				local npcPrompt = Instance.new("ProximityPrompt")
				npcPrompt.Name = "L1TutorAudioPrompt"
				npcPrompt.ActionText = "Bicara"
				npcPrompt.ObjectText = "Tutor " .. index
				npcPrompt.HoldDuration = 1
				npcPrompt.MaxActivationDistance = 10
				npcPrompt.RequiresLineOfSight = false
				npcPrompt.Parent = npc.part
				local openTutor = index == 1 and tutor1 or tutor2
				npcPrompt.Triggered:Connect(function(who) if who == player then openTutor() end end)
				print("L1 audio Tutor", index, npc.model:GetFullName(), npc.part.Position)
			end
			prompt.Enabled = false
		end
	end
else warn("L1 audio: expected two NPCs near Space1Answers; found", #candidates) end

-- ===== Papan Informasi (L1_PapanInformasi) =====
local papanInfoFrame = level1Gui:WaitForChild("papanInfoFrame")
local papanPrompt = workspace:WaitForChild("Level1Development"):WaitForChild("L1_PapanInformasi"):WaitForChild("Animation 2"):WaitForChild("ProximityPrompt")
guideTargets.info = papanPrompt.Parent
local infoOpened = false
do
 local infoContent=UI.legacy(papanInfoFrame,"Kenali Sistem Operasi","LEVEL 1 — MATERI\n\nSistem operasi adalah perangkat lunak yang mengelola sumber daya komputer.\n\nSumber daya yang dikelola meliputi:",{{"TutupBtn","Selesai membaca — Tutor 2"}})
local resources=Instance.new("Frame",infoContent)
 resources.BackgroundTransparency=1; resources.Size=UDim2.new(1,-12,0,156); resources.LayoutOrder=10
 local grid=Instance.new("UIGridLayout",resources); grid.CellPadding=UDim2.fromOffset(12,12); grid.SortOrder=Enum.SortOrder.LayoutOrder
 for i,name in ipairs({"Prosesor","Memori","Penyimpanan","Input dan output"}) do
  local card=Instance.new("TextLabel",resources); card.LayoutOrder=i; card.Text=string.format("%02d  %s",i,name)
  card.Font=Enum.Font.GothamBold; card.TextSize=20; card.TextWrapped=true; card.TextColor3=Color3.fromRGB(71,42,28); card.BackgroundColor3=Color3.fromRGB(255,247,237)
  Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
 end
 local function resourceLayout()
  local columns=resources.AbsoluteSize.X<480 and 1 or 2
  grid.CellSize=UDim2.new(1/columns,-(columns==2 and 6 or 0),0,64)
  resources.Size=UDim2.new(1,-12,0,(4/columns)*76-12)
 end
 resources:GetPropertyChangedSignal("AbsoluteSize"):Connect(resourceLayout); task.defer(resourceLayout)
end

papanPrompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		if not guideVisited or not completed[1] then
			explainPrerequisite("Selesaikan audio 1 dahulu sebelum membuka papan informasi.")
			return
		end
		hideAll()
		infoOpened = true
		level1Gui.Enabled = true
		overlay.Visible = true
		GuiAnimation.Show(papanInfoFrame)
		PlayerControl.Lock()
	end
end)

papanInfoFrame.TutupBtn.MouseButton1Click:Connect(function()
	reviewingInfo = false
	if infoOpened then infoVisited = true end
	GuiAnimation.Hide(papanInfoFrame)
	overlay.Visible = false
	level1Gui.Enabled = false
	PlayerControl.Unlock()
end)

-- ===== Papan Latihan (L1_PapanLatihan) =====
local latihanFrame = level1Gui:WaitForChild("latihanFrame")
latihanFrame.AnchorPoint = Vector2.new(.5, .5)
latihanFrame.Position = UDim2.fromScale(.5, .5)
latihanFrame.Size = UDim2.fromScale(.94, .92)
local latihanPrompt = workspace:WaitForChild("Level1Development"):WaitForChild("L1_PapanLatihan"):WaitForChild("Animation 2"):WaitForChild("ProximityPrompt")
guideTargets.latihan = latihanPrompt.Parent

-- Latihan 07B: pilih dua dari empat kartu dan tempatkan ke dua slot.
-- UI dibuat runtime agar tidak mengubah/menggandakan objek permanen di place.
local oldActivity = latihanFrame:FindFirstChild("L1TwoSlotActivity")
if oldActivity then oldActivity:Destroy() end
local activity = Instance.new("ScrollingFrame")
activity.Name = "L1TwoSlotActivity"
activity.BorderSizePixel=0; activity.CanvasSize=UDim2.new(); activity.AutomaticCanvasSize=Enum.AutomaticSize.Y; activity.ScrollBarThickness=6; activity.ScrollingDirection=Enum.ScrollingDirection.Y
local activityLayout=Instance.new("UIListLayout",activity); activityLayout.Padding=UDim.new(0,14); activityLayout.SortOrder=Enum.SortOrder.LayoutOrder
local activityPad=Instance.new("UIPadding",activity); activityPad.PaddingRight=UDim.new(0,12); activityPad.PaddingBottom=UDim.new(0,20)
activity.BackgroundTransparency = 1
activity.Size = UDim2.new(1, -48, 1, -112)
activity.Position = UDim2.new(0, 24, 0, 24)
activity.Parent = latihanFrame

-- Pastikan UI latihan lama tidak menumpuk di bawah/di atas activity baru.
-- Objek permanen di Studio tetap dipertahankan; hanya disembunyikan saat runtime.
for _, child in ipairs(latihanFrame:GetChildren()) do
	if child:IsA("GuiObject") and child ~= activity and child.Name ~= "TutupBtn" then
		child.Visible = false
	end
end

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(70, 48, 38)
title.Text = "Lengkapi informasi dari audio"
title.Parent = activity

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, 0, 0, 42)
hint.Position = UDim2.new(0, 0, 0, 36)
hint.TextWrapped = true
hint.Font = Enum.Font.Gotham
hint.TextSize = 19
hint.TextColor3 = Color3.fromRGB(85, 65, 55)
hint.Text = "Pilih satu kartu, lalu pilih tempat Pesan utama atau Informasi pendukung. Isi kedua tempat, kemudian tekan Periksa. Dua kartu tidak digunakan."
hint.Parent = activity

local cards = {
	{ id = "A", text = "Sistem operasi berperan penting dalam mengelola sumber daya dan mendukung penggunaan komputer." },
	{ id = "B", text = "Sumber daya yang dikelola mencakup prosesor, memori, penyimpanan, serta perangkat input dan output." },
	{ id = "C", text = "Rekaman menjelaskan langkah memasang sistem operasi." },
	{ id = "D", text = "Sistem operasi merupakan perangkat keras yang mengelola sumber daya komputer." },
}
local cardById = {}
for _, card in ipairs(cards) do cardById[card.id] = card end
local selectedCard = nil
local slots = { main = nil, supporting = nil }
local cardButtons = {}

local cardPanel = Instance.new("Frame")
cardPanel.Name = "Cards"
cardPanel.BackgroundTransparency = 1
cardPanel.BorderSizePixel = 0
cardPanel.Size = UDim2.new(0.52, -12, 1, -238)
cardPanel.Position = UDim2.new(0, 0, 0, 90)
cardPanel.Parent = activity
local cardLayout = Instance.new("UIListLayout")
cardLayout.Padding = UDim.new(0, 9)
cardLayout.Parent = cardPanel

local slotPanel = Instance.new("Frame")
slotPanel.Name = "Slots"
slotPanel.BackgroundTransparency = 1
slotPanel.BorderSizePixel = 0
slotPanel.Size = UDim2.new(0.48, -12, 1, -238)
slotPanel.Position = UDim2.new(0.52, 12, 0, 90)
slotPanel.Parent = activity

local feedback = Instance.new("TextLabel")
feedback.Name = "Feedback"
feedback.BackgroundTransparency = 0
feedback.BackgroundColor3 = Color3.fromRGB(255,247,237)
feedback.Size = UDim2.new(1, 0, 0, 82)
feedback.AutomaticSize = Enum.AutomaticSize.None
feedback.Position = UDim2.new(0, 0, 1, -138)
feedback.Font = Enum.Font.GothamBold
feedback.TextWrapped = true
feedback.TextSize = 21
feedback.TextXAlignment = Enum.TextXAlignment.Left
feedback.TextYAlignment = Enum.TextYAlignment.Top
feedback.TextColor3 = Color3.fromRGB(90, 55, 40)
feedback.Text = "BELUM SELESAI — Isi kedua slot, lalu tekan Periksa jawaban."
feedback.Parent = activity
Instance.new("UICorner",feedback).CornerRadius=UDim.new(0,10)
local feedbackPadding=Instance.new("UIPadding",feedback)
feedbackPadding.PaddingLeft=UDim.new(0,12); feedbackPadding.PaddingRight=UDim.new(0,12)
feedbackPadding.PaddingTop=UDim.new(0,6); feedbackPadding.PaddingBottom=UDim.new(0,6)

local checkButton = Instance.new("TextButton")
checkButton.Name = "Periksa"
checkButton.Size = UDim2.new(0.72, 0, 0, 46)
checkButton.AnchorPoint=Vector2.new(1,1)
checkButton.Position = UDim2.new(1, 0, 1, 0)
checkButton.Size = UDim2.new(.44, 0, 0, 48)
checkButton.BackgroundColor3 = Color3.fromRGB(190, 105, 70)
checkButton.TextColor3 = Color3.new(1, 1, 1)
checkButton.Font = Enum.Font.GothamBold
checkButton.TextSize = 18
checkButton.Text = "Periksa"
checkButton.AutoButtonColor = true
checkButton.Parent = activity
Instance.new("UICorner", checkButton).CornerRadius = UDim.new(0, 12)
local mainSlot
local supportingSlot

local function refreshCards()
	for id, button in pairs(cardButtons) do
		local used = slots.main == id or slots.supporting == id
		local destination = slots.main == id and "PESAN UTAMA" or (slots.supporting == id and "INFORMASI PENDUKUNG" or nil)
		button.BackgroundColor3 = used and Color3.fromRGB(226, 237, 224)
			or (selectedCard == id and Color3.fromRGB(245, 219, 187) or Color3.fromRGB(255, 247, 237))
		button.TextColor3 = Color3.fromRGB(71, 42, 28)
		button.SelectionStroke.Transparency = selectedCard == id and 0 or .8
		if destination then
			button.Text = id .. ". DITEMPATKAN → " .. destination .. "\n" .. cardById[id].text
		elseif selectedCard == id then
			button.Text = id .. ". DIPILIH — KETUK TEMPAT TUJUAN\n" .. cardById[id].text
		else
			button.Text = id .. ". " .. cardById[id].text
		end
	end
	local ready = slots.main ~= nil and slots.supporting ~= nil
	checkButton.Visible = not latihanCompleted
	checkButton.Active = ready and not latihanCompleted
	checkButton.AutoButtonColor = ready and not latihanCompleted
	checkButton.BackgroundColor3 = ready and Color3.fromRGB(190, 105, 70) or Color3.fromRGB(150, 140, 135)
	checkButton.Text = latihanCompleted and "Latihan selesai" or (ready and "Periksa jawaban" or "Isi kedua slot dahulu")
	if mainSlot then mainSlot.Text = "1. Pesan utama\n" .. (slots.main and ("Kartu " .. slots.main .. " • " .. cardById[slots.main].text) or "Pilih kartu, lalu klik tempat ini") end
	if supportingSlot then supportingSlot.Text = "2. Informasi pendukung\n" .. (slots.supporting and ("Kartu " .. slots.supporting .. " • " .. cardById[slots.supporting].text) or "Pilih kartu, lalu klik tempat ini") end
end

-- Deklarasikan lebih dahulu agar callback slot merujuk objek lokal yang benar.

local function makeSlot(name, label, key)
	local slot = Instance.new("TextButton")
	slot.Name = name
	slot.Size = UDim2.new(1, -6, .5, -6)
	slot.Position = key == "main" and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, .5, 6)
	slot.BackgroundColor3 = Color3.fromRGB(245, 226, 207)
	slot.TextColor3 = Color3.fromRGB(75, 52, 42)
	slot.Font = Enum.Font.Gotham
	slot.TextSize = 20
	slot.TextWrapped = true
	slot.Text = label .. "\nBelum terisi — pilih kartu pada daftar kartu, lalu klik tempat ini"
	slot.Parent = slotPanel
	slot.BorderSizePixel = 0
	Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 12)
	local padding = Instance.new("UIPadding", slot)
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	slot.MouseButton1Click:Connect(function()
		if latihanCompleted then return end
		if selectedCard then
			-- Satu kartu hanya boleh berada pada satu slot.
			if slots.main == selectedCard then slots.main = nil end
			if slots.supporting == selectedCard then slots.supporting = nil end
			slots[key] = selectedCard
			selectedCard = nil
			if slots.main then
				mainSlot.Text = "Pesan utama — TERISI KARTU " .. slots.main .. "\n" .. cardById[slots.main].text
			else
				mainSlot.Text = "Pesan utama\nBelum terisi — pilih kartu pada daftar kartu, lalu klik tempat ini"
			end
			if slots.supporting then
				supportingSlot.Text = "Informasi pendukung — TERISI KARTU " .. slots.supporting .. "\n" .. cardById[slots.supporting].text
			else
				supportingSlot.Text = "Informasi pendukung\nBelum terisi — pilih kartu pada daftar kartu, lalu klik tempat ini"
			end
			feedback.TextColor3 = Color3.fromRGB(90, 55, 40)
			feedback.Text = slots.main and slots.supporting and "Kedua slot terisi. Tekan Periksa jawaban." or "Kartu ditempatkan. Isi satu slot lagi."
			slot.BackgroundColor3 = Color3.fromRGB(213, 235, 209)
			game:GetService("TweenService"):Create(slot, TweenInfo.new(.3), {BackgroundColor3 = Color3.fromRGB(245, 226, 207)}):Play()
			refreshCards()
		else
			feedback.TextColor3 = Color3.fromRGB(170, 90, 50)
			feedback.Text = "Pilih salah satu kartu pada daftar kartu terlebih dahulu."
		end
	end)
	return slot
end
mainSlot = makeSlot("PesanUtama", "Pesan utama", "main")
supportingSlot = makeSlot("InformasiPendukung", "Informasi pendukung", "supporting")

for _, card in ipairs(cards) do
	local button = Instance.new("TextButton")
	button.Name = "Kartu" .. card.id
	button.Size = UDim2.new(1, -6, 0, 126)
	button.BackgroundColor3 = Color3.fromRGB(226, 157, 103)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.Gotham
	button.TextSize = 21
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextWrapped = true
	button.Text = card.id .. ". " .. card.text
	button.Parent = cardPanel
	button.BorderSizePixel = 0
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)
	local padding = Instance.new("UIPadding", button)
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	local stroke = Instance.new("UIStroke", button)
	stroke.Name = "SelectionStroke"
	stroke.Color = Color3.fromRGB(169, 90, 47)
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	cardButtons[card.id] = button
	button.MouseButton1Click:Connect(function()
		if latihanCompleted then return end
		if slots.main == card.id then slots.main = nil end
		if slots.supporting == card.id then slots.supporting = nil end
		selectedCard = card.id
		feedback.Text = "Kartu " .. card.id .. " dipilih — sekarang klik slot tujuan pada daftar tujuan."
		refreshCards()
	end)
end

-- Responsive activity: one continuous reading surface, no nested small card viewport.
for i,item in ipairs({title,hint,cardPanel,slotPanel,feedback,checkButton}) do
 item.LayoutOrder=i; item.AnchorPoint=Vector2.zero; item.Position=UDim2.new(); item.Size=UDim2.new(1,0,0,52)
end
for _,container in ipairs({cardPanel,slotPanel}) do
 container.Size=UDim2.new(1,0,0,0); container.AutomaticSize=Enum.AutomaticSize.Y
 if not container:FindFirstChildOfClass("UIListLayout") then
  local layout=Instance.new("UIListLayout",container); layout.Padding=UDim.new(0,12); layout.SortOrder=Enum.SortOrder.LayoutOrder
 end
end
for i,slot in ipairs({mainSlot,supportingSlot}) do
 slot.LayoutOrder=i; slot.AnchorPoint=Vector2.zero; slot.Position=UDim2.new(); slot.Size=UDim2.new(1,-6,0,100)
 slot.TextXAlignment=Enum.TextXAlignment.Left; UI.autoText(slot,100,36)
end
for i,card in ipairs(cards) do
 local b=cardButtons[card.id]; b.LayoutOrder=i; UI.autoText(b,80,40)
end
UI.autoText(title,36,4); UI.autoText(hint,56,4); UI.autoText(feedback,64,32)
local workArea=Instance.new("Frame",activity)
workArea.Name="ExerciseColumns"; workArea.BackgroundTransparency=1; workArea.LayoutOrder=3; workArea.Size=UDim2.new(1,0,0,0)
cardPanel.Parent=workArea; slotPanel.Parent=workArea; feedback.LayoutOrder=4; checkButton.LayoutOrder=5
local slotLayout=slotPanel:FindFirstChildOfClass("UIListLayout")
local function arrangeExercise()
 local wide=activity.AbsoluteSize.X>=700
 local cardsHeight=cardLayout.AbsoluteContentSize.Y+8
 local slotsHeight=slotLayout.AbsoluteContentSize.Y+8
 cardPanel.Position=UDim2.new(); cardPanel.Size=UDim2.new(wide and .52 or 1,wide and -12 or 0,0,0)
 slotPanel.Position=wide and UDim2.new(.52,12,0,0) or UDim2.fromOffset(0,cardsHeight+16)
 slotPanel.Size=UDim2.new(wide and .48 or 1,wide and -12 or 0,0,0)
 workArea.Size=UDim2.new(1,0,0,wide and math.max(cardsHeight,slotsHeight) or cardsHeight+slotsHeight+16)
end
cardLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(arrangeExercise)
slotLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(arrangeExercise)
-- TutupBtn stays disabled until the two-card exercise is finished; state drives color, label and clickability.
local exitState={enabled=false}
local function refreshExit()
 local exit=latihanFrame.TutupBtn
 if not exit then return end
 local label=exit:IsA("TextButton") and exit or exit:FindFirstChildWhichIsA("TextLabel")
 if exitState.enabled then
  exit.BackgroundColor3=Color3.fromRGB(153,59,42)
  exit.Active=true; exit.AutoButtonColor=true
  if label then label.Text="Tutup latihan" end
 else
  exit.BackgroundColor3=Color3.fromRGB(158,158,158)
  exit.Active=false; exit.AutoButtonColor=false
  if label then label.Text="Selesaikan latihan terlebih dahulu" end
 end
end
UI.fit(latihanFrame,function(w)
 activity.Position=UDim2.fromOffset(20,20); activity.Size=UDim2.new(1,-40,1,-100)
 title.TextSize=UI.font(w,true); hint.TextSize=UI.font(w); feedback.TextSize=UI.font(w)
 for _,b in pairs(cardButtons) do b.TextSize=UI.font(w) end
 mainSlot.TextSize=UI.font(w); supportingSlot.TextSize=UI.font(w)
 arrangeExercise()
 local exit=latihanFrame.TutupBtn; exit.AnchorPoint=Vector2.new(.5,1); exit.Position=UDim2.new(.5,0,1,-16); exit.Size=UDim2.new(1,-40,0,52); UI.action(exit,"Tutup latihan"); exit.Size=UDim2.new(.42,0,0,48); refreshExit()
end)

local function resetLatihan()
	selectedCard = nil
	slots.main = nil
	slots.supporting = nil
	feedback.Text = ""
	mainSlot.Text = "Pesan utama\nBelum terisi — pilih kartu pada daftar kartu, lalu klik tempat ini"
	supportingSlot.Text = "Informasi pendukung\nBelum terisi — pilih kartu pada daftar kartu, lalu klik tempat ini"
	checkButton.Active = true
	refreshCards()
end

latihanPrompt.Triggered:Connect(function(triggeredPlayer)
	if triggeredPlayer == player then
		if not (guideVisited and infoVisited and completed[1] and completed[2] and completed[3]) then
			explainPrerequisite("Latihan terbuka setelah papan informasi dan ketiga audio selesai.")
			return
		end
		hideAll()
		refreshCards() -- Keep choices and feedback when reopening this session.
		level1Gui.Enabled = true
		overlay.Visible = true
		GuiAnimation.Show(latihanFrame)
		exitState.enabled=latihanCompleted; refreshExit()
		PlayerControl.Lock()
	end
end)

latihanFrame.TutupBtn.MouseButton1Click:Connect(function()
	if not exitState.enabled then return end
	GuiAnimation.Hide(latihanFrame)
	overlay.Visible = false
	level1Gui.Enabled = false
	PlayerControl.Unlock()
end)

local function updateSlotText()
	local main = slots.main and cardById[slots.main].text or "(Ketuk kartu, lalu ketuk tempat ini)"
	local supporting = slots.supporting and cardById[slots.supporting].text or "(Ketuk kartu, lalu ketuk tempat ini)"
	mainSlot.Text = "Pesan utama\n" .. main
	supportingSlot.Text = "Informasi pendukung\n" .. supporting
end

checkButton.MouseButton1Click:Connect(function()
	updateSlotText()
	if not slots.main or not slots.supporting then
		feedback.TextColor3 = Color3.fromRGB(170, 90, 50)
		feedback.Text = "Isi kedua tempat terlebih dahulu."
		return
	end
	recordLearning("practice", {activity="slots", choices={slots.main,slots.supporting}})
	local correct = slots.main == "A" and slots.supporting == "B"
	if correct then
		latihanCompleted = true
		exitState.enabled = true; refreshExit()
		feedback.TextColor3 = Color3.fromRGB(40, 140, 60)
		feedback.BackgroundColor3 = Color3.fromRGB(220,240,218)
		checkButton.Visible=false
		feedback.Text = "SELESAI — Tepat. Pesan utama merangkum peran sistem operasi; informasi pendukung merinci sumber daya yang dikelolanya. Latihan selesai."
		checkButton.Active = false
		checkButton.AutoButtonColor = false
	else
		feedback.TextColor3 = Color3.fromRGB(180, 70, 45)
		feedback.BackgroundColor3=Color3.fromRGB(255,233,215)
		feedback.Text = "BELUM TEPAT — Periksa kembali penempatannya: mana yang merangkum seluruh pembahasan dan mana yang memberi rincian khusus?"
	end
end)

-- ===== Kios Evaluasi Level 1 =====
local kioskModel = workspace:WaitForChild("Level1Development"):WaitForChild("L1_KiosEvaluasi")
-- Anchor khusus mencegah prompt menempel pada bagian dekorasi kios yang tidak terjangkau.
local kioskPromptPart = kioskModel:FindFirstChild("L1KioskInteractionAnchor")
if not kioskPromptPart then
	local kioskCFrame, kioskSize = kioskModel:GetBoundingBox()
	kioskPromptPart = Instance.new("Part")
	kioskPromptPart.Name = "L1KioskInteractionAnchor"
	kioskPromptPart.Anchored = true
	kioskPromptPart.CanCollide = false
	kioskPromptPart.CanTouch = false
	kioskPromptPart.CanQuery = false
	kioskPromptPart.Transparency = 1
	kioskPromptPart.Size = Vector3.new(1, 1, 1)
	kioskPromptPart.CFrame = kioskCFrame * CFrame.new(0, math.max(1.5, kioskSize.Y * 0.2), 0)
	kioskPromptPart.Parent = kioskModel
end
guideTargets.kiosk = kioskPromptPart
do
	local kioskPrompt = kioskPromptPart:FindFirstChild("L1KioskPrompt")
	if not kioskPrompt then
		kioskPrompt = Instance.new("ProximityPrompt")
		kioskPrompt.Name = "L1KioskPrompt"
		kioskPrompt.ActionText = "Buka evaluasi"
		kioskPrompt.ObjectText = "Evaluasi Level 1"
		kioskPrompt.KeyboardKeyCode = Enum.KeyCode.E
		kioskPrompt.HoldDuration = 1
		kioskPrompt.MaxActivationDistance = 16
		kioskPrompt.RequiresLineOfSight = false
		kioskPrompt.Parent = kioskPromptPart
	end
	local kioskLabel = kioskPromptPart:FindFirstChild("L1KioskLabel")
	if kioskLabel then kioskLabel:Destroy() end

	local oldKioskFrame = level1Gui:FindFirstChild("L1KioskFrame")
	if oldKioskFrame then oldKioskFrame:Destroy() end
	local kioskFrame = Instance.new("Frame")
	kioskFrame.Name = "L1KioskFrame"
	kioskFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	kioskFrame.Position = UDim2.fromScale(0.5, 0.5)
	kioskFrame.Size = UDim2.fromScale(0.58, 0.54)
	kioskFrame.BackgroundColor3 = Color3.fromRGB(246, 224, 207)
	kioskFrame.Visible = false
	kioskFrame.ZIndex = 20
	kioskFrame.Parent = level1Gui
	local kioskCorner = Instance.new("UICorner")
	kioskCorner.CornerRadius = UDim.new(0, 16)
	kioskCorner.Parent = kioskFrame
	local kioskStroke = Instance.new("UIStroke")
	kioskStroke.Color = Color3.fromRGB(154, 103, 76)
	kioskStroke.Thickness = 2
	kioskStroke.Parent = kioskFrame

	local kioskTitle = Instance.new("TextLabel")
	kioskTitle.BackgroundTransparency = 1
	kioskTitle.Position = UDim2.new(0.06, 0, 0.07, 0)
	kioskTitle.Size = UDim2.new(0.88, 0, 0.14, 0)
	kioskTitle.Font = Enum.Font.GothamBold
	kioskTitle.TextSize = 30
	kioskTitle.TextColor3 = Color3.fromRGB(70, 47, 37)
	kioskTitle.Text = "Evaluasi Level 1"
	kioskTitle.ZIndex = 21
	kioskTitle.Parent = kioskFrame

	local kioskMessage = Instance.new("TextLabel")
	kioskMessage.BackgroundTransparency = 1
	kioskMessage.Position = UDim2.new(0.08, 0, 0.23, 0)
	kioskMessage.Size = UDim2.new(0.84, 0, 0.38, 0)
	kioskMessage.Font = Enum.Font.Gotham
	kioskMessage.TextSize = 22
	kioskMessage.TextWrapped = true
	kioskMessage.TextColor3 = Color3.fromRGB(75, 55, 45)
	kioskMessage.ZIndex = 21
	kioskMessage.Parent = kioskFrame

	local startEvaluation = Instance.new("TextButton")
	startEvaluation.Position = UDim2.new(0.52, 0, 0.72, 0)
	startEvaluation.Size = UDim2.new(0.4, 0, 0.14, 0)
	startEvaluation.BackgroundColor3 = Color3.fromRGB(190, 99, 66)
	startEvaluation.TextColor3 = Color3.new(1, 1, 1)
	startEvaluation.Font = Enum.Font.GothamBold
	startEvaluation.TextSize = 20
	startEvaluation.Text = "Mulai evaluasi"
	startEvaluation.ZIndex = 21
	startEvaluation.Parent = kioskFrame
	local startCorner = Instance.new("UICorner")
	startCorner.CornerRadius = UDim.new(0, 9)
	startCorner.Parent = startEvaluation

	local closeKiosk = Instance.new("TextButton")
	closeKiosk.Position = UDim2.new(0.08, 0, 0.72, 0)
	closeKiosk.Size = UDim2.new(0.4, 0, 0.14, 0)
	closeKiosk.BackgroundColor3 = Color3.fromRGB(125, 102, 90)
	closeKiosk.TextColor3 = Color3.new(1, 1, 1)
	closeKiosk.Font = Enum.Font.GothamBold
	closeKiosk.TextSize = 20
	closeKiosk.Text = "Nanti dulu"
	closeKiosk.ZIndex = 21
	closeKiosk.Parent = kioskFrame
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 9)
	closeCorner.Parent = closeKiosk

	local kioskReading=UI.scroll(kioskFrame,"KioskReading")
 kioskMessage.Parent=kioskReading; kioskMessage.Position=UDim2.new(); kioskMessage.Size=UDim2.new(1,0,0,0); UI.autoText(kioskMessage,0,4)
 local function kioskLayout(w)
  kioskTitle.TextWrapped=true; kioskTitle.TextSize=UI.font(w,true)
  kioskTitle.Position=UDim2.fromOffset(20,20); kioskTitle.Size=UDim2.new(1,-40,0,64)
  kioskReading.Position=UDim2.fromOffset(20,90); kioskReading.Size=UDim2.new(1,-40,1,-178); kioskMessage.TextSize=UI.font(w)
  startEvaluation.AnchorPoint=Vector2.new(1,1); startEvaluation.Position=UDim2.new(1,-20,1,-20); startEvaluation.Size=UDim2.new(.48,0,0,56)
  closeKiosk.AnchorPoint=Vector2.new(0,1); closeKiosk.Position=UDim2.new(0,20,1,-20); closeKiosk.Size=UDim2.new(.48,-10,0,56)
 end
 UI.fit(kioskFrame,kioskLayout)
 kioskFrame:GetPropertyChangedSignal("Visible"):Connect(function() if kioskFrame.Visible then task.defer(function() kioskLayout(kioskFrame.AbsoluteSize.X) end) end end)

	local function closeKioskFrame()
		kioskFrame.Visible = false
		overlay.Visible = false
		level1Gui.Enabled = false
		PlayerControl.Unlock()
	end

	-- Evaluasi mandiri: tier 1 jawaban, tier 2 alasan, lalu feedback.
	-- Tidak memakai quizFrame baseline karena handler lamanya masih mengarahkan ulang ke audioChoose.
	local oldEvaluation = level1Gui:FindFirstChild("L1TwoTierEvaluation")
	if oldEvaluation then oldEvaluation:Destroy() end
	local evaluationFrame = Instance.new("Frame")
	evaluationFrame.Name = "L1TwoTierEvaluation"
	evaluationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	evaluationFrame.Position = UDim2.fromScale(0.5, 0.5)
	evaluationFrame.Size = UDim2.fromScale(0.88, 0.92)
	evaluationFrame.BackgroundColor3 = Color3.fromRGB(246, 224, 207)
	evaluationFrame.Visible = false
	evaluationFrame.ZIndex = 30
	evaluationFrame.Parent = level1Gui
	local evaluationCorner = Instance.new("UICorner")
	evaluationCorner.CornerRadius = UDim.new(0, 16)
	evaluationCorner.Parent = evaluationFrame
	local evaluationStroke = Instance.new("UIStroke")
	evaluationStroke.Color = Color3.fromRGB(154, 103, 76)
	evaluationStroke.Thickness = 2
	evaluationStroke.Parent = evaluationFrame

	local function makeText(parent, name, position, size, textSize, bold)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.BackgroundTransparency = 1
		label.Position = position
		label.Size = size
		label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
		label.TextSize = textSize
		label.TextColor3 = Color3.fromRGB(70, 47, 37)
		label.TextWrapped = true
		label.ZIndex = 31
		label.Parent = parent
		return label
	end

	local evaluationTitle = makeText(evaluationFrame, "Title", UDim2.new(0.06, 0, 0.025, 0), UDim2.new(0.88, 0, 0.10, 0), 32, true)
	-- One reading area grows with wrapped text; the action buttons stay outside it.
	local readingArea = Instance.new("ScrollingFrame")
	readingArea.Name = "EvaluationReadingArea"
	readingArea.BackgroundTransparency = 1
	readingArea.BorderSizePixel = 0
	readingArea.Position = UDim2.fromScale(.07, .15)
	readingArea.Size = UDim2.fromScale(.86, .57)
	readingArea.CanvasSize = UDim2.new()
	readingArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	readingArea.ScrollBarThickness = 6
	readingArea.ZIndex = 31
	readingArea.Parent = evaluationFrame
	local readingLayout = Instance.new("UIListLayout", readingArea)
	readingLayout.SortOrder = Enum.SortOrder.LayoutOrder
	readingLayout.Padding = UDim.new(0, 20)
	local evaluationStem = makeText(readingArea, "Stem", UDim2.new(), UDim2.new(1, -14, 0, 0), 26, true)
	evaluationStem.AutomaticSize = Enum.AutomaticSize.Y
	evaluationStem.TextXAlignment = Enum.TextXAlignment.Left
	evaluationStem.TextYAlignment = Enum.TextYAlignment.Top
	evaluationStem.LayoutOrder = 1
	local selectedSummary = makeText(readingArea, "SelectedSummary", UDim2.new(), UDim2.new(1, -14, 0, 0), 23, false)
	selectedSummary.AutomaticSize = Enum.AutomaticSize.Y
	selectedSummary.TextXAlignment = Enum.TextXAlignment.Left
	selectedSummary.LayoutOrder = 2
	selectedSummary.Visible = false
	local options = Instance.new("Frame")
	options.Name = "Options"
	options.BackgroundTransparency = 1
	options.BorderSizePixel = 0
	options.Size = UDim2.new(1, -14, 0, 0)
	options.AutomaticSize = Enum.AutomaticSize.Y
	options.LayoutOrder = 3
	options.ZIndex = 31
	options.Parent = readingArea
	local optionLayout = Instance.new("UIListLayout")
	optionLayout.Padding = UDim.new(0, 12)
	optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optionLayout.Parent = options
	local status = makeText(evaluationFrame, "Status", UDim2.new(0.07, 0, 0.74, 0), UDim2.new(0.86, 0, 0.11, 0), 24, false)
	status.TextColor3 = Color3.fromRGB(100, 70, 55)
	local submit = Instance.new("TextButton")
	submit.Name = "Submit"
	submit.AnchorPoint = Vector2.new(0.5, 0)
	submit.Position = UDim2.new(0.5, 0, 0.87, 0)
	submit.Size = UDim2.new(0.38, 0, 0.08, 0)
	submit.BackgroundColor3 = Color3.fromRGB(150, 140, 135)
	submit.TextColor3 = Color3.new(1, 1, 1)
	submit.Font = Enum.Font.GothamBold
	submit.TextSize = 24
	submit.TextWrapped = true
	submit.Text = "Pilih jawaban terlebih dahulu"
	submit.Active = false
	submit.AutoButtonColor = false
	submit.ZIndex = 31
	submit.Parent = evaluationFrame
	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 9)
	submitCorner.Parent = submit

	local evaluationQuestions = {
		{ stem = "Berdasarkan narasi audio yang disampaikan, sistem operasi dapat diartikan sebagai …", options = {"A. Perangkat keras utama yang berfungsi menjalankan aplikasi", "B. Perangkat lunak yang berfungsi mengelola sumber daya komputer", "C. Program tambahan yang digunakan untuk mempercepat kinerja komputer", "D. Sistem jaringan yang menghubungkan komputer dengan internet", "E. Media penyimpanan data yang digunakan oleh pengguna"}, reasons = {"A. Narasi menyebut OS sebagai perangkat keras yang menjalankan aplikasi.", "B. Narasi menyebut OS sebagai perangkat lunak pengelola sumber daya.", "C. Narasi membatasi tugas OS pada pengaturan jaringan dan akses internet.", "D. Narasi menyamakan OS dengan perangkat penyimpanan data milik pengguna."}, answer = 2, reason = 2, f1 = {"OS disebut perangkat lunak, bukan perangkat keras utama.", "Benar. OS adalah perangkat lunak yang mengelola sumber daya komputer.", "Narasi menjelaskan pengelolaan sumber daya, bukan program tambahan untuk mempercepat komputer.", "Jaringan internet tidak sama dengan OS yang dimaksud narasi.", "Penyimpanan adalah salah satu sumber daya yang dikelola, bukan pengertian OS."}, f2 = {"Alasan A mengubah OS menjadi perangkat keras; narasi menyebut perangkat lunak.", "Alasan B tepat: narasi merinci sumber daya yang dikelola perangkat lunak.", "Alasan C mempersempit isi menjadi internet, padahal narasi membahas berbagai sumber daya.", "Alasan D menyamakan pengelola dengan penyimpanan yang dikelola."} },
		{ stem = "Salah satu peran utama sistem operasi menurut narasi audio adalah …", options = {"A. Menggantikan fungsi perangkat keras komputer", "B. Menyimpan seluruh data pengguna secara permanen", "C. Menjadi penghubung antara pengguna dan aplikasi", "D. Mengendalikan jaringan internet secara langsung", "E. Menjalankan aplikasi tanpa bantuan perangkat keras"}, reasons = {"A. Narasi menyebut OS sebagai penghubung antara pengguna dan aplikasi.", "B. Narasi menyebut OS sebagai pengganti seluruh perangkat keras komputer.", "C. Narasi menyebut OS sebagai tempat penyimpanan permanen seluruh data.", "D. Narasi menyebut OS sebagai pengelola layanan internet pada komputer."}, answer = 3, reason = 1, f1 = {"Penghubung tidak berarti menggantikan perangkat keras.", "Menyimpan seluruh data secara permanen bukan peran yang ditanyakan dalam narasi.", "Benar. Narasi menyebut OS sebagai penghubung pengguna dan aplikasi.", "Mengendalikan internet bukan peran penghubung yang dijelaskan narasi.", "Narasi tidak menyatakan aplikasi berjalan tanpa perangkat keras."}, f2 = {"Alasan A tepat: hubungan pengguna dan aplikasi dinyatakan dalam narasi.", "Alasan B tidak tepat karena menjadi penghubung tidak menghapus kebutuhan perangkat keras.", "Alasan C tidak menunjukkan hubungan pengguna dan aplikasi yang ditanyakan.", "Alasan D membatasi OS pada internet, berbeda dari peran yang dijelaskan."} },
		{ stem = "Implementasi nyata dari pemahaman fungsi sistem operasi dalam mengelola sumber daya komputer secara optimal adalah …", options = {"A. Mendesain ulang perangkat keras komputer agar seluruh aplikasi berjalan tanpa sistem operasi", "B. Mengatur alokasi prosesor dan memori agar aplikasi dan sistem dapat bekerja secara terpadu", "C. Menghubungkan komputer ke jaringan internet agar semua perangkat lunak dapat diperbarui secara otomatis", "D. Menambahkan perangkat penyimpanan eksternal untuk memperbesar kapasitas data pengguna", "E. Menginstal sebanyak mungkin aplikasi agar kinerja komputer meningkat secara maksimal"}, reasons = {"A. Audio mengaitkan penambahan jumlah aplikasi dengan peningkatan kinerja komputer.", "B. Audio mengaitkan pemasangan perangkat tambahan dengan percepatan seluruh aplikasi.", "C. Audio mengaitkan pengelolaan sumber daya dengan kerja terpadu aplikasi dan sistem.", "D. Audio mengaitkan penggunaan internet dengan penggantian fungsi pengelolaan memori komputer."}, answer = 2, reason = 3, f1 = {"Merancang ulang perangkat keras bukan contoh pengelolaan sumber daya dalam audio.", "Benar. Pengelolaan prosesor dan memori sesuai peran OS yang dibahas.", "Pembaruan melalui internet berbeda dari alokasi sumber daya yang ditanyakan.", "Menambah kapasitas penyimpanan berbeda dari mengatur prosesor dan memori.", "Narasi tidak menyatakan semakin banyak aplikasi selalu meningkatkan kinerja."}, f2 = {"Alasan A tidak didukung: audio tidak menghubungkan banyaknya aplikasi dengan peningkatan kinerja.", "Alasan B menambah klaim bahwa perangkat tambahan otomatis mempercepat seluruh aplikasi.", "Alasan C tepat: pengelolaan sumber daya dihubungkan dengan kerja terpadu aplikasi dan sistem.", "Alasan D mengganti pengelolaan memori dengan internet, yang tidak dijelaskan audio."} },
		{ stem = "Dalam narasi audio, apa yang terjadi jika sistem operasi tidak mampu menjalankan peran penghubung pengguna dan aplikasi dengan baik?", options = {"A. Aplikasi akan berjalan lebih cepat karena tidak ada perantara", "B. Pengguna dapat langsung mengakses perangkat keras tanpa hambatan", "C. Perangkat keras akan meningkatkan kinerjanya secara mandiri", "D. Sistem operasi akan digantikan secara otomatis oleh aplikasi lain", "E. Aplikasi tidak dapat berjalan dengan baik karena komunikasi antara pengguna dan perangkat terganggu"}, reasons = {"A. Audio menyebut aplikasi mengambil alih seluruh tugas OS secara otomatis.", "B. Audio menyebut perangkat keras menambah kemampuannya sendiri saat OS terganggu.", "C. Audio menyebut kegagalan penghubung membuat aplikasi berjalan semakin cepat.", "D. Audio menyebut gangguan peran OS menghambat aplikasi berjalan dengan baik."}, answer = 5, reason = 4, f1 = {"Kegagalan penghubung dalam narasi mengganggu aplikasi, bukan mempercepatnya.", "Narasi tidak menyatakan kegagalan OS membuat akses perangkat keras menjadi tanpa hambatan.", "Kenaikan kemampuan perangkat keras secara mandiri tidak dinyatakan dalam audio.", "Pergantian OS oleh aplikasi secara otomatis tidak dinyatakan dalam audio.", "Benar. Akibat yang dinyatakan adalah aplikasi tidak dapat berjalan dengan baik."}, f2 = {"Alasan A tidak didukung: aplikasi tidak disebut mengambil alih seluruh tugas OS.", "Alasan B menambahkan kenaikan kemampuan perangkat keras yang tidak dinyatakan.", "Alasan C membalik akibat: kegagalan penghubung mengganggu, bukan mempercepat aplikasi.", "Alasan D tepat: kegagalan peran OS dikaitkan dengan aplikasi yang tidak berjalan baik."} },
	}
	local currentQuestion, currentTier, selectedAnswer, selectedReason = 1, 1, nil, nil
	local evaluationMode = "tier"
	local answerCorrect, reasonCorrect = 0, 0
	local attemptId, recordedAnswers, recordedReasons
	local optionButtons = {}
	local function setSubmit(enabled, text)
		submit.Active = enabled
		submit.AutoButtonColor = enabled
		submit.BackgroundColor3 = enabled and Color3.fromRGB(190, 99, 66) or Color3.fromRGB(150, 140, 135)
		submit.Text = text
	end
	local renderEvaluation
	local resultProgressConnection
	local lastResult
	local retry = submit:Clone()
	retry.Name = "RetryEvaluation"
	retry.Text = "Coba lagi"
	retry.Visible = false
	retry.Parent = evaluationFrame
	status.Parent=readingArea; status.LayoutOrder=0; status.AnchorPoint=Vector2.zero; status.Position=UDim2.new(); status.Size=UDim2.new(1,-14,0,0)
 UI.autoText(status,40,4)
 local function evaluationLayout()
  local w=evaluationFrame.AbsoluteSize.X
  evaluationTitle.TextSize=UI.font(w,true)
  local hh=math.max(48,UI.height(evaluationTitle,w-40,8))
  evaluationTitle.Position=UDim2.fromOffset(20,16); evaluationTitle.Size=UDim2.new(1,-40,0,hh)
  readingArea.Position=UDim2.fromOffset(20,hh+30); readingArea.Size=UDim2.new(1,-40,1,-(hh+114))
  submit.AnchorPoint=Vector2.new(.5,1); retry.AnchorPoint=Vector2.new(.5,1)
  submit.Position=UDim2.new(retry.Visible and .25 or .5,0,1,-16); retry.Position=UDim2.new(.75,0,1,-16)
  submit.Size=UDim2.new(retry.Visible and .40 or .48,0,0,52); retry.Size=UDim2.new(.40,0,0,52)
  submit.TextSize=20; retry.TextSize=20; status.TextSize=UI.font(w)
 end
 UI.fit(evaluationFrame,evaluationLayout)
 evaluationTitle:GetPropertyChangedSignal("Text"):Connect(evaluationLayout)
 submit:GetPropertyChangedSignal("Position"):Connect(evaluationLayout)
 retry:GetPropertyChangedSignal("Visible"):Connect(evaluationLayout)

	local resultDetails=UI.label(readingArea,"",20)
 resultDetails.LayoutOrder=4; resultDetails.TextXAlignment=Enum.TextXAlignment.Center; resultDetails.Visible=false
 local resultCrown=Instance.new("ImageLabel",readingArea)
 resultCrown.Name="ResultCrown"; resultCrown.BackgroundTransparency=1; resultCrown.Size=UDim2.new(1,-14,0,78); resultCrown.ScaleType=Enum.ScaleType.Fit; resultCrown.LayoutOrder=-2; resultCrown.Visible=false
 local oldResult=quizFrame:FindFirstChild("ResultBackground")
 local oldSuccess=oldResult and oldResult:FindFirstChild("ResultLulus")
 local oldCrown=oldSuccess and oldSuccess:FindFirstChildWhichIsA("ImageLabel")
 if oldCrown then resultCrown.Image=oldCrown.Image end
 local function showResult(review)
		readingArea.CanvasPosition = Vector2.zero
		evaluationStem.TextSize = evaluationFrame.AbsoluteSize.X<600 and 38 or 46
		evaluationStem.TextXAlignment = Enum.TextXAlignment.Center
  evaluationStem.BackgroundTransparency=1
  UI.autoText(evaluationStem,72,8)
		if resultProgressConnection then resultProgressConnection:Disconnect(); resultProgressConnection = nil end
		if not review then lastResult = { answers = answerCorrect, reasons = reasonCorrect } end
		evaluationMode = "result"
		for _, child in ipairs(options:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		selectedSummary.Visible = false
		evaluationTitle.Text = answerCorrect >= 3 and "Level 1 — Lulus" or "Level 1 — Belum lulus"
		evaluationStem.Text = (answerCorrect * 25) .. " / 100"
  resultDetails.Text="Jawaban tepat: "..answerCorrect.." dari 4     •     Alasan tepat: "..reasonCorrect.." dari 4\nKelulusan berdasarkan skor jawaban; alasan dicatat terpisah."
  resultDetails.Visible=true; resultCrown.Visible=answerCorrect>=3
		if not review then game:GetService("ReplicatedStorage"):WaitForChild("UpdateLevel1Score"):FireServer({id=attemptId,answers=recordedAnswers,reasons=recordedReasons}) end
		retry.Visible = answerCorrect < 3
		retry.Active = true
		retry.AutoButtonColor = true
		retry.BackgroundColor3 = Color3.fromRGB(190, 99, 66)
		retry.Position = UDim2.new(.73, 0, .87, 0)
		submit.Position = UDim2.new(answerCorrect < 3 and .27 or .5, 0, .87, 0)
		if answerCorrect >= 3 then
			evaluationPassed = true
			status.Text = "Nilai memenuhi syarat. Menunggu konfirmasi akses Level 2 dari server…"
			local progress = player:WaitForChild("leaderstats"):WaitForChild("LevelProgress")
			local function confirmAccess()
				if progress.Value >= 2 and evaluationMode == "result" then
					status.Text = "Level 2 terbuka. Tutup hasil dan ikuti panah menuju gedung Level 2."
				end
			end
			resultProgressConnection = progress:GetPropertyChangedSignal("Value"):Connect(confirmAccess)
			confirmAccess()
		else
			status.Text = "Nilai minimal untuk melanjutkan adalah 75. Pelajari kembali bagian yang belum dipahami, lalu kembali ke kios untuk mencoba evaluasi lagi."
		end
		setSubmit(true, answerCorrect >= 3 and "Lanjut ke Level 2" or "Belajar lagi")
	end
	renderEvaluation = function()
  resultDetails.Visible=false; resultCrown.Visible=false
		readingArea.CanvasPosition = Vector2.zero
		evaluationStem.TextSize = evaluationFrame.AbsoluteSize.X<600 and 20 or 22
		evaluationStem.TextXAlignment = Enum.TextXAlignment.Left
  evaluationStem.BackgroundTransparency=1; UI.autoText(evaluationStem,40,4)
		retry.Visible = false
		submit.Position = UDim2.new(.5, 0, .87, 0)
		evaluationMode = "tier"
		for _, child in ipairs(options:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		optionButtons = {}
		local q = evaluationQuestions[currentQuestion]
		if currentTier == 1 then
			evaluationTitle.Text = "Evaluasi " .. currentQuestion .. "/4 — Tingkat 1: Jawaban"
			evaluationStem.Text = q.stem
			selectedSummary.Visible = false
			status.Text = "Pilih satu jawaban, lalu lanjutkan ke alasan."
			setSubmit(selectedAnswer ~= nil, selectedAnswer and "Lanjut ke alasan" or "Pilih jawaban terlebih dahulu")
		else
			evaluationTitle.Text = "Evaluasi " .. currentQuestion .. "/4 — Tingkat 2: Alasan"
			evaluationStem.Text = "Alasan atau bukti manakah yang paling tepat mendukung jawaban pada tingkat pertama?"
			selectedSummary.Visible = true
			selectedSummary.Text = "Jawaban yang dipilih: " .. q.options[selectedAnswer]
			status.Text = "Pilih satu alasan, lalu kirim kedua jawaban."
			setSubmit(selectedReason ~= nil, selectedReason and "Kirim jawaban" or "Pilih alasan terlebih dahulu")
		end
		local entries = currentTier == 1 and q.options or q.reasons
		for index, text in ipairs(entries) do
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, -8, 0, 76)
			button.AutomaticSize = Enum.AutomaticSize.Y
			button.LayoutOrder = index
			button.BackgroundColor3 = Color3.fromRGB(232, 210, 196)
			button.TextColor3 = Color3.fromRGB(70, 47, 37)
			button.Font = Enum.Font.Gotham
			button.TextSize = UI.font(evaluationFrame.AbsoluteSize.X)
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.TextWrapped = true
			button.Text = text
			button.ZIndex = 32
			button.Parent = options
			button.BorderSizePixel = 0
			Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
			local padding = Instance.new("UIPadding", button)
			padding.PaddingLeft = UDim.new(0, 16)
			padding.PaddingRight = UDim.new(0, 16)
			padding.PaddingTop = UDim.new(0, 12)
			padding.PaddingBottom = UDim.new(0, 12)
			optionButtons[index] = button
			button.MouseButton1Click:Connect(function()
				if currentTier == 1 then selectedAnswer = index else selectedReason = index end
				for i, other in pairs(optionButtons) do other.BackgroundColor3 = i == index and Color3.fromRGB(103, 151, 199) or Color3.fromRGB(232, 210, 196) end
				setSubmit(true, currentTier == 1 and "Lanjut ke alasan" or "Kirim jawaban")
			end)
		end
	end
	submit.MouseButton1Click:Connect(function()
		if evaluationMode == "result" then
			if lastResult and lastResult.answers < 3 then reviewingInfo = true end
			evaluationFrame.Visible = false
			overlay.Visible = false
			level1Gui.Enabled = false
			PlayerControl.Unlock()
			return
		end
		if evaluationMode == "feedback" then
			if currentQuestion < #evaluationQuestions then
				currentQuestion += 1
				currentTier, selectedAnswer, selectedReason = 1, nil, nil
				renderEvaluation()
			else
				showResult()
			end
			return
		end
		if currentTier == 1 and selectedAnswer then
			currentTier = 2
			renderEvaluation()
		elseif currentTier == 2 and selectedReason then
			readingArea.CanvasPosition = Vector2.zero
			local q = evaluationQuestions[currentQuestion]
			recordedAnswers[currentQuestion], recordedReasons[currentQuestion] = selectedAnswer, selectedReason
			recordLearning("evaluation_item", {id=attemptId..":"..currentQuestion,attemptId=attemptId,question=currentQuestion,answer=selectedAnswer,reason=selectedReason})
			local answerOK, reasonOK = selectedAnswer == q.answer, selectedReason == q.reason
			if answerOK then answerCorrect += 1 end
			if reasonOK then reasonCorrect += 1 end
			for _, child in ipairs(options:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
			evaluationTitle.Text = (answerOK and "Jawaban tepat" or "Jawaban belum tepat") .. " • " .. (reasonOK and "Alasan tepat" or "Alasan belum tepat")
			evaluationStem.Text = q.f1[selectedAnswer] .. "\n\n" .. q.f2[selectedReason]
			selectedSummary.Visible = true
			selectedSummary.Text = "Nilai jawaban soal ini: " .. (answerOK and "25 dari 25" or "0 dari 25") .. ". Ketepatan alasan dicatat terpisah."
			status.Text = "Jawaban dan alasan pada soal ini sudah dikirim dan tidak dapat diubah."
			setSubmit(true, currentQuestion < #evaluationQuestions and "Soal berikutnya" or "Lihat hasil")
			evaluationMode = "feedback"
		end
	end)
	local function openEvaluation()
		if resultProgressConnection then resultProgressConnection:Disconnect(); resultProgressConnection = nil end
		currentQuestion, currentTier, selectedAnswer, selectedReason = 1, 1, nil, nil
		answerCorrect, reasonCorrect = 0, 0
		attemptId, recordedAnswers, recordedReasons = recordHttp:GenerateGUID(false), {}, {}
		evaluationMode = "tier"
		quizFrame.Visible = false
		evaluationFrame.Visible = true
		renderEvaluation()
	end
	retry.MouseButton1Click:Connect(function()
		if evaluationMode == "result" and lastResult and lastResult.answers < 3 then openEvaluation() end
	end)

	kioskPrompt.Triggered:Connect(function(triggeredPlayer)
		if triggeredPlayer ~= player then return end
		if lastResult then
			answerCorrect, reasonCorrect = lastResult.answers, lastResult.reasons
			hideAll()
			kioskFrame.Visible = false
			evaluationFrame.Visible = true
			level1Gui.Enabled = true
			overlay.Visible = true
			PlayerControl.Lock()
			showResult(true)
			return
		end
		level1Gui.Enabled = true
		overlay.Visible = true
		kioskFrame.Visible = true
		PlayerControl.Lock()
		if latihanCompleted then
			kioskMessage.Text = "Siap mengikuti evaluasi Level 1?\n\nAda 4 soal. Jawaban benar bernilai 25 dan nilai minimal untuk melanjutkan adalah 75."
			startEvaluation.Visible = true
			startEvaluation.Position = UDim2.new(0.52, 0, 0.72, 0)
			closeKiosk.Position = UDim2.new(0.08, 0, 0.72, 0)
			closeKiosk.Text = "Nanti dulu"
		else
			kioskMessage.Text = "Evaluasi belum dapat dimulai.\n\nSelesaikan latihan pesan utama dan informasi pendukung terlebih dahulu."
			startEvaluation.Visible = false
			closeKiosk.Position = UDim2.new(0.3, 0, 0.72, 0)
			closeKiosk.Text = "Kembali ke latihan"
		end
	end)

	closeKiosk.MouseButton1Click:Connect(closeKioskFrame)
	startEvaluation.MouseButton1Click:Connect(function()
		if not latihanCompleted then return end
		kioskFrame.Visible = false
		openEvaluation()
	end)
end

-- Restore the existing welcome screen for players; never show it in Edit mode.
task.spawn(function()
 local welcomeGui=playerGui:WaitForChild("Welcome GUI",15)
 if not welcomeGui then return end
 local frame=welcomeGui:WaitForChild("welcomeFrame",10)
 if not frame then return end
 UI.welcome(frame,"Selamat Datang di Pembelajaran Bahasa Indonesia!",{"Jelajahi kampus virtual sambil berlatih menyimak dan membaca materi Teknologi Informasi.","Ikuti panah kuning: selesaikan Level 1, Level 2, dan Level 3, lalu tuju aula apresiasi.","PC: gerak dengan WASD dan tahan E di dekat objek. HP: gunakan kontrol layar dan tahan tombol interaksi."},{{"lanjutButton","Lanjut ke kampus"}})
 UI.screen(welcomeGui); welcomeGui.ResetOnSpawn=false
 local shade=welcomeGui:FindFirstChild("BackgroundOverlay")
 if shade then shade.Position=UDim2.new(); shade.AnchorPoint=Vector2.zero; shade.Size=UDim2.fromScale(1,1) end
 task.wait(.5)
 if not player:GetAttribute("LearningWelcomeShown") then
  player:SetAttribute("LearningWelcomeShown",true)
  welcomeGui.Enabled=true; frame.Visible=true; if shade then shade.Visible=true end
  PlayerControl.Lock()
 end
end)

-- Explain blocked entrances without changing any collision or unlock requirement.
task.spawn(function()
 local progress=player:WaitForChild("leaderstats"):WaitForChild("LevelProgress")
 local lastNotice=0
 for _,spec in ipairs({{"Space2DoorBlock",2,"Level 2","Level 1"},{"Space3DoorBlock",3,"Level 3","Level 2"},{"ApresiasiDoorBlock",4,"aula apresiasi","Level 3"}}) do
  local door=workspace:WaitForChild(spec[1],15)
  if door and door:IsA("BasePart") then
   door.Touched:Connect(function(hit)
    if progress.Value>=spec[2] or not player.Character or not hit:IsDescendantOf(player.Character) then return end
    if os.clock()-lastNotice<8 then return end
    lastNotice=os.clock()
    showNotice("Akses "..spec[3].." belum terbuka.\n\nSelesaikan materi dan latihan "..spec[4]..", lalu raih nilai evaluasi minimal 75.\n\nKembali ke kegiatan yang ditunjuk panah. Setelah nilai dikonfirmasi server, pintu akan terbuka.")
   end)
  end
 end
end)
