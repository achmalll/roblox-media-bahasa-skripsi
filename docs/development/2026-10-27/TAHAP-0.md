# Tahap 0 dan setup pindah warnet — 27 Oktober 2026

Target aktif: demo progres game dan draf isi Bab IV untuk bimbingan 3 November. Development minggu ini; 2 November tetap untuk penulisan Bab IV. Sumber keputusan: CONTEXT, HANDOFF-DEVELOPMENT dan sprint aktif ROADMAP pada folder docs skripsi. Catatan ini membedakan pemeriksaan file, rancangan, dan hasil Play.

**Pembaruan penyimpanan 27 Oktober:** perubahan WORKING dan penghapusan model progress bar sudah masuk commit `e3360cb`. Panduan/helper dicatat pada commit pendamping. Laporan/JSON di bawah merupakan snapshot pemeriksaan sebelum commit, sehingga status Git lama dipertahankan sebagai riwayat. Untuk langkah operasional terbaru, buka [panduan warnet tiga jam](../../../PANDUAN-WARNET-3-JAM.md). Play lengkap dan koneksi MCP belum dinyatakan lulus.

## 1. Hasil pemeriksaan sesi ini

| Bagian | Hasil aktual |
| --- | --- |
| File kerja | `places/RobloxLearningMedia-WORKING.rbxl` dalam clone ini, 2.691.974 byte |
| SHA256 | `a4e910246c70993a0fb90cfb9e73150412664a88d14d79f25dc0626a380c9eef` |
| Commit awal sesi | `4fbc41bf33b06d6a93675b871f9c2322571cf4d2` |
| Perubahan game sebelum sesi | WORKING berubah; model `migration-v2/src/StarterGui/LevelProgressGui.rbxm` terhapus; keduanya belum commit/push |
| Konfigurasi | `default.project.json` berubah lokal milik pengguna; tidak diedit atau dimasukkan ke commit |
| Baseline pendahulu | `../RobloxLearningMedia-BACKUP.rbxl` tetap tersedia dan tidak diubah; hash `072bd774477dc20a50550caee6922b2e2729f2e3aa3a5dcbc1a4b4c42c01a25e`. Salinan tambahan identik dibuat pada `../session-backups/baseline-pendahulu/` |
| Batas versi A | Baseline pendahulu tersimpan. Belum mengklaim file ini sudah ditetapkan/dibekukan sebagai build eksperimen A final atau lulus Play. Jangan gunakan B terbaru untuk menimpanya |
| Sinkronisasi | `git ls-remote origin refs/heads/main` berhasil: GitHub main dan HEAD lokal sama-sama `4fbc41b`. Perubahan game masih di luar commit, sehingga GitHub belum berisi WORKING terbaru. Tidak pull/push sesi ini |
| Pembukaan Studio | Konfirmasi pengguna sebelumnya: bisa dibuka, panel percobaan hilang. Pembukaan dan Play baru sesi ini belum dilakukan |
| Pemeriksaan helper | Mulai/selesai `-CheckOnly` berhasil; tidak menarik atau mengirim file |
| Cadangan baru | ZIP WORKING + manifest berhasil dibuat, diekstrak, hash hasil ekstraksi cocok. Rincian di `hasil-setup.json`. Belum disalin ke flashdisk |

File WORKING dan baseline asli tidak diedit sesi ini. Cadangan menggunakan salinan byte, tanpa deserialize/serialize.

## 2. Alur kerja yang dipilih untuk malam ini

Gunakan **Git untuk versi antar-PC + flashdisk untuk salinan penyelamatan dan bukti sesi**. Kerjakan di folder lokal PC, lalu salin cadangan ke flashdisk setelah Save. Flashdisk tidak menjadi satu-satunya tempat menyimpan hasil. Tidak perlu menambah Rojo/Argon atau migrasi baru untuk alur ini.

PC tujuan memerlukan Studio, Git (PortableGit yang tersedia juga bisa dipakai), internet dan akses akun repository. Studio tetap perlu tersedia pada setiap PC; membawa project/PortableGit bukan membawa instalasi Studio. Gunakan satu PC untuk mengedit pada satu waktu.

