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
noticeGui.Name="L3StageNotice"; noticeGui.ResetOnSpawn=false; noticeGui.DisplayOrder=70; noticeGui.Parent=pg
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
local evaluationFooter,evaluationStatus,navigationFooter,practiceFeedback
local evaluationButtons={}
local function clear(heading)
 if practiceFeedback then practiceFeedback:Destroy(); practiceFeedback=nil end
 evaluationButtons={}
 if navigationFooter then navigationFooter:Destroy(); navigationFooter=nil end
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
-- Fixed navigation: secondary action left, primary action right, reading stays scrollable.
local function navigation(leftLabel,leftAction,rightLabel,rightAction,rightEnabled)
 body.Size=UDim2.new(1,-40,1,-180)
 navigationFooter=Instance.new("Frame")
 navigationFooter.BackgroundTransparency=1; navigationFooter.Position=UDim2.new(0,20,1,-76)
 navigationFooter.Size=UDim2.new(1,-40,0,56); navigationFooter.Parent=panel
 local function action(label,callback,right)
  if not label then return end
  local enabled=nil; if right then enabled=rightEnabled end
  local b=button(navigationFooter,label,callback,enabled)
  b.AutomaticSize=Enum.AutomaticSize.None; b.Size=UDim2.new(.44,0,1,0)
  local cap=Instance.new("UISizeConstraint",b); cap.MaxSize=Vector2.new(280,56)
  b.AnchorPoint=Vector2.new(right and 1 or 0,0); b.Position=UDim2.fromScale(right and 1 or 0,0)
  b.TextSize=21
  if not right then b.BackgroundColor3=Color3.fromRGB(125,102,90) end
 end
 action(leftLabel,leftAction,false); action(rightLabel,rightAction,true)
end
local function practiceStatus(value,done,warning)
 body.Size=UDim2.new(1,-40,1,-282)
 practiceFeedback=Instance.new("TextLabel")
 practiceFeedback.Name="PracticeStatus"; practiceFeedback.Position=UDim2.new(0,20,1,-178)
 practiceFeedback.Size=UDim2.new(1,-40,0,90); practiceFeedback.TextWrapped=true
 practiceFeedback.Font=Enum.Font.GothamBold; practiceFeedback.TextSize=21
 practiceFeedback.TextColor3=Color3.fromRGB(40,55,35)
 practiceFeedback.BackgroundColor3=done and Color3.fromRGB(220,240,218) or (warning and Color3.fromRGB(255,233,215) or Color3.fromRGB(250,239,230))
 practiceFeedback.Text=value; practiceFeedback.Parent=panel
 Instance.new("UICorner",practiceFeedback).CornerRadius=UDim.new(0,10)
 local pad=Instance.new("UIPadding",practiceFeedback); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12)
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
 local sc=list(); sc.ScrollBarThickness=6
 sc:FindFirstChildOfClass("UIListLayout").Padding=UDim.new(0,20)
 return sc
