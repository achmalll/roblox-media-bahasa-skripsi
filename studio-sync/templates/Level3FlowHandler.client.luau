local UI = nil -- RESPONSIVE_LIBRARY
-- Source template; build with scripts/build-level3.cjs. Session-local learning state.
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Input = game:GetService("UserInputService")
local DATA = nil -- GENERATED_CONTENT
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
 {path={"Space 3",""},key="intro",title="Pemandu Tahap 3",action="Bicara"},
 {path={"Level3Development","meja baca"},key="news",title="Abstrak Twizzler",action="Baca abstrak"},
 {path={"Space 3","Infoboard"},key="terms",title="Istilah dalam abstrak",action="Lihat istilah"},
 {path={"Level3Development","latihan 1"},key="evidence",title="Latihan 1 — Fungsi gagasan",action="Buka latihan"},
 {path={"Level3Development","latihan 2"},key="pairs",title="Latihan 2 — Batas simpulan",action="Buka latihan"},
 {path={"Level3Development","L3_NPC_PemanduBaca"},key="news",title="Pemandu abstrak",action="Baca abstrak"},
 {path={"Level3Development","L3_NPC_FungsiGagasan"},key="evidence",title="Fungsi gagasan",action="Buka latihan"},
 {path={"Level3Development","L3_NPC_BatasSimpulan"},key="pairs",title="Batas simpulan",action="Buka latihan"},
 {path={"Level3Development","L3_NPC_EvaluasiPria"},key="exam",title="Evaluasi Tahap 3",action="Buka evaluasi"},
 {path={"Level3Development","L3_NPC_EvaluasiWanita"},key="exam",title="Evaluasi Tahap 3",action="Buka evaluasi"},
 {path={"Level3Development","Evaluasi"},key="exam",title="Evaluasi Tahap 3",action="Buka evaluasi"},
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
 if progress.Value<3 then return "Selesaikan Tahap 2 dengan nilai minimal 75 terlebih dahulu." end
 if key=="intro" or key=="terms" then return nil end
 if not state.intro then return "Temui pemandu Tahap 3 dan pilih «Ke meja baca» terlebih dahulu." end
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
 local sc=list()
 if page==1 then
  text(sc,"Sumber bacaan\nOperating Systems for Far Out Memories",UI.font(panel.AbsoluteSize.X,true)).Font=Enum.Font.GothamBold
  text(sc,"Bacaan ini diadaptasi dari abstrak disertasi Daniel A. Bittman (2023), University of California, Santa Cruz.",16)
 end
 text(sc,DATA.headings[page],26); text(sc,DATA.pages[page])
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
evidence=function(feedback,focus)
 clear("Latihan 1 — Fungsi gagasan"); local sc=list()
 local matchBoard=Instance.new("Frame")
 matchBoard.Name="PapanFungsiGagasan"
 matchBoard.BackgroundTransparency=1
 matchBoard.Size=UDim2.new(1,0,0,0)
 matchBoard.LayoutOrder=#sc:GetChildren(); matchBoard.Parent=sc
 local function column(name)
  local frame=Instance.new("Frame")
  frame.Name=name; frame.BackgroundTransparency=1; frame.Parent=matchBoard
  local layout=Instance.new("UIListLayout",frame)
  layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,10)
  return frame,layout
 end
 local cards,cardLayout=column("KartuGagasan")
 local targets,targetLayout=column("FungsiTujuan")
 text(cards,"Kartu gagasan",20).Font=Enum.Font.GothamBold
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
  card.LayoutOrder=#cards:GetChildren(); card.Parent=cards
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
   if not state.done1 then selectedFunctionCard=i; evidence(nil,"targets") end
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
 text(targets,state.done1 and "Hasil pasangan" or "Fungsi tujuan",20).Font=Enum.Font.GothamBold
 for i,label in ipairs(functionNames) do
  local assigned
  for cardIndex=1,3 do
   if state.slots[cardIndex]==i then assigned=cardIndex; break end
  end
  local canAssign=not state.done1 and selectedFunctionCard~=nil and selectedFunctionCard~=assigned
  local checked=assigned and state.check1 and state.check1[assigned]
  local status=assigned and "Terisi" or "Kosong"
  local fill=assigned and Color3.fromRGB(218,235,249) or Color3.fromRGB(255,247,237)
  local edge=assigned and Color3.fromRGB(46,108,171) or Color3.fromRGB(163,126,105)
  if state.done1 or checked==true then
   status="✓ Tepat"
   fill=Color3.fromRGB(220,240,218); edge=Color3.fromRGB(51,127,68)
  elseif checked==false then
   status="Belum tepat"
   fill=Color3.fromRGB(251,231,226); edge=Color3.fromRGB(172,63,48)
  end
  if canAssign then status..=assigned and " · Ganti pasangan" or " · Pasangkan di sini" end
  local b=button(targets,label.."\n"..status,function()
   if assigned then
    state.slots[assigned]=nil
    if state.check1 then state.check1[assigned]=nil end
   end
   state.slots[selectedFunctionCard]=i
   if state.check1 then state.check1[selectedFunctionCard]=nil end
   selectedFunctionCard=nil; evidence(nil,"cards")
  end,canAssign)
  b.BackgroundColor3=fill
  b.Font=Enum.Font.GothamBold
  b.TextXAlignment=Enum.TextXAlignment.Center
  b.Selectable=canAssign
  local stroke=Instance.new("UIStroke",b)
  stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  stroke.Color=edge
  stroke.Thickness=assigned and 2 or 1
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
 practiceStatus(state.done1 and "SELESAI — Ketiga fungsi gagasan tepat." or feedback or
  (selectedFunctionCard and "Gagasan dipilih. Ketuk fungsi yang sesuai." or "Pilih kartu gagasan, lalu pilih fungsinya. Isi ketiga fungsi dan tekan Periksa."),
  state.done1,feedback~=nil)
 local function arrangeMatchBoard()
  local wide=matchBoard.AbsoluteSize.X>=700
  local cardHeight,targetHeight=cardLayout.AbsoluteContentSize.Y,targetLayout.AbsoluteContentSize.Y
  cards.Size=UDim2.new(wide and .58 or 1,wide and -8 or 0,0,cardHeight)
  targets.Size=UDim2.new(wide and .42 or 1,wide and -8 or 0,0,targetHeight)
  targets.Position=wide and UDim2.new(.58,8,0,0) or UDim2.fromOffset(0,cardHeight+16)
  matchBoard.Size=UDim2.new(1,0,0,wide and math.max(cardHeight,targetHeight) or cardHeight+targetHeight+16)
 end
 matchBoard:GetPropertyChangedSignal("AbsoluteSize"):Connect(arrangeMatchBoard)
 cardLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(arrangeMatchBoard)
 targetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(arrangeMatchBoard)
 arrangeMatchBoard()
 if focus then
  task.defer(function()
   game:GetService("RunService").Heartbeat:Wait()
   if not sc.Parent or matchBoard.AbsoluteSize.X>=700 then return end
   if focus=="cards" then sc.CanvasPosition=Vector2.zero; return end
   local targetY=targets.AbsolutePosition.Y-sc.AbsolutePosition.Y+sc.CanvasPosition.Y
   local maxY=math.max(0,sc.AbsoluteCanvasSize.Y-sc.AbsoluteWindowSize.Y)
   sc.CanvasPosition=Vector2.new(0,math.clamp(targetY,0,maxY))
  end)
 end
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
 if v.done then
  local revised=text(sc,"Simpulan hasil revisi\n"..r.final)
  revised.Font=Enum.Font.GothamBold
  revised.LayoutOrder=-10
 else
  text(sc,"Perbaiki simpulan agar sesuai dengan kutipan.",UI.font(panel.AbsoluteSize.X,true)).Font=Enum.Font.GothamBold
  text(sc,"Baca kutipan acuan. Dari tiga bagian draf, ketuk satu bagian yang isinya tidak bisa dibuktikan dari kutipan. Dua bagian lain tetap dipakai. Lalu tekan Periksa coretan.")
 end
 text(sc,"Kutipan acuan — Abstrak Twizzler",20).Font=Enum.Font.GothamBold
 text(sc,r.evidence[r.keyEvidence])
 text(sc,v.done and "Draf sebelum revisi" or "Pilih satu bagian simpulan yang tidak sesuai dengan isi kutipan di atas untuk dicoret.",20).Font=Enum.Font.GothamBold
 for i,part in ipairs(r.parts) do
  local selected=v.part==i
  local caption="Bagian "..i..(selected and (v.done and " — Dicoret" or " — Dipilih untuk dicoret") or "")
  local b=button(sc,caption.."\n"..part,function()
   if not v.done then v.part=v.part~=i and i or nil; pairView() end
  end,not v.done)
  if selected then
   local escaped=part:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")
   b.RichText=true
   b.Text="<b>"..caption.."</b>\n<s>"..escaped.."</s>"
  end
  b.BackgroundColor3=selected and Color3.fromRGB(222,237,249) or Color3.fromRGB(255,247,237)
  b.Selectable=not v.done
  local stroke=Instance.new("UIStroke",b)
  stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  stroke.Color=selected and Color3.fromRGB(46,108,171) or Color3.fromRGB(211,180,154)
  stroke.Thickness=selected and 2 or 1
 end
 navigation("Baca abstrak",function() news(function() pairView() end) end,v.done and (state.round==4 and "Ke kios evaluasi" or "Ronde berikutnya") or "Periksa coretan",function()
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
   if v.errors>=2 then f..=" Bantuan frasa: “"..r.proof.."”. Pilih kembali lalu tekan Periksa coretan." end
   pairView(f)
  end
 end,v.done or (v.part~=nil and v.evidence~=nil))
 if v.done or feedback or v.part then
  practiceStatus(v.done and "Tepat! Baca simpulan hasil revisi, lalu lanjutkan." or feedback or "Satu bagian dipilih. Tekan Periksa coretan.",v.done,feedback~=nil)
 end
