# Proyek kerja di flashdisk + cadangan GitHub

29 Oktober 2026. Satu repository utama dibawa pada flashdisk; `.git`, WORKING, source, audio, rancangan dan konteks ikut berpindah. Commit/push tetap dilakukan setiap selesai sesi. Tidak perlu clone ulang di setiap PC.

## Folder yang dipakai

```text
roblox/                             ← folder di flashdisk, huruf drive boleh berubah
  MULAI.cmd
  TERMINAL.cmd
  SELESAI.cmd
  BACA-DULU.txt
  tools/
    PortableGit/                    ← Git yang sudah tersedia pada flashdisk
    node/                           ← node.exe, lisensi dan metadata checksum resmi
  roblox-media-bahasa-skripsi/        ← buka folder ini sebagai proyek Codex
    .git/
    places/RobloxLearningMedia-WORKING.rbxl
    studio-sync/src/Level1Handler.client.luau
    KONTEKS-AI.md
    docs/
    scripts/
  session-backups/                   ← cadangan WORKING + manifest
  cadangan/                         ← repository lama, tidak dipakai untuk edit
```

Path awal pengguna adalah `D:\roblox`. Launcher memakai lokasi dirinya, bukan hurufD yang ditulis tetap di kode. Simpan folder `tools` berdampingan dengan repository. GitHub membawa source helper/panduan; paket runtime portable tetap di flashdisk, tidak otomatis ikut clone dari GitHub.

## Satu pintu untuk sesi berikutnya

Baca LANJUTKAN.md. MULAI menampilkan pathaktual dan satu promptsiapsalin; AI membaca sumber, memandu targetberikut dan mengurus catatanharian. Jadwal/tugas terbaru ada pada handoff itu. SELESAI mewajibkan KONTEKS-AI.md, docs/LOG-PENGEMBANGAN.md dan LANJUTKAN.md diperbarui bersama perubahan.

## Saat tiba di PC baru

1. Colok flashdisk, buka folder `roblox`, klik **MULAI.cmd**. Launcher memilih Node/Git portable, memeriksa status/hash, memasang/memperbarui plugin bridge bila perlu dan menyalakan server localhost. Tidak otomatis pull, Play, Save atau publish.
2. Studio dan Codex tetap perlu tersedia di PC. Login bila diminta. Buka **WORKING di dalam repository flashdisk**, bukan tiga filearsip pada folderinduk atau repo di foldercadangan.
3. Bila plugin baru disalin/diperbarui, buka ulang Studio. Tanggapi izin localhost/akses script di Studio bila muncul. Koneksi dan izin aplikasi tetap perPC; helper mengerjakan pemasangannya, bukan memindahkan sesi login dari PC lama.
4. Di Codex, buka folder `roblox-media-bahasa-skripsi` pada flashdisk. Baca `AGENTS.md`, `KONTEKS-AI.md`, log dan acuan desain. AI perlu verifikasi bridge online, timestamp baru, WORKING yang benar, mode Edit dan source `synced_in_editor` sebelum mengubah game.
5. Gunakan **TERMINAL.cmd** untuk Git pada flashdisk. Terminal tersebut membawa PATH portable dan pengecualian `safe.directory` hanya untuk folder repo pada prosesitu. Tidak menambahkan trustglobal `*` atau menyimpan credential akun di flashdisk.

Untuk AI yang menjalankan Git/Node di setiap shelltool baru: dot-source `scripts/portable-runtime.ps1` dan jalankan perintah pada shell yang sama. Ini memilih runtimeportable sekaligus menangani FAT32. Alternatif Git ialah `git -c safe.directory=<root-clone-absolut>` untuk repoini saja; Node dapat dipanggil langsung dari `../tools/node/node.exe`. Launcher tidak mengubah environment aplikasiCodex yang sudah berjalan. Jangan mengubah konfigurasi keamanan global untuk menghilangkan errorownership.

Jika ada edit dari laptop/PC lain: pada repo bersih dan sebelum membuka place, jalankan `git pull --ff-only` dari terminalportable. Bila ada perubahanlokal, amankan dahulu; jangan reset/forcepush. Saat hanya satu folderflashdisk yang terus dipakai, tidak perlu clone ulang atau pull yang menimpa edit sendiri.

## Sebelum pulang atau pindah PC

