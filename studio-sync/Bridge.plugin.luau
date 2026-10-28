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
	local current = game
	for _, name in ipairs(parts) do
		local found
		for _, child in ipairs(current:GetChildren()) do
			if child.Name == name then
				assert(not found, "Ambiguous path: " .. name)
				found = child
			end
		end
		assert(found, "Missing instance: " .. name)
		current = found
	end
	return current
end

local function request(route, body, pairing)
	local headers = { ["Content-Type"] = "application/json", ["X-Codex-Bridge"] = "rbxl-v1" }
	if token then headers["X-Bridge-Token"] = token end
	if session then headers["X-Studio-Session"] = session end
	local response = Http:RequestAsync({ Url = BASE .. route, Method = "POST", Headers = headers, Body = Http:JSONEncode(body) })
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

local function execute(command)
	assert(not testing(), "Play active: edits paused")
	local inst = resolve(command.instancePath)
	assert(inst.ClassName == command.className, "Target class changed")
	if command.op == "set_property" then
		assert(allowed(config.properties, command, true), "Property outside project scope")
		assert(inst:IsA("ProximityPrompt") and command.property == "HoldDuration", "Unsupported property")
		assert(type(command.value) == "number" and command.value >= 0 and command.value <= 10, "Invalid duration")
		local before = inst.HoldDuration
		if before == command.value then return { status = "already_applied", value = before } end
		assert(before == command.before, "CONFLICT: property changed in Studio")
		History:SetWaypoint("Before Codex " .. command.id)
		inst.HoldDuration = command.value
		assert(inst.HoldDuration == command.value, "Property readback failed")
		History:SetWaypoint("Codex " .. command.id)
		return { status = "applied", before = before, value = inst.HoldDuration }
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
	local button = toolbar:CreateButton("CodexConnect", "Connect/pause local Codex bridge", "", "Connect")
	button.ClickableWhenViewportHidden = true
	button.Click:Connect(function()
		enabled = not enabled
		button:SetActive(enabled)
		if not enabled then connected = false; token = nil; session = nil; config = nil end
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
