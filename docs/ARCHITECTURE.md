# ARCHITECTURE.md

## Struktur Skrip (hasil bongkar file .rbxl asli)

### LocalScript (client-side, di StarterPlayerScripts / UI)
| Script | Fungsi |
|---|---|
| Level1Handler.lua | Kontrol audio player Level 1, buka panel intro/pilihan suara |
| Level1QuizHandler.lua | Logic kuis Level 1 (4 soal, cek jawaban, skor, feedback) |
| Level2BoardHandler.lua | Kontrol papan info Level 2 (2 slide statis) |
| Level2FlowHandler.lua | Alur intro → baca teks → konfirmasi → kuis Level 2 |
| Level2QuizHandler.lua | Logic kuis Level 2 |
| Level3BoardHandler.lua | Kontrol papan info Level 3 |
| Level3FlowHandler.lua | Alur Level 3 (sama pola dengan Level 2) |
| Level3QuizHandler.lua | Logic kuis Level 3 |
| LevelAccessHandler.lua | Gate akses antar level berdasarkan progress |
| FlowController.lua | Kontrol alur umum antar area |
| ArrowGuideScript.lua | Penunjuk arah (arrow guide) menuju tujuan |
| SummaryHandler.lua | Layar ringkasan hasil belajar di akhir |
| CameraController.lua | Kontrol kamera |
| GuiSoundEffect.lua | Efek suara UI |
| DisableResetButton.lua | Nonaktifkan tombol reset karakter bawaan Roblox |

### ModuleScript (reusable logic, di StarterPlayerScripts)
| Module | Fungsi |
|---|---|
| PlayerControlHandler.lua | `.Lock()` / `.Unlock()` — kunci pergerakan karakter saat UI terbuka |
| GuiAnimationHandler.lua | `.Show(frame)` / `.Hide(frame, callback)` — animasi TweenService untuk panel |

### Script (server-side)
| Script | Fungsi |
|---|---|
| LeaderboardHandler.lua | Inisialisasi `leaderstats` (TotalScore, LevelProgress) saat player join |
| Level1/2/3ScoreHandler.lua | Terima skor dari client via RemoteEvent, simpan ke `PlayerScores` |
| LevelProgressHandler.lua | Update `LevelProgress` saat client kirim event |
| GiveMedalHandler.lua | Clone medali dari `ServerStorage.AchievementTools` ke `Backpack` player |

### RemoteEvent (ReplicatedStorage)
- `UpdateLevel1Score`, `UpdateLevel2Score`, `UpdateLevel3Score` (asumsi Level2/3 
  mengikuti pola Level1 — perlu diverifikasi manual)
- `UpdateLevelProgress`
- `GiveMedalEvent`

## Pola Umum (konsisten di semua level)
ProximityPrompt.Triggered
→ GuiAnimation.Show(introFrame) + PlayerControl.Lock()
→ [baca materi]
→ ConfirmModal ("yakin mulai kuis?")
→ quizFrame.Visible = true
→ checkAnswer() per soal → feedbackLabel.Text (statis "Benar"/"Salah")
→ finishQuiz() → skor ≥75 lulus, kirim event ke server

## Data Flow (skor & progress)
Client (QuizHandler)
→ RemoteEvent (UpdateLevelXScore)
→ Server (ScoreHandler)
→ player.PlayerScores.LevelXScore.Value = score
→ leaderstats.TotalScore auto-update (Changed event listener)

## Yang PERLU divalidasi manual (belum 100% dikonfirmasi dari parsing)
- Struktur folder aset UI (Figma vs in-game — nama Frame/TextLabel harus dicocokkan manual)
- RemoteEvent untuk Level2/Level3 score (aku asumsikan namanya konsisten polanya, 
  tapi belum aku decode manual satu-satu)
- Struktur `AchievementTools` di ServerStorage (isi medali Bronze/Silver/Gold/Platinum)
