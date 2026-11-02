-- Local editor plugin only. No game scripts are executed by this bridge.
local Http = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StudioTest = game:GetService("StudioTestService")
local Editor = game:GetService("ScriptEditorService")
local History = game:GetService("ChangeHistoryService")
local BASE = "http://127.0.0.1:34873"
local PROJECT = "roblox-media-bahasa-skripsi"
local stopped = false
local connected = false
local enabled = true
local token, session, config
local cache = {}
local order = {}
local lastWarning = -math.huge

local function testing()
	-- Edit DataModel remains stopped during Play Solo; IsRunning alone is insufficient.
	return RunService:IsRunning() or not StudioTest.EditModeActive
end

local function resolve(parts)
	assert(type(parts) == "table" and #parts > 0, "Invalid instance path")
	local candidates = { game }
	for _, name in ipairs(parts) do
		local nextCandidates = {}
		for _, current in ipairs(candidates) do
			for _, child in ipairs(current:GetChildren()) do
				if child.Name == name then table.insert(nextCandidates, child) end
			end
		end
		assert(#nextCandidates > 0, "Missing instance: " .. name)
		assert(#nextCandidates <= 256, "Path candidate limit exceeded")
		candidates = nextCandidates
	end
	assert(#candidates == 1, "Ambiguous complete path: " .. table.concat(parts, "/"))
	return candidates[1]
end

local function request(route, body, pairing)
	local headers = { ["Content-Type"] = "application/json", ["X-Codex-Bridge"] = "rbxl-v1" }
	if token then headers["X-Bridge-Token"] = token end
	if session then headers["X-Studio-Session"] = session end
	local success, response = pcall(function()
		return Http:RequestAsync({ Url = BASE .. route, Method = "POST", Headers = headers, Body = Http:JSONEncode(body) })
	end)
	if not success then
		token = nil; session = nil; config = nil; connected = false
		error(response)
	end
	if response.StatusCode == 403 then token = nil; session = nil; config = nil; connected = false end
	assert(response.Success, "Bridge HTTP " .. tostring(response.StatusCode) .. ": " .. response.Body)
	return Http:JSONDecode(response.Body)
end

local function sourceOf(inst)
	return Editor:GetEditorSource(inst)
end

local function snapshot()
	local result = { scripts = {}, properties = {}, running = testing(), gameName = game.Name, placeId = game.PlaceId }
	for _, item in ipairs(config.scripts) do
		local inst = resolve(item.instancePath)
		assert(inst.ClassName == item.className, "Script class changed")
		table.insert(result.scripts, { instancePath = item.instancePath, className = inst.ClassName, source = sourceOf(inst) })
	end
	for _, item in ipairs(config.properties) do
		local inst = resolve(item.instancePath)
		assert(inst.ClassName == item.className, "Property target class changed")
		table.insert(result.properties, { instancePath = item.instancePath, className = inst.ClassName, property = item.property, value = inst[item.property] })
	end
	return result
end

local function allowed(list, command, withProperty)
	for _, item in ipairs(list) do
		local same = #item.instancePath == #command.instancePath
		for i, part in ipairs(item.instancePath) do
			if command.instancePath[i] ~= part then same = false end
		end
		if same and item.className == command.className and (not withProperty or item.property == command.property) then return true end
	end
	return false
end

local function aulaBounds(hall)
 local low=Vector3.new(math.huge,math.huge,math.huge)
 local high=Vector3.new(-math.huge,-math.huge,-math.huge)
 local count=0
 for _,p in ipairs(hall:GetDescendants()) do if p:IsA("BasePart") then
  count+=1
  for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
   local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2)
   low=Vector3.new(math.min(low.X,v.X),math.min(low.Y,v.Y),math.min(low.Z,v.Z))
   high=Vector3.new(math.max(high.X,v.X),math.max(high.Y,v.Y),math.max(high.Z,v.Z))
  end end end
 end end
 assert(count>0,"Aula has no geometry")
 return CFrame.new((low+high)/2),high-low
end

local function execute(command)
	assert(not testing(), "Play active: edits paused")
	if command.op == "archive_aula_photo_seating" then
		assert(config.aulaPhotoSpot==true,"Photo seating outside scope")
		local hall=resolve({"Workspace","Gedung Tengah"})
		local photo=resolve({"Workspace","Gedung Tengah","AulaPhotoSpot"})
		local storage=game:GetService("ServerStorage")
		local saved=storage:FindFirstChild("AulaPhotoSeatingBackup")
		if saved then
			assert(saved:IsA("Model") and saved:GetAttribute("PhotoSeatingBackupV1")==true,"Unmanaged backup exists")
			return {status="already_applied",backup="ServerStorage/AulaPhotoSeatingBackup"}
		end
		local candidates={}
		for _,root in ipairs(hall:GetChildren()) do if root:IsA("Model") and root~=photo then
			local seats=0; local unsafe=false
			for _,o in ipairs(root:GetDescendants()) do
				if o:IsA("Seat") or o:IsA("VehicleSeat") then seats+=1 end
				if o:IsA("LuaSourceContainer") or o:IsA("Humanoid") then unsafe=true end
			end
			if seats>=10 and seats<=60 and not unsafe then
				local cf,size=root:GetBoundingBox(); local offset=cf.Position-photo:GetPivot().Position
				table.insert(candidates,{root=root,name=root.Name,seats=seats,center={cf.X,cf.Y,cf.Z},size={size.X,size.Y,size.Z},distance=Vector3.new(offset.X,0,offset.Z).Magnitude})
			end
		end end
		table.sort(candidates,function(a,b) return a.distance<b.distance end)
		local report={}
		for _,c in ipairs(candidates) do table.insert(report,{name=c.name,seats=c.seats,center=c.center,size=c.size,distance=c.distance}) end
		if command.apply~=true then return {status="read",candidates=report} end
		local chosen=candidates[1]; assert(chosen and chosen.distance<50,"No nearby seating cluster")
		assert(not candidates[2] or candidates[2].distance-chosen.distance>2,"Ambiguous seating cluster")
		assert(type(command.beforeCenter)=="table" and #command.beforeCenter==3,"Preflight center required")
		assert((Vector3.new(table.unpack(command.beforeCenter))-Vector3.new(table.unpack(chosen.center))).Magnitude<.05 and command.beforeSeats==chosen.seats,"Seating changed after inspection")
		History:SetWaypoint("Before archiving aula photo seating")
		chosen.root:SetAttribute("PhotoSeatingOriginalName",chosen.name)
		chosen.root:SetAttribute("PhotoSeatingBackupV1",true)
		chosen.root.Name="AulaPhotoSeatingBackup"; chosen.root.Parent=storage
		History:SetWaypoint("Aula photo seating archived")
		return {status="applied",backup="ServerStorage/AulaPhotoSeatingBackup",seats=chosen.seats,center=chosen.center,remainingCandidates=#candidates-1}
	end
	if command.op == "polish_aula_photo" then
		assert(config.aulaPhotoSpot==true,"Photo polish outside scope")
		local model=resolve({"Workspace","Gedung Tengah","AulaPhotoSpot"})
		assert(model:GetAttribute("PhotoSpotV1")==true,"Unmanaged photo spot")
		local face=resolve({"Workspace","Gedung Tengah","AulaPhotoSpot","PhotoBackdrop","PhotoMessage"})
		local labels={}
		for _,o in ipairs(face:GetChildren()) do if o:IsA("TextLabel") then table.insert(labels,o) end end
		assert(#labels==4,"Photo labels changed")
		table.sort(labels,function(a,b) return a.Position.Y.Scale<b.Position.Y.Scale end)
		assert(labels[1].Text=="PERJALANAN BELAJARKU" and labels[2].Text=="Bahasa Indonesia • Roblox","Photo wording changed")
		if model:GetAttribute("PhotoTypographyV2")==true then return {status="already_applied",visibleLabels=2} end
		History:SetWaypoint("Before photo typography polish")
		labels[1].Position=UDim2.fromScale(.055,.065); labels[1].Size=UDim2.fromScale(.89,.20); labels[1].TextSize=72
		labels[2].Position=UDim2.fromScale(.07,.275); labels[2].Size=UDim2.fromScale(.86,.09); labels[2].TextSize=32
		labels[3].Visible=false; labels[4].Visible=false
		model:SetAttribute("PhotoTypographyV2",true)
		History:SetWaypoint("Photo typography polished")
		return {status="applied",visibleLabels=2,titleSize=72,avatarAreaClear=true}
	end
	if command.op == "inspect_aula_photo" then
		local hall=resolve({"Workspace","Gedung Tengah"})
		local cf,size=aulaBounds(hall)
		local parts={}
		for _,p in ipairs(hall:GetDescendants()) do if p:IsA("BasePart") then
			table.insert(parts,{name=p.Name,parent=p.Parent.Name,frame={p.CFrame:GetComponents()},size={p.Size.X,p.Size.Y,p.Size.Z},collide=p.CanCollide})
		end end
		local entry=resolve({"Workspace","ApresiasiDoorBlock"})
		local summary=resolve({"Workspace","SummaryProximity"})
		return {status="read",bounds={frame={cf:GetComponents()},size={size.X,size.Y,size.Z}},entry={entry.Position.X,entry.Position.Y,entry.Position.Z},summary={summary.Position.X,summary.Position.Y,summary.Position.Z},parts=parts}
	end
	if command.op == "stage_aula_photo" then
		assert(config.aulaPhotoSpot==true,"Aula photo outside scope")
		local hall=resolve({"Workspace","Gedung Tengah"})
		local existing=hall:FindFirstChild("AulaPhotoSpot")
		if existing then
			assert(existing:IsA("Model") and existing:GetAttribute("PhotoSpotV1")==true,"Unmanaged photo spot exists")
			return {status="already_applied",parts=#existing:GetChildren(),frame={existing:GetPivot():GetComponents()}}
		end
		assert(type(command.frame)=="table" and #command.frame==12,"Invalid photo frame")
		for _,n in ipairs(command.frame) do assert(type(n)=="number" and n==n and math.abs(n)<100000,"Invalid coordinate") end
		local frame=CFrame.new(table.unpack(command.frame))
		assert(math.abs(frame.UpVector.Y-1)<.001,"Photo frame must be upright")
		local bounds,size=aulaBounds(hall); local rel=bounds:PointToObjectSpace(frame.Position)
		assert(math.abs(rel.X)<size.X/2 and math.abs(rel.Z)<size.Z/2,"Photo spot outside aula")
		local entry=resolve({"Workspace","ApresiasiDoorBlock"})
		local summary=resolve({"Workspace","SummaryProximity"})
		assert((frame.Position-entry.Position).Magnitude>12 and (frame.Position-summary.Position).Magnitude>12,"Photo spot blocks main activity")
		local filter=OverlapParams.new(); filter.FilterType=Enum.RaycastFilterType.Include; filter.FilterDescendantsInstances={hall}
		local touching=workspace:GetPartBoundsInBox(frame*CFrame.new(0,4,0),Vector3.new(16,7.5,9),filter)
		assert(#touching==0,"Photo area occupied; inspect another position")
		History:SetWaypoint("Before aula photo spot")
		local model=Instance.new("Model"); model.Name="AulaPhotoSpot"
		local function part(name,size,offset,color)
			local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=frame*offset
			p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.Material=Enum.Material.SmoothPlastic; p.Color=color; p.Parent=model; return p
		end
		local cream=Color3.fromRGB(244,221,205); local brick=Color3.fromRGB(153,59,42); local gold=Color3.fromRGB(209,156,80)
		part("PhotoFloor",Vector3.new(16,.12,9),CFrame.new(0,.06,0),cream)
		local back=part("PhotoBackdrop",Vector3.new(16,9,.35),CFrame.new(0,4.5,4.3),brick)
		part("LeftTrim",Vector3.new(.25,9,.5),CFrame.new(-7.7,4.5,4.1),gold)
		part("RightTrim",Vector3.new(.25,9,.5),CFrame.new(7.7,4.5,4.1),gold)
		part("TopTrim",Vector3.new(15.6,.25,.5),CFrame.new(0,8.7,4.1),gold)
		local face=Instance.new("SurfaceGui"); face.Name="PhotoMessage"; face.Face=Enum.NormalId.Front; face.CanvasSize=Vector2.new(1200,675); face.Parent=back
		local function label(value,y,height,textSize)
			local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Position=UDim2.fromScale(.07,y); t.Size=UDim2.fromScale(.86,height)
			t.Font=Enum.Font.GothamBold; t.TextSize=textSize; t.TextColor3=cream; t.TextWrapped=true; t.Text=value; t.Parent=face
		end
		label("PERJALANAN BELAJARKU",.08,.19,64)
		label("Bahasa Indonesia • Roblox",.29,.10,32)
		label("Tiga level, satu pencapaian.",.43,.10,36)
		label("Pakai medalimu • Abadikan momenmu",.78,.10,30)
		for i=-1,1 do
			part("StandMarker"..i,Vector3.new(2,.04,2),CFrame.new(i*3,.14,0),gold)
		end
		model:SetAttribute("PhotoSpotV1",true); model.WorldPivot=frame; model.Parent=hall
		History:SetWaypoint("Aula photo spot created")
		return {status="applied",path="Workspace/Gedung Tengah/AulaPhotoSpot",parts=8,frame={frame:GetComponents()},medalChanged=false}
	end
	if command.op == "fix_male_guide_pants" then
		assert(config.level2StationGuides and config.level3FurnitureLayout,"Guide clothing outside scope")
		local source=resolve({"Workspace","Space 2","Budi",""}):FindFirstChildOfClass("Pants")
		assert(source and source.PantsTemplate~="","Original male guide pants missing")
		local targets={}
		for _,path in ipairs({
			{"Workspace","Level2Development","L2_NPC_SimpulanBukti"},
			{"Workspace","Level3Development","L3_NPC_BatasSimpulan"},
			{"Workspace","Level3Development","L3_NPC_EvaluasiPria"},
		}) do
			local model=resolve(path)
			local pants=model:FindFirstChildOfClass("Pants")
			assert(pants,"Male guide pants missing: "..model.Name)
			table.insert(targets,{pants=pants,name=model.Name,before=pants.PantsTemplate})
		end
		History:SetWaypoint("Before Codex male guide pants fix")
		local changes={}
		for _,target in ipairs(targets) do
			target.pants.PantsTemplate=source.PantsTemplate
			assert(target.pants.PantsTemplate==source.PantsTemplate,"Pants readback failed")
			table.insert(changes,{name=target.name,before=target.before,after=target.pants.PantsTemplate})
		end
		History:SetWaypoint("Codex male guide pants fix")
		return {status="applied",changes=changes,source="Workspace/Space 2/Budi/Pants"}
	end
	if command.op == "stage_level2_guides" then
		assert(config.level2StationGuides == true,"Level 2 guides outside scope")
		local root=resolve({"Workspace","Level2Development"})
		local first=resolve({"Workspace","Level2Development","L2_MejaBukti"})
		local second=resolve({"Workspace","Level2Development","L2_PapanPasangan"})
		local female=resolve({"Workspace","Level3Development","L3_NPC_FungsiGagasan"})
		local male=resolve({"Workspace","Level3Development","L3_NPC_BatasSimpulan"})
		assert(first:IsA("Model") and second:IsA("Model"),"Station model changed")
		assert(female:IsA("Model") and male:IsA("Model"),"Guide template changed")
		local names={"L2_NPC_BuktiTeks","L2_NPC_SimpulanBukti"}
		if root:GetAttribute("StationGuidesV1") then
			for _,name in ipairs(names) do assert(root:FindFirstChild(name),"Guide missing; inspect before retry") end
			return {status="already_applied",guides=2}
		end
		local floorCf,floorSize=first:GetBoundingBox()
		local function halfHeight(cf,size)
			return (math.abs(cf.RightVector.Y)*size.X+math.abs(cf.UpVector.Y)*size.Y+math.abs(cf.LookVector.Y)*size.Z)/2
		end
		local floorY=floorCf.Position.Y-halfHeight(floorCf,floorSize)
		local pending={}
		for i,entry in ipairs({{template=female,station=first,side=-1},{template=male,station=second,side=1}}) do
			assert(not root:FindFirstChild(names[i]),"Guide already exists; inspect before retry")
			local rig=entry.template:Clone(); assert(rig,"Guide cannot be cloned")
			local hum=rig:FindFirstChildOfClass("Humanoid"); assert(hum,"Guide Humanoid missing")
			for _,item in ipairs(rig:GetDescendants()) do
				if item:IsA("LuaSourceContainer") or item:IsA("ProximityPrompt") then item:Destroy()
				elseif item:IsA("BasePart") then item.Anchored=true; item.CanCollide=false; item.CanTouch=false end
			end
			hum.Sit=false; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
			local cf,size=entry.station:GetBoundingBox()
			local right=Vector3.new(cf.RightVector.X,0,cf.RightVector.Z)
			if right.Magnitude<.1 then right=Vector3.new(1,0,0) else right=right.Unit end
			local forward=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
			if forward.Magnitude<.1 then forward=Vector3.new(0,0,-1) else forward=forward.Unit end
			local position=cf.Position+right*(entry.side*(size.X/2+2.5))+forward*1.5
			local bodyCf,bodySize=rig:GetBoundingBox()
			local bottom=bodyCf.Position.Y-halfHeight(bodyCf,bodySize)
			local pivot=rig:GetPivot()
			rig:PivotTo(CFrame.new(position.X,floorY+pivot.Position.Y-bottom,position.Z)*CFrame.lookAt(Vector3.zero,forward).Rotation)
			rig.Name=names[i]; rig:SetAttribute("Level2StationGuide",true)
			table.insert(pending,rig)
		end
		History:SetWaypoint("Before Codex Level 2 station guides")
		for _,rig in ipairs(pending) do rig.Parent=root end
		root:SetAttribute("StationGuidesV1",true)
		History:SetWaypoint("Codex Level 2 station guides")
		return {status="applied",guides=2,names=names,scope="Appearance only; existing practice prompts unchanged"}
	end
	if command.op == "stage_level3_furniture" then
		assert(config.level3FurnitureLayout == true, "Level 3 furniture outside scope")
		local root=resolve({"Workspace","Level3Development"})
		if root:GetAttribute("FurnitureLayoutV1") then return {status="already_applied"} end
		local oldBoard=resolve({"Workspace","Level3Development","latihan 1"})
		local secondBoard=resolve({"Workspace","Level3Development","latihan 2"})
		local reading=resolve({"Workspace","Level3Development","meja baca"})
		local evaluation=resolve({"Workspace","Level3Development","Evaluasi"})
		assert(oldBoard:IsA("MeshPart") and secondBoard:IsA("Model"), "Level 3 board layout changed")
		local female=resolve({"Workspace","Space 3",""})
		local male=resolve({"Workspace","Space 2","Budi",""})
		assert(female:IsA("Model") and female:FindFirstChildOfClass("Humanoid"), "Female guide rig missing")
		assert(male:IsA("Model") and male:FindFirstChildOfClass("Humanoid"), "Male guide rig missing")
		local backup=game:GetService("ServerStorage")
		assert(not backup:FindFirstChild("L3OriginalBoard1"), "Original board backup already exists")
		local function bounds(object)
			local parts={}
			if object:IsA("BasePart") then table.insert(parts,object) end
			for _,item in ipairs(object:GetDescendants()) do if item:IsA("BasePart") then table.insert(parts,item) end end
			assert(#parts>0,"Furniture has no parts")
			local low=Vector3.new(math.huge,math.huge,math.huge)
			local high=Vector3.new(-math.huge,-math.huge,-math.huge)
			for _,part in ipairs(parts) do
				for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
					local point=part.CFrame:PointToWorldSpace(part.Size*Vector3.new(x,y,z)/2)
					low=Vector3.new(math.min(low.X,point.X),math.min(low.Y,point.Y),math.min(low.Z,point.Z))
					high=Vector3.new(math.max(high.X,point.X),math.max(high.Y,point.Y),math.max(high.Z,point.Z))
				end end end
			end
			return (low+high)/2,high-low,low.Y
		end
		local function captions(board,title,first,second,third)
			for name,value in pairs({Title=title,["Animation 1"]=first,["Animation 2"]=second,["Animation 3"]=third}) do
				local row=board:FindFirstChild(name)
				local label=row and row:FindFirstChildWhichIsA("TextLabel",true)
				assert(label,"Board caption missing: "..name); label.Text=value
			end
		end
		local first=secondBoard:Clone()
		assert(first,"Board cannot be cloned")
		captions(first,"Latihan 1","Fungsi gagasan","Susun tiga gagasan","Tahan E untuk berlatih")
		for _,item in ipairs(first:GetDescendants()) do
			if item:IsA("LuaSourceContainer") or item:IsA("ProximityPrompt") then item:Destroy()
			elseif item:IsA("BasePart") then item.Anchored=true end
		end
		local oldCenter,_,floor=bounds(oldBoard)
		local center,_,copyFloor=bounds(first)
		first:PivotTo(CFrame.new(oldCenter.X-center.X,floor-copyFloor,oldCenter.Z-center.Z)*first:GetPivot())
		first.Name="latihan 1"
		local pending={}
		local function guide(name,template,object,side,front)
			assert(not root:FindFirstChild(name),"Guide already exists: "..name)
			local rig=template:Clone(); assert(rig,"NPC cannot be cloned")
			local hum=rig:FindFirstChildOfClass("Humanoid")
			for _,item in ipairs(rig:GetDescendants()) do
				if item:IsA("LuaSourceContainer") or item:IsA("ProximityPrompt") then item:Destroy()
				elseif item:IsA("BasePart") then item.Anchored=true; item.CanCollide=false; item.CanTouch=false
				elseif item:IsA("Shirt") then item.ShirtTemplate="http://www.roblox.com/asset/?id=10285081830"
				elseif item:IsA("Pants") then item.PantsTemplate=template==male and "http://www.roblox.com/asset/?id=11766474738" or "http://www.roblox.com/asset/?id=10297918623"
				elseif item:IsA("Motor6D") then item.Transform=CFrame.identity end
			end
			hum.Sit=false; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
			local c,size,bottom=bounds(object)
			local position=c+Vector3.new(side*(size.X/2+2.5),0,front*(size.Z/2+2.5))
			local rigCenter,_,rigBottom=bounds(rig)
			local facing=Vector3.new(c.X,position.Y,c.Z)-position
			if facing.Magnitude<.1 then facing=Vector3.new(0,0,-1) end
			local pivot=rig:GetPivot()
			local rotation=CFrame.lookAt(Vector3.zero,facing.Unit).Rotation
			rig:PivotTo(CFrame.new(position.X,bottom+(pivot.Position.Y-rigBottom),position.Z)*rotation)
			rig.Name=name; rig:SetAttribute("Level3StationGuide",true)
			table.insert(pending,rig)
		end
		guide("L3_NPC_PemanduBaca",female,reading,0,-1)
		guide("L3_NPC_FungsiGagasan",female,first,-1,0)
		guide("L3_NPC_BatasSimpulan",male,secondBoard,1,0)
		guide("L3_NPC_EvaluasiPria",male,evaluation,-1,0)
		guide("L3_NPC_EvaluasiWanita",female,evaluation,1,0)
		-- Validate the existing second board's labels before any live mutation.
		for _,name in ipairs({"Title","Animation 1","Animation 2","Animation 3"}) do
			local row=secondBoard:FindFirstChild(name)
			assert(row and row:FindFirstChildWhichIsA("TextLabel",true),"Second board caption missing")
		end
		History:SetWaypoint("Before Codex Level 3 furniture")
		oldBoard.Name="L3OriginalBoard1"; oldBoard.Parent=backup
		first.Parent=root
		captions(secondBoard,"Latihan 2","Batas simpulan","Empat ronde bukti","Tahan E untuk berlatih")
		for _,rig in ipairs(pending) do rig.Parent=root end
		root:SetAttribute("FurnitureLayoutV1",true)
		History:SetWaypoint("Codex Level 3 furniture")
		return {status="applied",guides=5,board="Workspace/Level3Development/latihan 1",backup="ServerStorage/L3OriginalBoard1",scope="Furniture only; learning interactions not implemented"}
	end
	if command.op == "replace_news_board" then
		assert(config.newsBoardReplacement == true, "News board replacement outside scope")
		local room=resolve({"Workspace","Space 2"})
		local original=resolve({"Workspace","Space 2","L2_PapanBerita"})
		if original:IsA("Model") and original:GetAttribute("ClonedFromTermsBoard") then
			return {status="already_applied",name=original.Name}
		end
		assert(original:IsA("MeshPart"), "Expected original news MeshPart")
		local template=resolve({"Workspace","Space 2","Infoboard"})
		assert(template:IsA("Model") and template.Archivable, "Terms board cannot be cloned")
		local backupService=game:GetService("ServerStorage")
		assert(not backupService:FindFirstChild("L2NewsBoardOriginal"), "News board backup already exists; inspect before replacing")
		local copy=template:Clone()
		assert(copy and copy:FindFirstChild("Surface"), "Terms board surface missing")
		local captions={Title="Berita Cloud AI Pad",["Animation 1"]="Baca berita",["Animation 2"]="Tahan E untuk membaca",["Animation 3"]="Tiga bagian bacaan"}
		for name,value in pairs(captions) do
			local row=copy:FindFirstChild(name)
			local label=row and row:FindFirstChildWhichIsA("TextLabel",true)
			assert(label, "Terms board caption missing: "..name)
			label.Text=value
		end
		for _,item in ipairs(copy:GetDescendants()) do
			if item:IsA("LuaSourceContainer") or item:IsA("ProximityPrompt") then item:Destroy()
			elseif item:IsA("BasePart") then item.Anchored=true end
		end
		local cf,size=copy:GetBoundingBox()
		local function halfHeight(frame,extent)
			return (math.abs(frame.RightVector.Y)*extent.X+math.abs(frame.UpVector.Y)*extent.Y+math.abs(frame.LookVector.Y)*extent.Z)/2
		end
		local bottom=original.Position.Y-halfHeight(original.CFrame,original.Size)
		local target=Vector3.new(original.Position.X,bottom+halfHeight(cf,size),original.Position.Z)
		copy:PivotTo(CFrame.new(target-cf.Position)*copy:GetPivot())
		copy.Name="L2_PapanBerita"; copy:SetAttribute("ClonedFromTermsBoard",true)
		History:SetWaypoint("Before Codex news board replacement")
		original.Name="L2NewsBoardOriginal"; original.Parent=backupService
		copy.Parent=room
		History:SetWaypoint("Codex news board replacement")
		return {status="applied",name=copy.Name,backup="ServerStorage/L2NewsBoardOriginal",position={target.X,target.Y,target.Z},source="Workspace/Space 2/Infoboard"}
	end
	if command.op == "inspect_workspace" then
		local items = {}
		local function pathOf(inst)
			local parts = {}
			while inst and inst ~= game do table.insert(parts, 1, inst.Name); inst = inst.Parent end
			return parts
		end
		for _, inst in ipairs(workspace:GetDescendants()) do
			if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("ProximityPrompt") or inst:IsA("Folder") or inst:IsA("Model") then
				assert(#items < 5000, "Workspace inventory exceeds limit")
				local item = { instancePath = pathOf(inst), className = inst.ClassName }
				if inst:IsA("TextLabel") or inst:IsA("TextButton") then item.text = inst.Text end
				table.insert(items, item)
			end
		end
		local summaries = {}
		local roots = {}
		local folder = workspace:FindFirstChild("Level2Development")
		if folder then for _, child in ipairs(folder:GetChildren()) do roots[child] = true end end
		for _, target in ipairs(config.objectMoves or {}) do
			local ok, root = pcall(resolve, target.instancePath)
			if ok then roots[root] = true end
		end
		for root in pairs(roots) do
			local summary = { instancePath = pathOf(root), parts = 0, unanchored = 0, scripts = {}, prompts = {} }
			for _, child in ipairs(root:GetDescendants()) do
				if child:IsA("BasePart") then
					summary.parts += 1
					if not child.Anchored then summary.unanchored += 1 end
				elseif child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
					table.insert(summary.scripts, { instancePath = pathOf(child), className = child.ClassName })
				elseif child:IsA("ProximityPrompt") then
					table.insert(summary.prompts, { instancePath = pathOf(child), enabled = child.Enabled, actionText = child.ActionText, objectText = child.ObjectText })
				end
			end
			if root:IsA("Model") then summary.pivot = { root:GetPivot():GetComponents() } end
			table.insert(summaries, summary)
		end
		return { status = "read", items = items, objectSummaries = summaries }
	elseif command.op == "create_folder" then
		assert(command.name == "Level2Development", "Folder name outside scope")
		local existing = workspace:FindFirstChild(command.name)
		if existing then assert(existing:IsA("Folder"), "Existing target is not a Folder"); return { status = "already_applied" } end
		History:SetWaypoint("Before Codex " .. command.id)
		local folder = Instance.new("Folder"); folder.Name = command.name; folder.Parent = workspace
		History:SetWaypoint("Codex " .. command.id)
		return { status = "applied", name = folder.Name }
	end
	local inst = resolve(command.instancePath)
	assert(inst.ClassName == command.className, "Target class changed")
	if command.op == "move_instance" then
		assert(allowed(config.objectMoves or {}, command, false), "Move outside project scope")
		if command.newName then
			local permitted = false
			for _, item in ipairs(config.objectMoves or {}) do
				if allowed({ item }, command, false) and item.newName == command.newName then permitted = true end
			end
			assert(permitted, "Rename outside project scope")
		end
		assert(inst:IsDescendantOf(workspace), "Move only Workspace objects")
		local destination = resolve({ "Workspace", "Level2Development" })
		assert(destination:IsA("Folder") and inst ~= destination, "Invalid destination")
		local finalName = command.newName or inst.Name
		local existing = destination:FindFirstChild(finalName)
		assert(not existing or existing == inst, "Destination name already exists")
		if inst.Parent == destination and inst.Name == finalName then return { status = "already_applied" } end
		History:SetWaypoint("Before Codex " .. command.id)
		inst.Name = finalName
		inst.Parent = destination
		History:SetWaypoint("Codex " .. command.id)
		return { status = "applied", parentPath = { "Workspace", "Level2Development" }, name = inst.Name }
	elseif command.op == "set_property" then
		assert(allowed(config.properties, command, true), "Property outside project scope")
		local duration = inst:IsA("ProximityPrompt") and command.property == "HoldDuration"
		local text = (inst:IsA("TextLabel") or inst:IsA("TextButton")) and command.property == "Text" and inst:IsDescendantOf(workspace)
		assert(duration or text, "Unsupported property")
		if duration then assert(type(command.value) == "number" and command.value >= 0 and command.value <= 10, "Invalid duration")
		else assert(type(command.value) == "string" and #command.value <= 4096, "Invalid sign text") end
		local before = inst[command.property]
		if before == command.value then return { status = "already_applied", value = before } end
		assert(before == command.before, "CONFLICT: property changed in Studio")
		History:SetWaypoint("Before Codex " .. command.id)
		inst[command.property] = command.value
		assert(inst[command.property] == command.value, "Property readback failed")
		History:SetWaypoint("Codex " .. command.id)
		return { status = "applied", before = before, value = inst[command.property] }
	elseif command.op == "update_source" then
		assert(allowed(config.scripts, command, false), "Script outside project scope")
		local before = sourceOf(inst)
		if before == command.source then return { status = "already_applied", source = before } end
		assert(before == command.beforeSource, "CONFLICT: source changed in Studio")
		History:SetWaypoint("Before Codex " .. command.id)
		Editor:UpdateSourceAsync(inst, function(current)
			assert(current == command.beforeSource, "CONFLICT: editor changed during update")
			assert(not testing(), "Play started during update")
			return command.source
		end)
		local after = sourceOf(inst)
		assert(after == command.source, "Editor readback failed")
		History:SetWaypoint("Codex " .. command.id)
		return { status = "applied", source = after }
	elseif command.op == "read_property" then
		assert(allowed(config.properties, command, true), "Read outside project scope")
		return { status = "read", value = inst[command.property] }
	end
	error("Unsupported bridge operation")
end

if plugin then
	local toolbar = plugin:CreateToolbar("Codex Local")
	local button = toolbar:CreateButton("CodexConnect", "Automatic connection enabled; click to reconnect", "", "Reconnect")
	button.ClickableWhenViewportHidden = true
	button:SetActive(true)
	button.Click:Connect(function()
		enabled = true
		button:SetActive(true)
		connected = false; token = nil; session = nil; config = nil
	end)
	plugin.Unloading:Connect(function() stopped = true end)
end

task.spawn(function()
	while not stopped do
		local ok, err = pcall(function()
			if not enabled then return end
			if not token then
				-- Do not connect unrelated places or a Play client DataModel.
				if testing() then return end
				resolve({ "Workspace", "Level1Development", "L1_PapanLatihan" })
				resolve({ "StarterPlayer", "StarterPlayerScripts", "Level1Handler" })
				local paired = request("/pair", { projectKey = PROJECT, sessionId = Http:GenerateGUID(false) }, true)
				token = paired.token; session = paired.sessionId; config = paired.config; connected = true
				print("[Codex Bridge] Connected: " .. session)
			end
			if not connected then return end
			local state = snapshot()
			request("/snapshot", state)
			if state.running then return end
			local job = request("/poll", {})
			if not job.command then return end
			local command = job.command
			local result = cache[command.id]
			if not result then
				local success, value = pcall(execute, command)
				result = { id = command.id, ok = success, result = success and value or nil, error = not success and tostring(value) or nil }
				cache[command.id] = result
				table.insert(order, command.id)
				if #order > 100 then cache[table.remove(order, 1)] = nil end
			end
			request("/result", result)
			if result.ok then print("[Codex Bridge] " .. command.id .. " " .. result.result.status) else warn("[Codex Bridge] " .. result.error) end
		end)
		if not ok and os.clock() - lastWarning > 30 then
			warn("[Codex Bridge] " .. tostring(err))
			lastWarning = os.clock()
		end
		task.wait(1)
	end
end)
