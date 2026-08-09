# TODO.md

## Fase 1 — Feedback Evaluasi (P02) — PRIORITAS 1
- [ ] Susun teks penjelasan untuk tiap soal (12 soal: 4×3 level), rujuk ke 
      materi asli (Lampiran A.1-A.3 skripsi sebelumnya)
- [ ] Tambah field `explanation` di struct `questions` — Level1QuizHandler.lua
- [ ] Ulangi untuk Level2QuizHandler.lua
- [ ] Ulangi untuk Level3QuizHandler.lua
- [ ] Cek UI `feedbackLabel` — sesuaikan ukuran/wrapping kalau teks lebih panjang
- [ ] Test manual: semua kombinasi benar/salah tampil dengan benar

## Fase 2 — Progress Indicator HUD (P09) — PRIORITAS 2
- [x] Desain visual widget (sudah ada, revisi bahasa Indo + ganti ikon)
- [ ] Bangun struktur Frame/TextLabel di Roblox Studio sesuai desain
- [ ] Script baru: subscribe ke `leaderstats.TotalScore.Changed` dan 
      `leaderstats.LevelProgress.Changed`
- [ ] Posisikan HUD (cek tidak menutupi elemen lain)
- [ ] Test manual: HUD update real-time saat skor berubah

## Fase 3 — Interaksi Reflektif (P08) — PRIORITAS 3
- [ ] Susun 1 pertanyaan reflektif per level (kontekstual ke materi)
- [ ] Modifikasi ConfirmModal flow di Level1/2/3Handler
- [ ] Test manual

## Fase 4 — Board Materi Bertahap (P04) — PRIORITAS 4 (opsional, cut duluan)
- [ ] Desain interaksi klik-untuk-buka istilah
- [ ] Modifikasi Level2BoardHandler.lua & Level3BoardHandler.lua
- [ ] Test manual

## Validasi & Dokumentasi
- [ ] Validasi ahli media (setelah Fase 1-3 minimal selesai)
- [ ] Validasi ahli materi (khusus konten explanation feedback)
- [ ] Uji coba ke mahasiswa (disseminate)
- [ ] Tulis BAB 4 (Perancangan) — screenshot before/after
- [ ] Tulis BAB 5 (Pengembangan) — dokumentasi implementasi

## Setup & Infra
- [ ] Install Argon + Git (lihat SETUP.md)
- [ ] Buat repo GitHub, push kondisi awal (baseline dari file .rbxl kating)
- [ ] Commit per fitur selesai, bukan sekali commit besar di akhir