### Sebelum pindah dari laptop malam ini

1. Stop bila sedang Play, Save to File ke WORKING dalam clone, lalu tutup place sebelum pull atau pergantian versi di disk.
2. Cadangkan file tersimpan:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\cadangkan-sesi.ps1
   ```

   Default tujuan `../session-backups/`, di luar clone. Salin ZIP dan `.sha256` ke flashdisk pribadi. ZIP ini berisi WORKING dan manifest; source, konfigurasi lokal, riwayat Git dan gambar tidak disertakan. Untuk tujuan flashdisk langsung, ganti contoh drive yang benar:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\cadangkan-sesi.ps1 -DestinationDirectory 'E:\Roblox-Skripsi\cadangan'
   ```

3. Selesaikan pemeriksaan Studio pada bagian 4. Periksa `git diff --cached --name-only` sebelum commit agar tidak mencampur file lain.
4. Perubahan penghapusan GUI perlu commit terfokus yang memasukkan **WORKING dan model yang dihapus**. Helper selesai lama hanya men-stage WORKING. Perintah berikut adalah langkah manual setelah hasil pemeriksaan diterima, **belum dijalankan sesi ini**:

   ```powershell
   git add -- places/RobloxLearningMedia-WORKING.rbxl migration-v2/src/StarterGui/LevelProgressGui.rbxm
   git diff --cached --name-status
   git commit -m "Hapus panel progres percobaan dari place dan sumber migrasi"
   git push
   ```

   Jangan `git add .`; `default.project.json` tetap dipertahankan lokal. Script cadangan dan catatan setup yang baru juga perlu commit tersendiri bila ingin tersedia dari clone PC berikutnya.
5. Pastikan push berhasil sebelum menganggap PC berikutnya memperoleh versi baru. Jika gagal, bawa cadangan dan pertahankan clone/commit yang belum terkirim. Jangan reset, force-push, atau menimpa binary untuk mengejar sinkronisasi.

### Di warnet

1. Clone pertama sesuai `WARNET-CEPAT.md`; gunakan folder clone yang ada bila tersedia. Contoh folder lokal boleh `D:\Kerja\roblox-media-bahasa-skripsi`, sesuaikan drive PC. Jangan membuka arsip bernama sama di luar clone.
2. Jika clone bersih dan sesi sebelumnya sudah dikirim, jalankan dari root:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\mulai-warnet.ps1
   ```

3. Cocokkan hash WORKING dengan hasil akhir sesi sebelumnya, lalu Studio → Open from File → path yang dicetak helper. Hash yang berubah setelah edit wajar; bandingkan dengan snapshot terakhir yang benar-benar tersimpan.
4. Edit/Play, Stop, Save to File. Jalankan helper selesai untuk sesi yang hanya mengubah WORKING, lalu cadangkan:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\selesai-warnet.ps1 -Message "Level 1: penempatan papan informasi"
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\cadangkan-sesi.ps1
   ```

5. Simpan gambar dan catatan hasil uji di log sesi. Bukti di luar WORKING tidak dikirim otomatis oleh helper. Salin bukti beserta ZIP ke media pribadi, lalu keluar dari akun pada PC umum.

Jika internet gagal dan hanya ZIP terbaru yang dibawa: ekstrak ke folder pemulihan terpisah, periksa hash, buka file itu untuk penyelamatan. Jangan menyebut clone sudah sinkron atau menimpa WORKING clone yang berbeda secara otomatis. Bandingkan versi sebelum memasukkan hasil ke clone dan mengirimnya kembali. Untuk mempertahankan commit lokal yang belum terkirim, cadangan WORKING saja tidak cukup.

## 3. Peta kode dan batas alat

Proyek berupa satu place Roblox: map/NPC/GUI di RBXL, Luau client mengelola panel dan interaksi, server menyimpan skor/progres. `migration-v2/src` menjadi referensi source; script yang disiapkan di sana belum otomatis terpasang pada WORKING. File konfigurasi lama tidak dipakai untuk build menimpa place.

