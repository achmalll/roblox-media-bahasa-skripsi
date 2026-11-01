# Alur aktif: kerja dari disk lokal PC warnet

Keputusan pengguna 1 November 2026: GitHub menjadi sumber perpindahan versi antar-PC; setiap sesi dikerjakan dari clone di disk internal PC. Flashdisk hanya untuk transfer/cadangan karena sudah terputus di warnet dan laptop. Ini menggantikan alur 29 Oktober yang menjadikan flashdisk sebagai folder kerja aktif.

## Saat tiba

1. Siapkan Roblox Studio, Codex dan akses Git pada PC itu. Jika sudah terpasang dan berfungsi, pakai yang ada; PC warnet yang direset mungkin memerlukan pemasangan/login lagi. Membawa repo tidak membawa instalasi, sesi login atau izin plugin PC.
2. Clone repo GitHub terbaru ke folder lokal pendek yang diizinkan, misalnya C:/RobloxWork/roblox-media-bahasa-skripsi. Jika clone lokal lama masih ada, AI cek status lalu perbarui secara aman. Alternatif saat jaringan lambat: salin repo lengkap termasuk .git dari cadangan USB ke disk lokal, verifikasi hash, lalu cek pembaruan GitHub. Jangan membuka proyek atau WORKING langsung dari USB.
3. Buka folder repo lokal itu di Codex. AI baca AGENTS.md, LANJUTKAN.md dan KONTEKS-AI.md; cari acuan dan kondisi aktual sendiri. Pengguna tidak perlu merakit brief dari arsip.
4. Jalankan CONNECT-STUDIO dari clone lokal untuk memasang plugin dan bridge PC tersebut. Bridge memerlukan Node yang mendukung ZSTD; jika runtime tidak tersedia di PC/Codex, salin folder tools/node dari paket cadangan ke folder tools di samping repo. Clone Git saja tidak memuat runtime portable yang berada di luar repo.
5. Buka places/RobloxLearningMedia-WORKING.rbxl **dari clone lokal yang sama**. Pastikan hanya satu clone/Studio yang terhubung, timestamp bridge segar dan mode Edit. Pengguna tetap mengendalikan Play/Stop/Save.

Prompt pengguna setelah membuka repo lokal:

> Baca AGENTS.md, LANJUTKAN.md dan KONTEKS-AI.md. Saya bekerja dari clone lokal PC warnet, USB hanya cadangan. Cek progres aktual dan lanjutkan target terakhir; bantu setup bridge dan pencatatan sesi. Jangan ulang fitur yang sudah selesai. Saya yang menjalankan Play/Stop/Save.

## Sebelum pulang

1. Stop dan Save WORKING lokal. AI verifikasi source yang tersimpan, catat Play aktual dan batas yang belum diuji; source sinkron editor belum membuktikan file sudah tersimpan.
2. AI perbarui konteks, log bertanggal sesi dan LANJUTKAN; review cakupan, commit dan push. Pastikan HEAD remote cocok, bukan hanya ada commit lokal.
3. Salin cadangan sesi ke USB bila tersedia, lalu verifikasi hash salinan. USB bukan satu-satunya tempat menyimpan progres. Jika penyalinan USB gagal tetapi push terverifikasi, catat kegagalan dan gunakan GitHub/laptop untuk sesi berikut.
4. Tutup aplikasi yang memakai USB sebelum eject. Pada PC warnet yang datanya dihapus setelah sesi, jangan meninggalkan satu-satunya perubahan belum push di disk lokal.

## Target development saat panduan ini dibuat

Source recorder/panah sudah di GitHub; WORKING masih checkpoint 31 Oktober, belum membawa delapan perubahan source baru. Target awal PC kuat: sinkronisasi11source -> user Save -> verifikasi11source -> QA panah/Level2 -> uji tulis-baca recorder pada experience uji. Baca docs/LEARNING-RECORDS.md. Latihan Level3 baru belum diimplementasikan. Akses Level2 sudah ada; jangan mengulang target integrasi Level1 dari panduan lama.

Tidak ada perubahan game, runtime, pengaturan cloud atau instalasi PC warnet oleh pembaruan panduan ini.