end
local function evaluationAction(label,callback,enabled)
 local b=button(evaluationFooter,label,callback,enabled)
 b.AutomaticSize=Enum.AutomaticSize.None; b.Size=UDim2.new(.46,-6,1,0); b.TextSize=24
 local cap=Instance.new("UISizeConstraint",b); cap.MaxSize=Vector2.new(280,80)
 table.insert(evaluationButtons,b)
 b.AnchorPoint=Vector2.new(1,0); b.Position=UDim2.fromScale(1,0)
 if #evaluationButtons==2 then
  local secondary=evaluationButtons[1]
  secondary.AnchorPoint=Vector2.new(0,0); secondary.Position=UDim2.fromScale(0,0)
  secondary.BackgroundColor3=Color3.fromRGB(125,102,90)
 end
 if enabled==false then b.BackgroundColor3=Color3.fromRGB(150,140,135) end
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
evidence=function(feedback)
 clear("Latihan 1 — Fungsi gagasan")
 local labels={"Masalah","Pendekatan","Evaluasi"}
 local home=box(UDim2.fromScale(0,.12),UDim2.fromScale(1,.37),""); home.BackgroundTransparency=1
 box(UDim2.fromScale(0,0),UDim2.fromScale(1,.10),"Seret setiap kartu ke fungsi yang sesuai.")
 local targets={}
 for i=1,3 do
  local heading=box(UDim2.fromScale((i-1)*.34,.52),UDim2.fromScale(.32,.09),labels[i]); heading.BackgroundTransparency=1; heading.Font=Enum.Font.GothamBold; heading.TextSize=22
  targets[i]=box(UDim2.fromScale((i-1)*.34,.63),UDim2.fromScale(.32,.36),"Lepaskan kartu di sini")
  targets[i].TextSize=17; targets[i].TextColor3=Color3.fromRGB(135,109,90)
  for j=1,3 do if state.slots[j]==i then targets[i].Text="" end end
  local border=Instance.new("UIStroke",targets[i]); border.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; border.Color=Color3.fromRGB(196,159,127); border.Thickness=2
 end
 for i=1,3 do
  local card=Instance.new("TextButton"); card.Text=DATA.cards[i]; card.TextWrapped=true; card.Font=Enum.Font.Gotham
  card.TextScaled=true; local tc=Instance.new("UITextSizeConstraint",card); tc.MinTextSize=16; tc.MaxTextSize=22; card.TextSize=20; card.TextColor3=brown; card.BackgroundColor3=Color3.fromRGB(220,234,243)
  card.Size=UDim2.fromScale(.30,.34); card.Position=UDim2.fromScale(((state.slots[i] or i)-1)*.34+.01,state.slots[i] and .64 or .14)
  card.TextXAlignment=Enum.TextXAlignment.Left
  local pad=Instance.new("UIPadding",card); pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,14); pad.PaddingTop=UDim.new(0,10); pad.PaddingBottom=UDim.new(0,10)
  local outline=Instance.new("UIStroke",card); outline.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; outline.Color=Color3.fromRGB(109,147,175); outline.Thickness=2
  card.Parent=body; Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
  card.InputBegan:Connect(function(input)
   if state.done1 or drag then return end
   if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
   drag={index=i,card=card,input=input,offset=Vector2.new(input.Position.X,input.Position.Y)-card.AbsolutePosition}; card.ZIndex=10
  end)
 end
 dragBoard={targets=targets,home=home}
 navigation("Baca abstrak",function() news(function() evidence() end) end,state.done1 and "Ke Latihan 2" or "Periksa",function()
  if state.done1 then dismiss(); return end
  local correct=functionsCorrect(state.slots)
  recordLearning("practice",{activity="functions",choices={state.slots[1],state.slots[2],state.slots[3]},help=state.errors1>=2})
  if correct then state.done1=true; evidence() else
   state.errors1+=1
   evidence(state.errors1>=2 and "Bantuan: kendala melatarbelakangi masalah; data-centric ialah usulan; studi kasus ialah cara evaluasi. Susun kembali dan Periksa." or "Tinjau fungsi setiap gagasan pada bagian 1, 2, dan 3 abstrak.")
  end
 end,state.done1 or (state.slots[1]~=nil and state.slots[2]~=nil and state.slots[3]~=nil))
 practiceStatus(state.done1 and "SELESAI — Ketiga fungsi gagasan sesuai." or feedback or "Untuk mengganti pasangan, kembalikan kartu ke area atas.",state.done1,feedback~=nil)
 -- Reserve most of the panel for the actual drag board; keep the resting hint compact.
 panel.Size=UDim2.fromScale(.94,.94)
 local feedbackHeight=feedback and 80 or 42
 body.Size=UDim2.new(1,-40,1,-(194+feedbackHeight))
 practiceFeedback.Position=UDim2.new(0,20,1,-(88+feedbackHeight))
 practiceFeedback.Size=UDim2.new(1,-40,0,feedbackHeight); practiceFeedback.TextSize=18
 if not feedback and not state.done1 then practiceFeedback.BackgroundTransparency=1 end
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
 clear("Latihan 2 — Ronde "..state.round.."/4: "..r.title); local sc=list()
 text(sc,r.instruction,25)
 text(sc,"SUMBER — pilih satu kalimat bukti",22).Font=Enum.Font.GothamBold
 for i,quote in ipairs(r.evidence) do
  button(sc,(v.evidence==i and "✓ " or "")..quote,function()
   if not v.done then v.evidence=v.evidence~=i and i or nil; pairView() end
  end).BackgroundColor3=v.evidence==i and Color3.fromRGB(65,110,145) or Color3.fromRGB(125,102,90)
 end
 text(sc,"DRAF — pilih satu rentang yang harus dicoret",22).Font=Enum.Font.GothamBold
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
  recordLearning("practice",{activity="editor",round=state.round,choices={v.part,v.evidence},help=v.errors>=2})
  if revision and proof then
   v.done=true; state.done2=true
   for i=1,4 do if not state.rounds[i] or not state.rounds[i].done then state.done2=false end end
   pairView()
  else
   v.errors+=1
   local f=(revision and "Revisi tepat. " or "Tinjau cakupan draf. "..r.hint.." ")..(proof and "Bukti tepat." or r.wrongEvidence)
   if v.errors>=2 then f..=" Bantuan frasa: “"..r.proof.."”. Pilih kembali dan Periksa." end
   pairView(f)
  end
 end,v.done or (v.part~=nil and v.evidence~=nil))
 practiceStatus(v.done and "SELESAI — Revisi dan bukti sesuai." or feedback or "Pilih rentang draf dan bukti, lalu Periksa. Pilihan tersimpan saat panel ditutup.",v.done,feedback~=nil)
end

resultView=function()
 local sc=evaluationClear("Hasil Evaluasi Level 3",result.unlocked and "Gedung tengah terbuka. Tutup hasil dan ikuti panah." or "Nilai minimal 75. Pelajari kembali abstrak, lalu kembali ke kios untuk mencoba lagi.")
 text(sc,"Skor jawaban: "..result.score.." / 100",34).Font=Enum.Font.GothamBold
 text(sc,"Ketepatan alasan: "..result.reasons.." / 4 (terpisah dari skor kemajuan)")
 text(sc,"Nilai terbaik sesi: "..result.best.." / 100")
 text(sc,result.unlocked and "Akses gedung tengah sudah terbuka." or "Nilai minimal 75. Baca kembali materi dan coba lagi.")
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
  clear("Level 3 — Keterampilan Membaca"); local sc=list(); text(sc,DATA.intro)
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
  notice.Visible=false; noticeVersion+=1
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
