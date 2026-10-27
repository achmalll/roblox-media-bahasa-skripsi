# Masuk warnet dari nol: Studio + AI + proyek, sesi 3 jam

Disiapkan 27 Oktober 2026 untuk sprint menuju bimbingan 3 November. Target setup 30 menit, batas maksimum 60 menit. Durasi bergantung unduhan, izin instalasi, dan login PC; bukan janji setup otomatis selesai. Senin 2 November tetap untuk Bab IV.

**Pilihan malam ini: Roblox Studio + Codex yang biasa dipakai + Git, dengan flashdisk sebagai cadangan.** Pakai satu aplikasi AI dahulu. VS Code, Claude, OpenCode, Script Sync, Rojo dan plugin MCP tambahan tidak masuk daftar instalasi wajib sesi ini. Ini pembatasan cakupan supaya waktu tersisa untuk game.

## 1. Sebelum berangkat: bawa versi yang benar

- Bawa ZIP kit sesi, cadangan WORKING terbaru beserta hash, gambar acuan denah/05A/05B dan catatan ini di flashdisk. Kit berisi snapshot tersimpan; hasil edit berikutnya memerlukan cadangan baru.
- WORKING sumber ada di `places/RobloxLearningMedia-WORKING.rbxl` dalam clone. Snapshot awal: SHA256 `a4e910246c70993a0fb90cfb9e73150412664a88d14d79f25dc0626a380c9eef` (2.691.974 byte). Jangan membuka WORKING arsip di folder induk.
- Pembaruan 27 Oktober: WORKING terbaru dan penghapusan model GUI sudah dicatat pada commit **`e3360cb`**. Panduan serta helper disertakan dalam commit pendamping. Gunakan clone/pull yang memuat commit game ini, lalu cocokkan hash. Catatan yang menyebut perubahan belum commit pada laporan audit awal adalah riwayat sebelum penyimpanan ini.
- Jalur utama: Stop/Save di laptop → pastikan push terakhir berhasil → pada clone bersih PC warnet jalankan helper mulai → buka WORKING. Jangan sertakan `default.project.json` lokal lama milik pengguna saat menyimpan perubahan game.
- Jika hasil edit sesi mendatang belum sempat di-push, gunakan prosedur snapshot pada bagian 3 dengan cadangan terbaru. Jangan pull dahulu di atas snapshot yang sudah dimasukkan ke clone.
- Simpan baseline pendahulu/A terpisah. File itu bukan tempat edit. Bawa akses akun dan cara 2FA yang biasa digunakan; file login/token tidak dimasukkan ke kit.

## 2. Menit 0–15: aplikasi dan login