1. **Stop Play → Save to File WORKING → tutup place di Studio**. Source editor tersinkron belum otomatis menjadi isi filebiner di disk.
2. AI wajib memperbarui `KONTEKS-AI.md`, `docs/LOG-PENGEMBANGAN.md` dan `LANJUTKAN.md`: perubahan, alasan, ujiaktual, bukti, bug dan targetsesiberikut. Pengguna tidak perlu merakitulang brief.
3. Klik **SELESAI.cmd**. Helper memeriksa source terkelola terhadap WORKING; bila berbeda, berhenti dan meminta SaveStudio. Ia tidak melakukan patch/buildbiner untuk memaksa cocok.
4. Jika verifikasi cocok, helper membuat cadangan WORKING. Ia memperlihatkan daftar perubahan untuk ditinjau, meminta pesancommit dan konfirmasi `YA`, lalu commit/push dan membandingkan HEADremote. `default.project.json` dikecualikan. Jika ada stagedchanges sebelumnya atau konteks/log belum diperbarui, selesaikan lewat terminal.
5. Berkasbaru yang dimasukkan otomatis terbatas pada area proyek/panduan yang didaftar helper. Periksa `git status`; berkas di luar scope perlu ditangani secara terarah. File yang masih berada di PC lokal/screenshot belum disalin ke flashdisk tidak dibawa otomatis.
6. Helper menghentikan hanya proses bridge yang PID, waktu mulai, executable dan identitasserver-nya cocok dengan clone ini. Jika tidak dapat dibuktikan, helper berhenti tanpa membunuh proses lain. Jangan menghentikan seluruh prosesNode.
7. Setelah push dan penghentianbridge berhasil, tutup Codex/Studio/terminal yang menggunakan flashdisk, logout akunPCumum dan pilih **Safely Remove/Eject** Windows. Jika pushgagal, cadangan tetap tersedia; status belum sinkron sampai diverifikasi.

Tidak ada pemformatan drive atau instalasi Studio/Codex otomatis. Bila PC memblokir eksekusi USB, plugin atau localhost, gunakan PC yang mengizinkan workflow ini. Jangan mengubah kebijakan PC untuk memaksa koneksi.

## Kondisi game saat paket ini disiapkan

Source audio terakhir berasal dari checkpoint `488d266`; keadaan sebelum Save pada catatan awal di bawah adalah riwayat, bukan statusterbaru. Pada checkpoint awal, WORKING terkomit masih hash57eb2… dan verifikasiSave menolak. **Pembaruan:** pengguna sudah mengecek dan Save; commitcea89a6 memuat WORKING hash2b590468c0754b23ac7a83a5c1cb427e4159214f9afb7346a0918fd541063029 yang cocok dengan source. Tugas Save awal sudah selesai, jangan diulang sebagai hambatanaktif. Guard tetap dipakai untuk perubahan sesiberikutnya; jangan mengganti place dengan buildlama.

Tidak ada perubahan gameplay dalam penyiapan portable ini. Tetap perlu Play desain/pause/tutup-buka/ulang/gating/evaluasi dan integrasi unlockLevel2. Pembacaan bridge/editor tidak menggantikan Play atau validasi ahli.

## Batas pengujian

Node portable `v22.23.4` Windowsx64 diambil dari distribusi resmi Node22, ZIP diverifikasi dengan SHASUMS256 lalu diuji memiliki ZSTD. Gitportable yang sudah ada:2.55.0.windows.3. Helper diuji parsePowerShell, CheckOnly, fixturecontroller HTTP dan startulang/stopPID tanpaStudio. Pengujian langsung dari flashdisk dicatat terpisah setelah penyalinan; PCwarnet kedua, login, izinplugin dan Play bukan hasilpengujian ini.

Hasil penyiapanD: repository/runtime tersalin, CheckOnly/packplugin/startulang/stopPID dariFAT32 lulus, roothealth cocok dan trustGitglobal tetap. UjiSELESAI denganpathberspasi/pesankutip sampaicommit/push diverifikasi memakai remotetiruan lokal. Laporan [PORTABLE-TESTS](docs/development/2026-10-29-PORTABLE-TESTS.json). Desain audio terbaru belumSave; guard pada SELESAI menolak kondisi itu sesuaiharapan. Tidak adaPlay otomatis atau bukti ujikeduaPC.

Sumber runtime: [distribusi resmi Node22](https://nodejs.org/dist/latest-v22.x/) dan [GitforWindowsportable](https://git-scm.com/install/windows). LisensiNode dan metadatahash berada pada `tools/node`. Foldertools tidak dikirim ke GitHub sebagai sourceproyek.