end

resultView=function()
 local sc=evaluationClear("Hasil Evaluasi Tahap 3",result.unlocked and "Gedung tengah terbuka. Tutup hasil dan ikuti panah." or "Nilai minimal 75. Pelajari kembali abstrak, lalu kembali ke kios untuk mencoba lagi.")
 local passed=result.score>=75
 title.Text="Tahap 3 — "..(passed and "Lulus" or "Belum lulus")
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
 local sc=evaluationClear("Siap mengikuti evaluasi Tahap 3?","Jawaban benar bernilai 25. Nilai minimal untuk melanjutkan adalah 75.")
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
  clear("Tahap 3 — Membaca Teks Akademik"); local sc=list()
  local nextStation=state.intro and stage() or "news"
  local destinations={
   news={"Meja baca Abstrak Twizzler","Ke meja berkursi di sisi kanan ruangan jika kamu menghadap ke dalam dari pintu masuk. Saat muncul «Baca abstrak», tahan E di PC atau tahan tombol interaksi di HP.","Ke meja baca"},
   evidence={"Papan Fungsi Gagasan","Datangi papan Fungsi Gagasan untuk memasangkan tiga gagasan dengan fungsinya.","Ke papan gagasan"},
   pairs={"Papan Batas Simpulan","Datangi papan Batas Simpulan. Baca kutipan dan tandai bagian simpulan yang melampaui sumber.","Ke papan simpulan"},
   exam={"Kios Evaluasi Tahap 3","Datangi kios evaluasi untuk menjawab empat soal beserta alasannya.","Ke kios evaluasi"},
  }
  local destination=destinations[nextStation]
  text(sc,"Berikutnya — "..destination[1],UI.font(panel.AbsoluteSize.X,true)).Font=Enum.Font.GothamBold
  local arrowHint=progress.Value==3 and "Setelah panel tertutup, ikuti panah kuning. " or ""
  text(sc,arrowHint..destination[2])
  text(sc,"Alur Tahap 3: baca tiga bagian abstrak, kerjakan dua latihan, lalu ikuti evaluasi. Nilai minimal 75 membuka aula apresiasi.")
  navigation(nil,nil,destination[3],function()
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