Alur existing Level 1 yang ditelusuri dan cocok dengan script dalam WORKING:

`Workspace.Space1Answers.ProximityPrompt` → `Level1Handler` → `StarterGui.Level1Gui.space1IntroFrame` → `audioChoose` → `audioPlayerMale/Female.NarationSound` → `quizFrame` → `Level1QuizHandler` → event progres/skor → handler server.

Papan panduan existing: `Workspace.Halaman depan.papanInformasi`, prompt pada `Animation 2.ProximityPrompt`, dikendalikan `FlowController`. Ini **papan panduan global**, berbeda dari papan informasi baru setelah Tutor 1. Jangan mengganti nama/memindahkan objek lama agar nama baru terlihat cocok.

Inventaris parsial di `inventaris.json` menemukan SpawnLocation, dua Sound narasi pada Level1Gui, panel intro/audio/kuis, serta prompt existing. ID Sound tidak dapat dibaca lewat properti yang dicoba alat; itu **bukan bukti ID kosong**. Periksa properti audio/aset di Studio. Belum membuktikan tiga klip rancangan sudah tersedia. Tidak membuat audio baru.

Lune 0.11.1 masih memperingatkan `Terrain.VoxelGridAssetContentMap` tipe 0x23. Audit hanya deserialize/baca; tidak menyimpan ulang place. Parser lama gagal pada ZSTD menurut handoff. Studio menjadi alat penyimpanan place untuk sesi ini. Audit opsional dapat diulang dengan `lune run scripts/inventaris-baca-saja.luau` dari root, dengan dukungan properti yang terbatas; Lune tidak wajib untuk PC warnet.

Temuan server: assignment `progress.Value = newLevel` mendahului pembandingan kenaikan, dan validasi klien belum memadai. Kuis existing mengirim progres sebelum skor. Perbaikan harus menelusuri kontrak kedua event, bukan menambah syarat skor secara sepihak. Belum diperbaiki sesi ini; harus ditangani sebelum menyatakan akses versi B andal.

## 4. Play baseline yang perlu dilakukan pengguna

Buka WORKING di clone. Tampilkan Explorer, Properties dan Output melalui kontrol Studio yang tersedia. Catat error lengkap beserta saat terjadinya. Gunakan sesi baru untuk tes akses awal agar status kelulusan tes sebelumnya tidak mencemari hasil.

| ID | Tindakan di Studio/Play | Hasil yang diharapkan | Hasil aktual sesi ini |
| --- | --- | --- | --- |
| P00 | Open from File ke WORKING; periksa error pembukaan | Map terbuka tanpa Invalid id; panel progres percobaan tidak ada | Belum diuji ulang; konfirmasi sebelumnya terbatas pembukaan/panel |
| P01 | Play; tutup sambutan; berjalan dari spawn ke papan panduan | Spawn/map terlihat, kontrol kembali aktif, panduan bisa dibuka dan ditutup | Belum diuji |
| P02 | Dekati interaksi Level1 existing; putar, jeda dan lanjutkan masing-masing pilihan audio | Suara termuat, tidak tumpang tindih, indikator bergerak; pesan izin/pemuatan dicatat bila gagal | Belum diuji |
| P03 | Periksa dua NarationSound di Explorer/Properties; dengarkan isinya | Catat ID aset, durasi runtime, naskah yang terdengar, kemungkinan batas tiga klip; belum mengubah stimulus | Belum diuji |
| P04 | Kerjakan kuis dengan 2/4 benar, lalu retry | Hasil 50, belum lulus; retry kembali ke materi tanpa panel/gerak tersangkut | Belum diuji |
| P05 | Pada percobaan berikutnya 3/4 benar; cek hasil dan Level2 | Hasil 75 dan akses Level2 terbuka; catat nilai PlayerScores/leaderstats dari konteks server | Belum diuji |
| P06 | Pada sesi baru, coba Level2/3/aula sebelum lulus; lanjutkan lulus tiap level | Urutan akses sesuai hasil; kelulusan tidak membuka akses seluruh pemain | Belum diuji |
| P07 | Buka materi Level2/3; cek bacaan, kuis dan skor masing-masing | Isi tampil dan hasil 25 per benar, maksimum100, lulus75; catat perbedaan baseline dari rancangan B | Belum diuji |
| P08 | Stop, Save to File, buka ulang | Hasil edit mode edit tersimpan; screenshot Play saja bukan bukti penyimpanan | Belum diuji |

