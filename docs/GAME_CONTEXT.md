# GAME_CONTEXT.md

## Tentang Game

**Judul internal:** Roblox Learning Media — Keterampilan Bahasa Indonesia
**Genre:** Educational / Game-Based Learning (bukan game kompetitif — tidak ada 
sistem kalah-menang)
**Tema/Setting:** Lingkungan kampus universitas dengan nuansa arsitektur 
klasik-modern (terinspirasi Yonsei University), suasana taman terbuka dan 
gedung pembelajaran

**Tujuan:** Media pembelajaran berbasis Roblox untuk melatih keterampilan 
menyimak dan membaca mahasiswa Teknologi Informasi pada mata kuliah Bahasa 
Indonesia, dengan konten materi yang dikontekstualisasi ke topik sistem 
informasi/teknologi informasi (sistem operasi, dsb).

**Struktur:** 3 level pembelajaran berurutan, masing-masing di gedung/area 
terpisah dalam map:
- **Level 1 — Menyimak:** audio narasi (dengan pilihan suara pria/wanita) 
  tentang konsep dasar sistem operasi, dilanjutkan kuis pilihan ganda (4 soal)
- **Level 2 — Membaca:** teks eksposisi berita (dual-OS tablet Cloud AI Pad), 
  dilanjutkan kuis
- **Level 3 — Membaca Lanjutan:** teks abstrak akademik (jurnal ilmiah tentang 
  sistem operasi), dilanjutkan kuis

Setiap level: masuk via `ProximityPrompt` → panel intro → materi → kuis → 
hasil (lulus jika skor ≥75, jika tidak wajib mengulang). Setelah 3 level 
selesai, dapat medali (Bronze/Silver/Gold/Platinum) berdasarkan total skor.

**Basis pengembangan:** Kelanjutan dari skripsi Sanubari (2026), model 4D. 
Fokus pengembangan lanjutan pada 3 aspek: penyajian materi, interaksi 
pembelajaran, dan umpan balik evaluasi.

## Tentang Widget HUD (Progress Indicator)

**Fitur untuk:** Menampilkan progres belajar mahasiswa secara real-time dan 
persisten selama bermain — bagian dari pengembangan lanjutan (P09 — informasi 
perkembangan belajar belum terlihat secara langsung).

**Menampilkan:**
- Level saat ini (1 dari 3)
- Total skor akumulasi dari seluruh level yang sudah diselesaikan

**Kenapa dibutuhkan:** Data ini **sudah tersimpan** di sistem sejak awal 
(`leaderstats.TotalScore` dan `leaderstats.LevelProgress`, dikelola oleh 
script `LeaderboardHandler.lua` dan `LevelProgressHandler.lua`), tapi 
sebelumnya cuma tampil di tab player list bawaan Roblox (kecil, gampang 
terlewat) dan baru benar-benar terlihat detail di layar ringkasan akhir 
(`SummaryHandler.lua`). Widget ini meng-*expose* data yang sudah ada itu ke 
HUD kustom yang selalu terlihat, tanpa perlu membangun sistem data baru.

**Scope fungsional (sengaja dibatasi minimal):**
- Bukan achievement/quest log system — cuma status indicator kecil
- Selalu terlihat, tidak ada panel buka-tutup
- Update otomatis saat skor/level berubah (subscribe ke `.Changed` event)
- Tidak ada locked/unlocked state atau animasi kompleks

**Referensi teknis:** lihat `LeaderboardHandler.lua`, `LevelProgressHandler.lua`


## Rencana Pengembangan (Roadmap Skripsi)

### In Scope — dikerjakan (prioritas urut)
1. **Feedback evaluasi + penjelasan** (P02) — status: belum dikerjakan
   - Tambah field `explanation` di struct `questions` pada Level1/2/3QuizHandler.lua
2. **Progress indicator HUD** (P09) — status: desain visual selesai, implementasi belum
   - Subscribe ke `leaderstats.TotalScore` dan `leaderstats.LevelProgress`
3. **Interaksi reflektif ringan sebelum kuis** (P08) — status: belum dikerjakan
   - Sisip 1 pertanyaan pemicu di ConfirmModal sebelum masuk kuis
4. **Board materi jadi bertahap/klik-untuk-buka** (P04) — status: belum dikerjakan, 
   prioritas terakhir, boleh dikorbankan duluan kalau waktu mepet

### Out of Scope — sengaja TIDAK dikerjakan di skripsi ini
(masuk bagian "Saran" BAB 7 nanti, bukan berarti idenya buruk, tapi effort/waktu 
tidak realistis untuk 2 bulan atau evidence-nya belum cukup kuat)
- Sistem dialog NPC penuh (branching conversation) — terlalu berat secara scripting
- Variasi tipe soal (fill-in-blank, matching, quiz spasial) — tiap tipe butuh mekanik terpisah
- Level kesulitan (easy/medium/hard) — butuh 3x lipat konten soal
- Sistem save/progress anti-disconnect (DataStore) — effort tinggi, risiko technical debt
- Gamifikasi lanjutan (leaderboard kompetitif, parkour, kustomisasi karakter) — 
  di luar fokus pedagogis keterampilan bahasa, condong ke P12 (engagement) yang 
  evidence-nya lemah
- Achievement/quest log system — sudah dipertimbangkan lalu di-downscope jadi 
  HUD minimal (lihat keputusan di riwayat chat)

### Catatan penting
Judul skripsi WAJIB identik dengan penelitian sebelumnya (instruksi dospem): 
"PENGEMBANGAN MEDIA PEMBELAJARAN BERBASIS ROBLOX UNTUK KETERAMPILAN BAHASA 
PADA MAHASISWA TEKNOLOGI INFORMASI MENGGUNAKAN MODEL 4D"
Model pengembangan: 4D (Define, Design, Develop, Disseminate) — sama seperti 
penelitian sebelumnya, bukan model baru.
Batas waktu efektif: 2 bulan untuk tahap develop.
