// Geometry/lifecycle regression fixture. Roblox rendering and real font metrics still need Play QA.
const fs=require('fs'),cp=require('child_process');
const library=fs.readFileSync('studio-sync/ui/ResponsiveLearning.luau','utf8');
const client=fs.readFileSync('studio-sync/templates/Level3FlowHandler.client.luau','utf8');
const shell=client.slice(client.indexOf('local evaluationFooter'),client.indexOf('local function prompts'));
const mock=String.raw`
local function signal()
 local callbacks={}
 return {Connect=function(_,f) table.insert(callbacks,f); return {Disconnect=function() end} end,Fire=function() for _,f in ipairs(callbacks) do f() end end}
end
Enum=setmetatable({},{__index=function(t,k) local v=setmetatable({},{__index=function(_,x)return x end});rawset(t,k,v);return v end})
Vector2={new=function(x,y)return {X=x,Y=y} end};Vector2.zero=Vector2.new(0,0)
UDim={new=function(s,o)return {Scale=s,Offset=o} end}
UDim2={new=function(x,xo,y,yo)return {X=UDim.new(x or 0,xo or 0),Y=UDim.new(y or 0,yo or 0)} end}
UDim2.fromScale=function(x,y)return UDim2.new(x,0,y,0) end
UDim2.fromOffset=function(x,y)return UDim2.new(0,x,0,y) end
Color3={new=function(...)return {...} end,fromRGB=function(...)return {...} end}
task={defer=function(f) f() end}
local objects={}
local function make(class,parent)
 local d={ClassName=class,Name=class,Parent=parent,Size=UDim2.new(),Position=UDim2.new(),Text="",TextSize=24,Destroying=signal(),Activated=signal(),Visible=true}
 local signals={}
 local o
 local methods={}
 function methods:GetChildren()local a={};for _,v in ipairs(objects)do if v.Parent==o then table.insert(a,v)end end;return a end
 function methods:IsA(c)return class==c or (c=="GuiObject" and class~="ScreenGui" and not class:match("^UI"))end
 function methods:FindFirstChild(n)for _,v in ipairs(self:GetChildren())do if v.Name==n then return v end end end
 function methods:FindFirstChildWhichIsA(n)for _,v in ipairs(self:GetChildren())do if v:IsA(n)then return v end end end
 methods.FindFirstChildOfClass=methods.FindFirstChildWhichIsA
 function methods:FindFirstAncestorWhichIsA(n)local p=self.Parent;while p do if p:IsA(n)then return p end;p=p.Parent end end
 function methods:GetPropertyChangedSignal(n)if not signals[n]then signals[n]=signal()end;return signals[n]end
 function methods:Destroy()d.Parent=nil;d.Destroying:Fire()end
 function methods:ClearAllChildren()for _,c in ipairs(self:GetChildren())do c:Destroy()end end
 o=setmetatable({},{__index=function(_,k)
  if methods[k]then return methods[k]end
  if k=="AbsoluteContentSize" and class=="UIListLayout" then
   local total,count=0,0
   if d.Parent then for _,c in ipairs(d.Parent:GetChildren())do if c:IsA("GuiObject") and c.Visible then total+=c.AbsoluteSize.Y;count+=1 end end end
   return Vector2.new(0,total+math.max(0,count-1)*(d.Padding and d.Padding.Offset or 0))
  end
  if k=="AbsoluteSize"then
   if class=="ScreenGui" then return workspace.CurrentCamera.ViewportSize end
   local p=d.Parent and d.Parent.AbsoluteSize or workspace.CurrentCamera.ViewportSize
   return Vector2.new(p.X*d.Size.X.Scale+d.Size.X.Offset,p.Y*d.Size.Y.Scale+d.Size.Y.Offset)
  end
  return d[k]
 end,__newindex=function(_,k,v)d[k]=v end})
 table.insert(objects,o);return o
end
Instance={new=make}
local camera={ViewportSize=Vector2.new(1920,1080),changed=signal()}
function camera:GetPropertyChangedSignal()return self.changed end
workspace={CurrentCamera=camera,changed=signal()}
function workspace:GetPropertyChangedSignal()return self.changed end
local inset=36
game={GetService=function(_,name)
 if name=="GuiService"then return {GetGuiInset=function()return Vector2.new(0,inset),Vector2.zero end}end
 if name=="TextService"then return {GetTextSize=function(_,value,size,font,bounds)
  local lines=0
  for line in (value.."\n"):gmatch("(.-)\n")do lines+=math.max(1,math.ceil(#line*size*.55/bounds.X))end
  return Vector2.new(bounds.X,lines*size*1.2)
 end}end
end}
local UI=(function()
`+library+String.raw`
end)()
local gui=make("ScreenGui")
local overlay=make("Frame",gui);overlay.Size=UDim2.fromScale(1,1)
local panel=make("Frame",overlay)
local title=make("TextLabel",panel)
local close=make("TextButton",panel)
local body=make("Frame",panel)
local cream,brown,brick={},{},{}
local drag,dragBoard
`+shell+String.raw`
for _,v in ipairs({{320,568},{360,640},{390,844},{768,1024},{640,360},{844,390},{1280,720},{1920,1080}})do
 for _,safeTop in ipairs({36,58})do
  inset=safeTop;camera.ViewportSize=Vector2.new(v[1],v[2]);camera.changed:Fire()
  clear("Latihan 2 — Ronde 1/4: Kendala dalam bacaan")
  local sc=list();text(sc,string.rep("Kalimat yang panjang harus tetap terbaca. ",20))
  navigation("Baca abstrak",function()end,"Ronde berikutnya",function()end,true)
  practiceStatus("BELUM TEPAT — Baca lagi kutipan, kemudian pilih satu bagian draf yang melampaui sumber.",false,true)
  assert(panel.AbsoluteSize.X<=v[1] and panel.AbsoluteSize.Y<=v[2])
  assert(body.AbsoluteSize.Y>0,"Negative reading area at "..v[1].."x"..v[2])
  assert(body.Position.Y.Offset+body.AbsoluteSize.Y<=panel.AbsoluteSize.Y-68)
  assert(practiceFeedback.Size.Y.Offset>=52 and practiceFeedback.LayoutOrder<0)
  for _,b in ipairs(navigationFooter:GetChildren())do if b:IsA("TextButton")then assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44)end end
  local nextList=evaluationClear("Evaluasi 1/4 — Alasan","Pilih satu alasan.")
  evaluationAction("Lanjut ke alasan",function()end,true)
  evaluationAction("Kirim jawaban",function()end,true)
  assert(body.AbsoluteSize.Y>0 and evaluationStatus.Parent==nextList)
 end
end
local legacy=make("Frame",gui)
local nextButton=make("ImageButton",legacy);nextButton.Name="next"
local nextLabel=make("TextLabel",nextButton);nextLabel.AnchorPoint=Vector2.new(.5,.5)
local closeButton=make("ImageButton",legacy);closeButton.Name="close"
UI.legacy(legacy,"Panduan",string.rep("Baca panduan. ",20),{{"next","Berikutnya"},{"close","Tutup"}})
assert(legacy:FindFirstChild("next")==nextButton and legacy:FindFirstChild("close")==closeButton,"Legacy callbacks must still find direct buttons")
assert(nextLabel.AnchorPoint.X==0 and nextLabel.AnchorPoint.Y==0 and nextLabel.Position.X.Offset==0 and nextLabel.TextXAlignment==Enum.TextXAlignment.Center,"Legacy button text must stay inside the target")
local guide=make("Frame",gui)
local guideBody=make("TextLabel",guide);guideBody.Name="TextLabel";guideBody.Position=UDim2.fromScale(.55,.2);guideBody.Size=UDim2.fromScale(.4,.6);guideBody.AnchorPoint=Vector2.zero
local legacyCap=make("UISizeConstraint",guideBody)
local guidePhoto=make("ImageLabel",guide);guidePhoto.Name="ImageLabel";guidePhoto.Position=UDim2.fromScale(.05,.2);guidePhoto.Size=UDim2.fromScale(.45,.5);guidePhoto.AnchorPoint=Vector2.zero
local photoPosition,photoSize=guidePhoto.Position,guidePhoto.Size
local guideNext=make("ImageButton",guide);guideNext.Name="next";guideNext.AnchorPoint=Vector2.zero
camera.ViewportSize=Vector2.new(1920,1080)
UI.guide(guide,"Level 1 — Menyimak","Petunjuk lokasi tetap disertai foto.")
assert(guidePhoto.Parent==guide and guidePhoto.Visible and guidePhoto.Position==photoPosition and guidePhoto.Size==photoSize,"Wide guide must retain the original location photograph layout")
guideBody:GetPropertyChangedSignal("AbsoluteSize"):Fire()
local guideScroll=guide:FindFirstChild("GuideReading")
local guideLayout=guideScroll:FindFirstChildOfClass("UIListLayout")
guideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
assert(legacyCap.Parent==nil and guideLayout.VerticalAlignment==Enum.VerticalAlignment.Center,"Short guide narrative must be centered without a legacy height cap")
guideBody.Text=string.rep("Narasi panjang harus dapat dibaca sampai kalimat terakhir. ",80)
guideBody:GetPropertyChangedSignal("Text"):Fire();guideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
assert(guideLayout.VerticalAlignment==Enum.VerticalAlignment.Top and guideBody.Size.Y.Offset>guideScroll.AbsoluteSize.Y,"Overflow must start at the top and remain reachable by scrolling")
camera.ViewportSize=Vector2.new(390,844);camera.changed:Fire()
assert(guidePhoto.Parent==guide:FindFirstChild("GuideReading") and guidePhoto.Visible,"Narrow guide must keep the photograph reachable in the scroll")
camera.ViewportSize=Vector2.new(1920,1080);camera.changed:Fire()
assert(guidePhoto.Parent==guide and guidePhoto.Position==photoPosition and guidePhoto.Size==photoSize and guide:FindFirstChild("next")==guideNext)
local show,hide=UI.notice(gui,"TestNotice")
show("Selesaikan Level 1 dengan nilai minimal 75.")
assert(gui:FindFirstChild("TestNotice").Visible)
hide();assert(not gui:FindFirstChild("TestNotice").Visible)
print("PASS responsive geometry: 8 viewport sizes x 2 safe insets, positive scroll area, footer targets, feedback placement, legacy action identity, notice dismissal")
`;
fs.writeFileSync('local-rbxl/test-responsive-ui.luau',mock);
process.stdout.write(cp.execFileSync('local-rbxl/luau/luau.exe',['local-rbxl/test-responsive-ui.luau'],{encoding:'utf8'}));
