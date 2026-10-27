-- Jalankan seluruh isi file ini melalui Command Bar Roblox Studio dalam mode Edit.
-- Target terverifikasi dari Output pengguna pada 27 Oktober 2026 pukul 23:35.
-- Mengubah tulisan SurfaceGui saja; tidak membuat modal atau logic interaksi.
-- Acuan isi: storyboard pembuka/Level 1, 05B (penguatan singkat).

assert(not game:GetService("RunService"):IsRunning(), "Stop Play dahulu, lalu jalankan dalam mode Edit.")

local area = workspace:FindFirstChild("Halaman depan")
assert(area, "Workspace.Halaman depan tidak ditemukan.")
local boards = {}
for _, child in ipairs(area:GetChildren()) do
	if child.Name == "L1_PapanInformasi" then
		table.insert(boards, child)
	end
end
assert(#boards == 1, "Harus ada tepat satu Halaman depan.L1_PapanInformasi; ditemukan " .. #boards)
local board = boards[1]

local changes = {
	{ part = "Title", text = "KENALI SISTEM OPERASI" },
	{ part = "Animation 1", text = "Sistem operasi adalah perangkat lunak." },
	{ part = "Animation 2", text = "Mengelola sumber daya komputer:\nProsesor • Memori • Penyimpanan" },
	{ part = "Animation 3", text = "Perangkat input dan output.\nSelanjutnya, temui Tutor 2." },
}

-- Periksa SEMUA target sebelum mengubah satu pun label.
for _, change in ipairs(changes) do
	local target = board
	for _, name in ipairs({ change.part, "SurfaceGui", "Frame", "Edit me" }) do
		target = target:FindFirstChild(name)
		assert(target, "Target tidak lengkap: " .. change.part .. ".SurfaceGui.Frame.Edit me")
	end
	assert(target:IsA("TextLabel") or target:IsA("TextButton") or target:IsA("TextBox"), "Target bukan objek teks: " .. target:GetFullName())
	change.target = target
end

local history = game:GetService("ChangeHistoryService")
history:SetWaypoint("Sebelum teks papan informasi L1")
for _, change in ipairs(changes) do
	change.target.Text = change.text
	print("DIUBAH", change.target:GetFullName(), "=", change.target.Text)
end
history:SetWaypoint("Teks papan informasi L1 diperbarui")
print("SELESAI: empat label papan diperbarui dalam mode Edit. Periksa keterbacaan, lalu Save to File WORKING. Modal dan gating audio belum diubah.")