Simpan minimal gambar spawn/area Level1, panel audio, hasil 50/75 dan Output bila ada error. Belum ada screenshot Studio baru sesi ini. File uji JSON adalah bukti pemeriksaan setup, bukan gambar/gameplay. Masalah pembukaan/spawn/audio wajib diselesaikan sebelum membangun rangkaian baru yang bergantung padanya.

## 5. Satu pekerjaan Level 1 pertama

**Setelah baseline pokok dicek: tempatkan satu papan informasi setelah Tutor 1**, mengikuti denah aktif 00. Ini bagian pertama penempatan objek Tahap1; belum panel/materi baru.

- Alasan: memberi satu titik nyata pada rute Tutor1 → papan informasi → Tutor2 tanpa mengubah audio, kunci atau skor.
- Yang sudah disiapkan asisten: inventaris objek existing, cadangan, langkah kerja dan kriteria uji. Tidak mengedit binary dengan alat yang belum kompatibel.
- Di Studio mode edit, buat Folder di Workspace bernama `Level1Development`. Tambahkan satu Part bernama `L1_PapanInformasi`. Aktifkan `Anchored`, gunakan bentuk papan sederhana, tempatkan dengan Move/Rotate di tepi rute antara Tutor1 dan Tutor2 menurut denah 00. Cocokkan skala dengan karakter; koordinat akhir ditentukan di map. Jangan pindahkan dua tutor lama yang berdampingan depan air mancur.
- Bedakan dengan `Halaman depan.papanInformasi` existing. Jangan menghapus atau menggandakan prompt/script lama ke objek baru. Panel dan penguatan informasi menyusul pada pekerjaan berikutnya.
- Play: berjalan dari Tutor1 mendekati papan lalu ke Tutor2. Hasil yang diharapkan: papan stabil dan terlihat, jalan tetap lapang, karakter tidak tersangkut, interaksi tutor lama tetap berjalan. Ambil gambar area dari pemain dan tampak umum.
- Stop → Save to File → buka ulang untuk memastikan papan tetap ada. Catat lokasi aktual dan nama objek, hash baru, hasil Play, commit/push. Sampai tindakan ini dilakukan, statusnya **instruksi siap, belum terpasang**.

## 6. Penutupan sesi dan bahan skripsi

Hasil sesi ini: script `cadangkan-sesi.ps1`, audit `inventaris-baca-saja.luau`, catatan tahap0, JSON inventaris dan hasil pemeriksaan setup; semuanya lokal, belum commit/push. Hash WORKING tetap a4e910… dan konfigurasi milik pengguna tidak diubah. Cadangan baseline identik tersedia di luar clone.

Untuk BabIV: keputusan satu sumber kerja, asal baseline dan rute objek tetap dicatat sebagai rancangan/keputusan kerja. Untuk BabV: hasil pemasangan, gambar gameplay, uji dan bug hanya ditulis setelah pelaksanaan aktual. Tidak mengisi hasil Play yang belum ada. Target berikutnya: Play baseline → satu papan terpasang dan jalur lolos → panel/interaksi → pembagian klip sesuai aset → latihan dan evaluasi dua tingkat.

Template catatan setiap sesi:

```text
Tanggal/PC dan file yang dibuka:
Keputusan rancangan + alasan + acuan storyboard (Bab IV):
Perubahan disiapkan di source / terpasang di WORKING:
Langkah Play → hasil aktual → bug (Bab V):
Nama berkas gambar dan lokasinya:
SHA256 / commit:
Push berhasil/belum; cadangan dibawa/belum:
Pekerjaan tersisa dan langkah berikutnya:
```
