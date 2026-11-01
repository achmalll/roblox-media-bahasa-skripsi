# Satu pintu sesi warnet: cukup minta "Setup warnet"

Alur aktif sejak 1 November 2026: kerja di clone pada disk internal PC; GitHub untuk perpindahan versi; USB hanya transfer/cadangan. Sesudah Git/Codex/Studio terpasang dan repo di-clone ke path pendek (misalnya C:/RobloxWork/roblox-media-bahasa-skripsi), buka folder itu di Codex dan kirim:

> Setup warnet dan lanjutkan workflow repo sampai siap diuji. Baca aturan dan status sendiri; saya mengendalikan login, izin plugin, Play/Stop/Save.

Tidak perlu menempelkan seluruh riwayat chat. AI di PC baru wajib mengikuti prosedur ini dari AGENTS.md. Jika user sedang di kos atau meminta kerja offline, gunakan CheckOnly; jangan membuka Studio laptop otomatis.

## Yang dilakukan AI secara otomatis

1. Baca AGENTS.md, panduan ini, entri paling atas LANJUTKAN.md/KONTEKS-AI.md dan log terbaru. Riwayat lama dibaca hanya bila relevan. Cek Git aktual dan file WORKING; jangan mengambil target lama dari arsip.
2. Jalankan dari root clone lokal:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/setup-warnet.ps1 -Mode Prepare -OpenStudio
```

Pengguna boleh menjalankan SETUP.cmd untuk tahap yang sama. Helper memperbarui main secara fast-forward bila repo bersih dan tidak akan mengganti file yang sedang terbuka di Studio; perubahan lokal/branch lain tidak di-reset. Node22.23.4 yang mendukung ZSTD dipakai jika tersedia, atau disiapkan otomatis dari ZIP resmi + SHA256 dalam local-rbxl/runtime/node (tanpa admin/PATH global). Lalu plugin dipasang dan bridge clone ini disiapkan. Fingerprint konfigurasi yang berubah memicu restart bridge dengan receipt PID/root/exe/starttime terverifikasi; bridge clone lain tidak dimatikan. Studio dibuka pada WORKING lokal bila belum ada Studio berjalan. Jendela yang sudah ada tidak ditutup/ditimpa otomatis.
3. Baca laporan local-rbxl/setup/latest.json. **Jangan berhenti hanya setelah helper sukses**, dan jangan menyatakan game siap dari status Git saja. Lanjutkan menurut tahap di bawah. Login, izin plugin/localhost dan tindakan Studio yang membutuhkan pengguna disampaikan satu per satu, bukan meminta pengguna mempelajari setup sendiri.
4. Untuk membaca ulang status, gunakan:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/setup-warnet.ps1 -Mode Status
```

Status/CheckOnly tidak download, memasang plugin, menyalakan bridge/Studio, pull, atau menulis WORKING. Pemeriksaan membaca health localhost dan snapshot terbaru; EACCES sandbox berarti akses tool ditolak, bukan bukti file hilang. AI gunakan izin tool yang sesuai bila diperlukan. Jangan mencetak token/config akun.

| Tahap laporan | Tindakan AI berikut |
| --- | --- |
| setup_failed | Baca error; perbaiki prasyarat yang dapat ditangani, lanjutkan pekerjaan independen. Jangan reset perubahan lokal. |
| locate_or_install_studio | Cari instalasi nonstandar; jika belum ada bantu instalasi resmi sesuai izin PC. Login tetap pengguna. Codex CLI tidak wajib untuk aplikasi desktop. |
| wrong_clone / bridge_config_changed | Periksa identitas clone. Restart hanya bridge milik clone yang terverifikasi; jalankan Prepare lagi setelah penyebab teratasi. |
| restart_studio_after_save | Plugin diperbarui saat Studio sudah berjalan; pengguna Save/tutup sesi lama dan buka ulang WORKING yang benar. |
| awaiting_studio / stale_status | Periksa login/plugin/izin dan file yang dibuka. Poll ulang setelah tindakan; online kemarin tidak dianggap online sekarang. |
| awaiting_edit | Pengguna Stop Play/Run dahulu; antrean bridge menunggu Edit. |
| source_conflict | Simpan kedua versi dan selesaikan konflik; jangan menimpa sepihak. |
| syncing_editor | Pantau sampai seluruh source terkelola sinkron dan readback baru; baca receipt/error bila macet. Jumlah mengikuti project.json (sekarang11), bukan angka lama di panduan. |
| awaiting_save | Beri path WORKING tepat kepada pengguna untuk Save, lalu verifikasi file disk. Bila tetap berbeda, cek jendela Studio duplikat/path Save, bukan menganggap user belum menekan Save. |
| ready_for_play | Source editor segar dan file disk cocok; baru pandu checklist Play. Ini belum bukti QA/cloud lulus. |

Sesudah pengguna Save:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/setup-warnet.ps1 -Mode VerifySaved
node scripts/verify-studio-save.cjs
```

VerifySaved keluar dengan kode2 bila source disk masih berbeda; jangan menganggap setup selesai. Node dipilih melalui dot-source scripts/portable-runtime.ps1 dan Get-ProjectNode bila PATH Node lama. AI membandingkan seluruh source; pengguna tidak perlu mengecek 11 script satu per satu. Jangan patch biner untuk melewati Save.

## Uji dan tutup sesi

Pengguna Play; AI pandu uji target dari LANJUTKAN/brief, baca Output/bukti aktual, perbaiki satu masalah lalu ulang bagian relevan. Pengguna Stop/Save setelah perubahan; AI verifikasi lagi. Bedakan editor sinkron, Savedisk, Play dan cloud. AI menulis KONTEKS-AI.md, entri log hari itu dan LANJUTKAN.md; review scope perubahan, commit/push yang sudah diotorisasi, dan cocokkan HEAD dengan remote. Helper penutupan scripts/selesai-sesi.ps1 memeriksa Save, cadangan, handoff dan push; ia meminta konfirmasi interaktif bila dijalankan manual. AI boleh menjalankan Git langsung sesuai otorisasi sesi agar tidak meminta YA berulang. Launcher/helper USB dan helper mulai/selesai-warnet lama telah dihapus.

Jika PC direset setelah sesi, tidak boleh meninggalkan satu-satunya progres belum push di disk lokal. Cadangan USB opsional dan hash salinan diperiksa; git push terverifikasi tetap pegangan utama. Hentikan bridge clone ini dengan stop-studio-bridge.ps1 saat tidak dipakai. Tidak auto publish atau mengubah pengaturan cloud dari permintaan setup.

## Target saat ini

Source recorder/panah sudah di GitHub, WORKING masih checkpoint31Oktober; delapan perubahan menunggu pemasangan. Mulai dari sync11 -> user Save -> verify11 -> Play panah/L2 -> uji tulis-baca recorder pada experience uji sesuai docs/LEARNING-RECORDS.md. LatihanL3 baru belum dibuat; aksesL2 sudah ada. Jangan mengulang fitur lama. Paket Rojo/Argon, konfigurasi TOML/JSON migrasi dan folder src/src copy/migration-v2 telah dihapus dari tree aktif atas permintaan pengguna. Tidak perlu memasang tooling migrasi; gunakan source studio-sync dan WORKING.

API/prasyarat resmi: [Node22.23.4](https://nodejs.org/en/download/archive/v22.23.4), [Roblox Studio setup](https://create.roblox.com/docs/studio/setup). Repo tidak membawa login atau izin PC; helper tidak menjanjikan dapat melewati batas instalasi/koneksi yang ditetapkan warnet.