1. Pilih folder kerja lokal yang diizinkan PC, misalnya `D:\Kerja`. Bila drive itu tidak ada, pilih folder lain. Pastikan hasil tidak hilang sebelum sesi selesai karena reset/deep-freeze.
2. Cek Start Menu: Roblox Studio, aplikasi Codex/desktop AI yang biasa dipakai, dan Git. Buka PowerShell, jalankan `git --version`. Jika Git tidak dikenali, gunakan installer/PortableGit yang dibawa. PortableGit cukup untuk Git, bukan pengganti Studio.
3. Pasang Studio dari [halaman resmi Roblox](https://create.roblox.com/docs/studio/setup). Buka dan login akun Roblox. Jika akses instalasi diblokir, minta operator menyediakan Studio atau gunakan PC lain yang mendukung; ini penghambat utama.
4. Buka aplikasi Codex/desktop yang biasa digunakan dan login. Gunakan instalasi dari kanal resmi aplikasi; lihat [panduan aplikasi OpenAI](https://learn.chatgpt.com/docs/app). Tidak perlu menyiapkan API key hanya untuk mengikuti alur login aplikasi yang sudah kamu gunakan.
5. Login GitHub saat clone/push meminta autentikasi. Jangan menempelkan password/token ke chat atau perintah. Git resmi tersedia sebagai installer maupun PortableGit pada [halaman Windows](https://git-scm.com/install/windows).

Jika memakai PortableGit, salin ke `D:\Kerja\tools\PortableGit`, lalu tambahkan hanya untuk PowerShell saat ini:

```powershell
$env:Path = 'D:\Kerja\tools\PortableGit\cmd;' + $env:Path
git --version
```

Sesuaikan folder di perintah dengan lokasi nyata. Tidak perlu mengubah PATH seluruh komputer.

## 3. Menit 10–20: clone dan buka WORKING

Clone lewat URL repository yang sudah tersedia pada GitHub milikmu/panduan `WARNET-CEPAT.md`, lalu masuk ke folder `roblox-media-bahasa-skripsi`. Bila folder clone sudah ada, periksa `git status --short --branch` sebelum melakukan apa pun.

### Jika perubahan laptop sudah di-push

Jalankan helper mulai dari root clone yang berisi `places`, `scripts` dan `README.md`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\mulai-warnet.ps1
```

Cocokkan hash dengan akhir sesi laptop. Baru buka Studio → Open from File → WORKING pada path hasil helper.

### Jika GitHub masih versi lama dan kamu membawa kit snapshot

Gunakan cabang ini hanya pada **clone baru yang bersih**, sebelum membuka place di Studio:

1. Clone dari GitHub terlebih dahulu, lalu periksa `git status --short`; hasil harus kosong. Jika ada edit lain, berhenti dan bandingkan versi.
2. Ekstrak `cadangan-WORKING.zip` dari kit ke folder terpisah. Baca `manifest.json`, cocokkan hash file hasil ekstraksi:

   ```powershell
   Get-FileHash 'PATH-HASIL-EKSTRAKSI\RobloxLearningMedia-WORKING.rbxl' -Algorithm SHA256
   ```

3. Pastikan snapshot kit memang hasil terakhir dari laptop. Jika laptop sudah diedit setelah kit dibuat, ambil cadangan terbaru dahulu.
4. Tutup place Studio. Salin WORKING hasil ekstraksi ke `places/RobloxLearningMedia-WORKING.rbxl` dalam clone bersih tersebut. Terapkan penghapusan model GUI lama yang tercatat: pada Explorer Windows hapus hanya `migration-v2/src/StarterGui/LevelProgressGui.rbxm` bila masih ada.
5. Jangan menyalin `default.project.json` lama milik laptop atau mengganti konfigurasi clone. Snapshot ini bukan paket migrasi/build.
6. Salin script dalam folder `scripts` kit ke folder `scripts` clone. Helper umum/mulai/selesai di kit berasal dari repository; tambahan baru adalah pemeriksaan PC dan cadangan. Salin panduan ini ke root clone jika belum tersedia di GitHub.
7. `git status --short` sekarang semestinya menunjukkan WORKING berubah, model GUI terhapus, dan mungkin script/panduan baru. **Jangan jalankan pull setelah ini sebelum perubahan tersebut diamankan.**
8. Buka WORKING dalam clone di Studio. Commit awal nanti mencakup WORKING dan penghapusan model. Jika remote telah berubah, bandingkan sebelum push; jangan force-push.

Satu perintah untuk memeriksa keadaan PC setelah script baru tersedia:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\cek-warnet.ps1
```

Script ini membaca keberadaan Git, Studio, launcher MCP, konfigurasi server dan hash WORKING. Tidak menginstall, login, pull, atau menulis config. `False` untuk CLI tidak berarti aplikasi desktop tidak ada. Instalasi Studio di luar folder standar mungkin tidak terdeteksi.

## 4. Menit 20–30: sambungkan Codex ke Studio

MCP bawaan Studio menghubungkan aplikasi AI dengan sesi Studio lokal. AI bisa membaca dan mengubah isi place melalui tools yang disediakan. Aktifkan melalui Assistant → ⋯ → Manage MCP Servers → **Enable Studio as MCP server**, lalu pilih klien yang tersedia pada Quick connect. Indikator hijau menandakan klien tersambung. [Dokumentasi Roblox](https://create.roblox.com/docs/studio/mcp)

### Jalur utama: Quick connect

1. Buka WORKING yang benar, cukup satu instance Studio untuk sesi awal ini.
2. Aktifkan server pada menu di atas. Pada beberapa versi, pengaturan muncul sebagai Assistant → ⋯ → Settings → MCP Servers.
3. Pilih Codex/Codex CLI atau ChatGPT (codex) bila tercantum. Ikuti nama yang benar-benar muncul di PC; jangan menganggap semua versi menu identik.
4. Restart aplikasi AI bila tools belum muncul. Jika diminta memulai chat baru, gunakan prompt serah-terima pada bagian 6 agar konteks kerja terbawa.

### Jika Quick connect tidak tersedia: satu fallback konfigurasi

Periksa dulu `codex mcp list` bila perintah Codex tersedia. Hindari entri duplikat `Roblox_Studio`. Periksa launcher:

```powershell
Test-Path "$env:LOCALAPPDATA\Roblox\mcp.bat"
```

Jika `False`, kembali ke Studio dan aktifkan MCP/update Studio. Jangan membuat batch tiruan. Jika launcher ada dan server belum terdaftar, jalankan di PowerShell:

```powershell
codex mcp add Roblox_Studio '--' cmd.exe /c 'cd /d %LOCALAPPDATA%\Roblox && .\mcp.bat'
codex mcp list
```

Perintah Windows dan penggunaan working directory di atas mengikuti [panduan koneksi resmi repository Roblox](https://github.com/Roblox/roblox-studio-agent-plugin/blob/main/skills/roblox-get-started/references/connect.md). Restart klien setelah pendaftaran bila tools belum termuat.

Jika CLI tidak tersedia, gunakan pengaturan MCP aplikasi, tipe STDIO, server `Roblox_Studio`, command `cmd.exe`, dengan dua argumen `/c` dan `cd /d %LOCALAPPDATA%\Roblox && .\mcp.bat`. Bila UI versi aplikasi berbeda, gunakan editor konfigurasi MCP yang memang disediakan aplikasi. Tambahkan satu entri; jangan menimpa konfigurasi lain.

Codex menyimpan server pada tabel `[mcp_servers.<nama>]` di konfigurasi pengguna. JSON milik Claude tidak bisa langsung menggantikan TOML Codex. Konfigurasi Codex dipakai bersama oleh klien yang mendukungnya; lihat [dokumentasi MCP OpenAI](https://learn.chatgpt.com/docs/extend/mcp?surface=cli). Tidak perlu menyalin seluruh folder konfigurasi/kredensial laptop ke PC umum.

### Verifikasi nyata, bukan hanya toggle ON

Kirim prompt ini pada AI yang berjalan di PC yang sama:

> Gunakan tools MCP Roblox untuk membaca sesi Studio yang terbuka. Sebutkan instance Studio/place yang dipilih, daftar anak langsung Workspace, keberadaan StarterGui.Level1Gui, dan lokasi SpawnLocation. Jangan mengubah objek, menjalankan script game, mulai Play, atau menyimpan file. Jika tools belum tersedia, katakan belum terhubung.

Selesai bila ada hasil tool nyata yang cocok dengan map WORKING; bukan sekadar jawaban AI “connected”. Jika ada lebih dari satu Studio, pilih instance yang benar sebelum mutasi.

**Batas waktu:** pada menit30 evaluasi. Jika proyek dan Studio siap, lanjut kerja; MCP boleh diberi tambahan maksimal10–15menit sambil menyiapkan baseline. Menit60 adalah batas setup total. Jika MCP tetap gagal, pakai Studio manual dan bantuan chat untuk kode/instruksi. Jangan menghabiskan sisa sesi mencoba empat aplikasi AI.

## 5. Koreksi terhadap panduan tempelan

- Gagasan MCP dan AI langsung ke Studio benar dan didukung dokumentasi resmi. Kita memakai server bawaan yang tersedia pada Studio.
- Publish experience baru dan Allow Studio access to API Services **tidak tercantum sebagai prasyarat pada panduan MCP resmi**. Karena itu keduanya tidak diaktifkan hanya untuk mencoba koneksi. Kebutuhan akses layanan lain dibahas ketika fitur nyata memerlukannya.
- “Select All lalu paste config” berisiko mengganti entri yang sudah ada. Tambahkan satu server sesuai format klien.
- Klaim OpenCode gratis/unlimited belum diverifikasi; bukan dasar memilih setup malam ini. Tidak perlu membuat akun AI tambahan.
- Plugin pihak ketiga yang disebut pada tempelan tidak dijadikan syarat. Lampiran tidak memberikan tautan rilis yang cukup untuk memverifikasi asalnya; label “resmi” tidak diambil sebagai fakta.
- Script Sync adalah workflow tambahan. Sesi ini tetap Studio + WORKING; belum mengaktifkan sync pada source migration/arsip yang mungkin tidak mewakili place terbaru.
- Sambungan/login biasanya harus diulang pada PC baru atau PC yang direset. Kit mempercepat persiapan; tidak otomatis membawa sesi login atau menjamin satu klik selesai.

## 6. Pekerjaan malam ini dalam 180 menit

| Menit sejak mulai | Kerja | Keluaran |
| --- | --- | --- |
| 00–30 | Aplikasi/login, file terbaru, MCP | WORKING benar dibuka; AI terbukti membaca Studio, atau jalur manual dipilih |
| 30–55 | Play baseline singkat | Spawn/gerak, sambutan, panduan, audio Level1 dan Output diperiksa; hasil aktual dicatat |
| 55–100 | Objek Level1 | Satu papan informasi terpasang dan rute Tutor1–papan–Tutor2 lolos jalan. Jika aman, tempatkan papan latihan/kios sebagai placeholder |
| 100–135 | Inventaris audio dan persiapan interaksi | Catat aset, durasi runtime dan kecocokan isi dengan tiga bagian rancangan. Jika semuanya jelas, mulai satu interaksi papan; jangan menebak batas klip |
| 135–150 | Uji dan gambar | Uji ulang jalur, objek statis, kontrol/panel yang diubah; ambil 2–3 gambar dan catat bug |
| 150–180 | Penutupan wajib | Stop/Save, hash, commit/push, cadangan flashdisk, bukti dan logout |

Jika setup memakai60menit: 60–85baseline,85–120satu papan,120–145uji/gambar/inventaris audio seperlunya,145–180penyimpanan. Kurangi tambahan objek dan panel. Waktu pulang tidak digunakan untuk fitur baru.

Target minimum yang realistis: **proyek bisa dibuka pada PC baru, alur penyimpanan jelas, baseline diperiksa, satu papan informasi benar-benar terpasang dan jalur diuji**. Satu Level1 lengkap tetap target sprint, bukan janji sesi setup pertama.

Prompt serah-terima untuk AI di PC warnet:

> Saya melanjutkan skripsi Roblox menuju bimbingan3November; 2November fokusBabIV. Baca PANDUAN-WARNET-3-JAM.md dan konteks/handoff pada kit. File utama places/RobloxLearningMedia-WORKING.rbxl. Pertahankan snapshot terbaru dan baselineA; jangan build migration menimpa place. Mulai dari verifikasi sesiStudio dan inventaris baca-saja. Setelah baseline dicek, kerjakan satu papan informasi Level1 menurut denah00/05A–05B, lalu uji jalur. Dua tutor tetap berdampingan depan air mancur. Materi, skor25/0,maks100,lulus75 tidak diubah; tier2 terpisah. Jangan menambahkan DataStore atau membuat audio baru. Bedakan source disiapkan, terpasang diWORKING dan sudahPlay. Simpan gambar/log untukBabIV/V. Hentikan fitur baru pada menit150 dan bantu Save/commit/push/cadangan.

Detail pekerjaan pertama: buat Folder `Level1Development` di Workspace, Part `L1_PapanInformasi`, Anchored aktif. Letakkan di tepi rute dekatTutor1 sesuai denah, bukan menutup jalur atau memindah duaTutor. Bedakan dari papan panduan existing `Halaman depan.papanInformasi`.

Panel opsional memakai isi05B yang sudah disepakati: “Kenali sistem operasi”; “Sistem operasi adalah perangkat lunak.”; “Mengelola sumber daya komputer: Prosesor • Memori • Penyimpanan • Perangkat input dan output”; “Selanjutnya, temui Tutor2.” Akses final mensyaratkan audio1 selesai. Jika status tiga klip belum diimplementasikan, catat panel sebagai prototipe belum terintegrasi dan jangan berpura-pura syarat tersebut sudah bekerja. Uji tutup/buka serta pengembalian gerak.

## 7. Menutup sesi: mulai sebelum paket waktu habis

1. Stop Play → Save to File pada WORKING dalam clone → tutup place sebelum mengganti file di disk.
2. Jika sesi hanya mengubah WORKING dan commit awal penghapusanGUI sudah aman, gunakan helper:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\selesai-warnet.ps1 -Message "Level 1: penempatan papan informasi dan uji rute"
   ```

3. Jika penghapusan model masih belum masuk commit, gunakan langkah commit terfokus pada TAHAP-0.md. Jangan stage konfigurasi milik pengguna. Script/panduan/bukti baru memerlukan commit tersendiri; helper tidak mengirimkannya otomatis.
4. Buat cadangan, lalu salin hasil dan gambar ke flashdisk:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\cadangkan-sesi.ps1
   git log -1 --oneline
   ```

5. Pastikan push berhasil, WORKING tidak berubah lagi, dan ZIP/gambar benar-benar dapat dibuka pada flashdisk. Jika push gagal, catat belum sinkron; pertahankan clone bila ada commit yang belum terkirim. ZIPWORKING bukan cadangan seluruh riwayatGit.
6. Catat: apa berubah, lokasi objek, Play/hasilaktual, bug, nama gambar, hash/commit dan statuspush. Jangan menulis uji lulus dari screenshot rancangan. Logout Roblox, aplikasiAI, GitHub browser dan akunGit yang disimpan di PC umum sesudah hasil aman.

Status saat panduan dibuat: koneksiMCP **belum diuji pada PCwarnet**, WORKING tidak diedit, belum ada Play/screenshotStudio baru. Scriptcek hanya pemeriksaanlokal. Jangan menyebut setupAI selesai sampai permintaanbaca Studio berhasil.
