# AI_INSTRUCTIONS.md

Instruksi untuk AI coding assistant (dipakai lewat VS Code + Argon, bukan lewat
plugin AI di Roblox Studio — lihat SETUP.md bagian "AI Tooling" untuk alasannya).

## Konteks Project
Skripsi PTI FILKOM UB — pengembangan LANJUTAN dari media pembelajaran Roblox
"Keterampilan Bahasa Indonesia" (basis: skripsi Sanubari 2026, model 4D).
Judul WAJIB identik: "PENGEMBANGAN MEDIA PEMBELAJARAN BERBASIS ROBLOX UNTUK
KETERAMPILAN BAHASA PADA MAHASISWA TEKNOLOGI INFORMASI MENGGUNAKAN MODEL 4D".
Batas waktu tahap develop: 2 bulan. JANGAN mengubah struktur/fitur yang sudah
ada dan tervalidasi — tugas AI adalah MENAMBAH 4 fitur di roadmap, bukan merombak.

## Aturan Wajib
1. Ikuti konvensi penamaan yang sudah ada: PascalCase, akhiran `Handler` untuk
   logic per-level (`Level1QuizHandler`, dst).
2. Reuse module yang sudah ada — jangan bikin fungsi lock/unlock karakter atau
   show/hide panel baru:
```lua
   local PlayerControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerControlHandler"))
   local GuiAnimation = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("GuiAnimationHandler"))
```
3. Semua teks UI dalam Bahasa Indonesia (media pembelajaran Bahasa Indonesia).
4. Skor/progress WAJIB lewat RemoteEvent ke server (`UpdateLevelXScore`,
   `UpdateLevelProgress`) — jangan modifikasi `leaderstats` langsung dari client.
5. HUD Progress Indicator (P09): scope-nya sengaja minimal — cuma tampilkan
   level saat ini + total skor, update via `.Changed` event, TIDAK ADA
   panel buka-tutup, locked state, atau animasi kompleks. Jangan over-engineer.
6. Field `explanation` (feedback evaluasi, P02) disimpan di struct `questions`
   yang sudah ada — jangan hardcode teks feedback di banyak tempat terpisah.
7. Setiap selesai edit script, ingatkan user test manual di Play mode sebelum
   commit — AI tidak bisa lihat hasil visual di Roblox Studio.

## Larangan Tegas (Out of Scope — lihat GAME_CONTEXT.md untuk alasan lengkap)
Jangan implementasikan, walau diminta "sekalian aja" — tanya balik ke user dulu:
- Sistem dialog NPC / branching conversation (termasuk yang pakai AI API apa pun)
- Variasi tipe soal (fill-in-blank, matching, spasial)
- Level kesulitan (easy/medium/hard)
- DataStore / sistem save anti-disconnect
- Leaderboard kompetitif, parkour, kustomisasi karakter, achievement/quest log

## Kalau ragu
Tanya dulu sebelum eksekusi perubahan besar (>1 file atau >30 baris).
