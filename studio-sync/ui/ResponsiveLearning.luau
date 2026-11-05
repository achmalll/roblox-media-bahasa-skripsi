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
