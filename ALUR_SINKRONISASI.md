# Alur kerja lintas laptop dan warnet

Status 24 September 2026: GitHub repository `achmalll/roblox-media-bahasa-skripsi` terkonfirmasi **private**. Place `WORKING` dalam folder `places/` disalin dari file asli di folder Roblox induk; file asli tidak diubah. `BACKUP.rbxl` milik Alif dan `MIGRATION.rbxl` tidak dimasukkan ke repository; file MIGRATION memiliki hash sama persis dengan WORKING pada tanggal ini.

## Sumber kerja

- **Kanonis untuk pengembangan:** `places/RobloxLearningMedia-WORKING.rbxl` di dalam repository ini.
- **Baseline penelitian pendahulu:** `../RobloxLearningMedia-BACKUP.rbxl` hanya berada di folder lokal induk sebagai pembanding, tidak diedit atau diunggah.
- Tiga `.rbxl` di folder induk `../` adalah arsip awal 24 September; jangan membuka lalu menyimpan yang di luar repo sebagai pekerjaan harian, sebab editnya tidak akan terkirim ke GitHub.
- `src/` dan `src copy/` belum merupakan representasi penuh place. Jangan menjalankan build Rojo lalu menimpa `WORKING.rbxl` dengan hasilnya.

## Pada komputer baru

1. Pasang/jalankan Git dan Roblox Studio; login ke akun GitHub pribadi bila perlu. Clone repository private ini ke folder kerja lokal yang diizinkan komputer.
2. Sebelum membuka Studio, jalankan `git pull --ff-only` dari dalam folder repository. Jika gagal karena perubahan lokal, hentikan dulu dan simpan salinan file kerja; jangan paksa reset.
3. Buka `places/RobloxLearningMedia-WORKING.rbxl` langsung dari folder clone. Pastikan nama/path pada Studio sebelum menekan Save.
4. Uji di Studio, lalu **Save to File** pada path `WORKING.rbxl` yang sama. Lihat `git status --short` dan pastikan yang berubah sesuai sesi.
5. Jalankan `git add places/RobloxLearningMedia-WORKING.rbxl`, `git commit -m "Jelaskan perubahan sesi"`, lalu `git push`. Pastikan push berhasil sebelum pindah komputer. Jangan bekerja bersamaan pada dua komputer karena Git tidak dapat menggabungkan dua perubahan binary `.rbxl` secara otomatis.
6. Keluar dari akun GitHub/Roblox pada PC umum dan hapus salinan lokal sesuai kebijakan warnet. Jangan menyimpan token atau password di repository/flashdisk.

## Bila internet atau GitHub terputus

Simpan salinan bertanggal dari `WORKING.rbxl` pada flashdisk. Saat online kembali, pilih **satu** salinan kerja yang paling mutakhir, salin ke path kanonis dalam clone yang sudah di-`pull`, uji buka di Studio, lalu commit/push. Jangan menggabungkan dua binary `.rbxl` dengan Git; perbedaan harus dipindahkan secara manual di Studio.

## Pengamanan setiap sesi

Catat tanggal, komputer, perubahan level/fitur, hasil uji Play, dan commit Git dalam log pengembangan. Untuk eksperimen A/B, buat salinan/commit versi A dan B yang dibekukan; jangan mengubah file yang dipakai di tengah pengumpulan data. GitHub private adalah sinkronisasi dan riwayat, sedangkan flashdisk/OneDrive adalah cadangan tambahan.

## Status Rojo

Rojo dapat bermanfaat untuk script yang sudah dipetakan dan versi teks. Namun `default.project.json` saat ini hanya memetakan sebagian service, sementara place juga menyimpan Workspace, terrain/aset, GUI, dan script lain. Karena itu alur kerja di atas memakai file place utuh sampai migrasi diuji dengan pembandingan dan Play test terpisah. Dokumentasi resmi: [porting existing game](https://rojo.space/docs/v7/getting-started/existing-game/) dan [sync details](https://rojo.space/docs/v7/sync-details/).
