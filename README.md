# Media pembelajaran Roblox untuk skripsi Achmal

**Kerja langsung dari flashdisk:** baca [PAKAI-FLASHDISK.md](PAKAI-FLASHDISK.md). Jalankan `MULAI.cmd` pada folderinduk paket, atau `MULAI-PORTABLE.cmd` pada repo. Proyek dan Git dibawa terus; runtime portable di foldertools tidak ikut cloneGitHub. Studio/Codex tetap tersedia pada PC.

> **Mulai di PC/clone baru:** AI atau pengembang yang akan mengerjakan Roblox harus membaca `AGENTS.md` dan `KONTEKS-AI.md`, lalu menjalankan `CONNECT-STUDIO.cmd`. Setelah Roblox Studio membuka `places/RobloxLearningMedia-WORKING.rbxl`, pastikan bridge online dan source sinkron sesuai `studio-sync/README.md`. Clone saja belum memasang plugin Studio; helper memasangnya secara lokal. Jangan menjalankan Play/Save/publish tanpa kebutuhan tugas.

File utama pengembangan: `places/RobloxLearningMedia-WORKING.rbxl`. Buka dan simpan file ini langsung di Roblox Studio. `RobloxLearningMedia-BACKUP.rbxl` milik penelitian pendahulu tetap berada di folder lokal induk dan tidak dimasukkan ke repository.

**Bridge Codex ↔ Studio (28 Oktober 2026):** jalankan `CONNECT-STUDIO.cmd` untuk setup/aktivasi lokal dari repo. [Panduan dan batas cakupan](studio-sync/README.md). Source `Level1Handler` dapat disinkronkan ke editor tanpa patch biner yang terbuka; Studio tetap menyimpan WORKING. Clone saja belum memuat plugin di PC baru.

Untuk sprint menuju 3 November, baca [pemeriksaan tahap 0 dan setup pindah warnet](docs/development/2026-10-27/TAHAP-0.md). Cadangan tambahan WORKING dapat dibuat dengan `scripts/cadangkan-sesi.ps1`; cadangan tidak menggantikan Save di Studio atau push Git.

Untuk PC warnet baru, ikuti [panduan sesi tiga jam dan koneksi AI](PANDUAN-WARNET-3-JAM.md). Pemeriksaan awal satu perintah tersedia pada `scripts/cek-warnet.ps1`.

Untuk AI memahami flow, mulai dari [brief](KONTEKS-AI.md), [peta sumber dan link Docs rancangan](docs/ACUAN-DESAIN.md), lalu [snapshot storyboard/gambar](docs/desain/README.md). Setiap perubahan wajib memperbarui brief dan [log pengembangan](docs/LOG-PENGEMBANGAN.md), sesuai [AGENTS.md](AGENTS.md).

Repository GitHub ini **private** dan menyimpan place utuh agar pekerjaan di laptop dan beberapa komputer warnet dapat disinkronkan. **Mulai dari [panduan laptop dan warnet](WARNET-CEPAT.md)** untuk clone, perintah sebelum/sesudah edit, Save to File, commit/push, dan pemulihan jika pindah PC atau internet terputus.

`default.project.json`, `src/`, dan `src copy/` berasal dari percobaan Rojo/Argon lama dan dipertahankan sebagai arsip. Migrasi ulang memakai Rojo 7.7.0 berada pada `migration-v2/` dengan konfigurasi `migration-v2.syncback.project.json`. Build sudah berhasil dan cocok secara statis untuk seluruh script serta teks GUI, tetapi masih harus diuji Play di Studio sebelum menggantikan WORKING sebagai sumber utama. Baca `MIGRASI_ROJO_V2.md`. Fitur penelitian baru belum diimplementasikan pada baseline ini.
