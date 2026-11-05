local UI = nil -- RESPONSIVE_LIBRARY
-- Source template; build with scripts/build-level2.cjs. Session-local learning state.
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
