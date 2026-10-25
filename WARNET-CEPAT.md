# Mulai bekerja dari laptop atau warnet

File utama: **places/RobloxLearningMedia-WORKING.rbxl** di dalam clone repository. Inilah place utuh yang dipakai sampai migrasi selesai diuji Play. `src/`, `src copy/` dan `default.project.json` adalah arsip migrasi lama. Hasil `migration-v2/build/` adalah kandidat pengujian, bukan pengganti otomatis WORKING.

## Sekali pada setiap PC

Sediakan Git dan Roblox Studio. Clone repository private milik sendiri melalui akun GitHub yang berwenang:

```powershell
git clone https://github.com/achmalll/roblox-media-bahasa-skripsi.git
cd roblox-media-bahasa-skripsi
```

Login dilakukan melalui Git/GitHub; jangan memasukkan token ke script. Jika clone sudah ada, gunakan folder itu. Untuk alur place utuh ini tidak perlu memasang Rojo, Argon, Node atau plugin sinkronisasi. Pengaturan akun/aset/audio Roblox tetap perlu diperiksa pada Play pertama.

## Setiap mulai sesi

Pastikan sesi PC sebelumnya sudah Save to File dan push. Tutup WORKING yang masih terbuka sebelum menarik pembaruan. Dari folder repository:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\mulai-warnet.ps1
```

Ini memeriksa file dan Git, menolak pull jika WORKING punya perubahan lokal, lalu pull dengan fast-forward. Buka path WORKING yang dicetak. Untuk sekaligus membukanya lewat asosiasi file, tambahkan `-OpenStudio`. Jika asosiasi .rbxl tidak tersedia, buka melalui File > Open from File di Studio. Perubahan file lain tetap terlihat pada status dan tidak dihapus.

## Setiap selesai sesi

Di Studio: Stop Play, lalu **Save to File** ke WORKING pada folder clone yang sama. Setelah itu:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\selesai-warnet.ps1 -Message "Level 1: jelaskan perubahan sesi"
```

Script hanya men-stage WORKING, membuat commit jika berubah, push, lalu memeriksa tidak ada commit lokal tertinggal. Jika file lain sudah di-stage, script berhenti supaya tidak ikut meng-commit pekerjaan lain. Script tidak menekan Save di Studio. Catat hasil Play dan commit sesi; keluar akun pada PC umum setelah semuanya selesai.

## Pemeriksaan tanpa mengubah apa pun

Tambahkan `-CheckOnly` pada salah satu script untuk melihat file, hash dan status saja. `mulai-warnet.ps1 -Offline` melewati pull; gunakan hanya ketika salinan terakhir jelas. Jika push/internet gagal, simpan salinan WORKING bertanggal sebagai cadangan dan lanjutkan satu sumber pekerjaan saja sampai sinkronisasi pulih. Jangan bekerja bersamaan dari dua PC pada binary yang sama, jangan force-push/reset, dan jangan menyalin build migrasi di atas WORKING.

## Pemeriksaan Play pertama

Periksa spawn/sambutan dan panduan, audio baseline, kuis tiga level, ambang75, penguncian gedung, ringkasan dan medali. Ulangi buka file hasil pull pada PC warnet berikutnya. Build/statistik statis tidak menggantikan Play. Rancangan baru segmentasi tiga klip, latihan baru, tier2, feedback, spot foto/bonus belum otomatis ada di baseline.

Persiapan ini menyederhanakan perpindahan pekerjaan; keberhasilan Play di PC kedua tetap harus dicatat saat perangkat itu tersedia.
