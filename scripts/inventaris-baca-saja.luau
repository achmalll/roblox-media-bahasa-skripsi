-- Audit opsional dengan Lune 0.11.1. Jalankan dari root repo.
-- Hanya deserialize dan membaca data; tidak serialize, menjalankan script game, atau Play.
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local place = roblox.deserializePlace(fs.readFile("places/RobloxLearningMedia-WORKING.rbxl"))
local report = {
    scope = "Pembacaan parsial file, bukan Play atau verifikasi audio/izin aset",
    limitation = "Lune 0.11.1 memperingatkan properti Terrain tipe 0x23 tidak didukung; tidak dipakai menyimpan ulang place",
    sounds = {}, spawns = {}, prompts = {}, level1GuiChildren = {}, sourceMatches = {},
}
local function property(inst, key)
    local ok, value = pcall(function() return inst[key] end)
    return if ok then tostring(value) else "Tidak terbaca oleh alat; periksa di Studio"
end
for _, inst in place:GetDescendants() do
    if inst.ClassName == "Sound" and inst:GetFullName():sub(1,21) == "StarterGui.Level1Gui." then
        table.insert(report.sounds, {path = inst:GetFullName(), soundId = property(inst, "SoundId")})
    elseif inst.ClassName == "SpawnLocation" then
        table.insert(report.spawns, {path = inst:GetFullName(), cframe = property(inst, "CFrame")})
    elseif inst.ClassName == "ProximityPrompt" then
        table.insert(report.prompts, {path = inst:GetFullName(), actionText = property(inst, "ActionText"), objectText = property(inst, "ObjectText")})
    end
end
local gui = place:FindFirstChild("StarterGui"):FindFirstChild("Level1Gui")
for _, child in gui:GetChildren() do
    table.insert(report.level1GuiChildren, {name = child.Name, class = child.ClassName})
end
report.experimentalProgressGuiPresent = place:FindFirstChild("StarterGui"):FindFirstChild("LevelProgressGui") ~= nil
local locations = {
    {"StarterPlayer", "StarterPlayerScripts", "Level1Handler", "client"},
    {"StarterPlayer", "StarterPlayerScripts", "Level1QuizHandler", "client"},
    {"StarterPlayer", "StarterPlayerScripts", "FlowController", "client"},
    {"ServerScriptService", "LevelProgressHandler", "server"},
    {"ServerScriptService", "Level1ScoreHandler", "server"},
}
local normalize = function(s) return s:gsub("\r\n", "\n") end
for _, location in locations do
    local suffix = location[#location]
    local node = place
    local path = "migration-v2/src/"
    for i = 1, #location - 1 do
        node = node:FindFirstChild(location[i])
        path ..= location[i]
        if i < #location - 1 then path ..= "/" end
    end
    path ..= "." .. suffix .. ".luau"
    report.sourceMatches[path] = normalize(node.Source) == normalize(fs.readFile(path))
end
fs.writeFile("docs/development/2026-10-27/inventaris.json", serde.encode("json", report, true))
print("Inventaris baca-saja tersimpan: docs/development/2026-10-27/inventaris.json")
