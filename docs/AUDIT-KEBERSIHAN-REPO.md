**Dilaksanakan 1 November 2026 atas instruksi pengguna:** 712 file/23.118.211 byte dihapus dari tree aktif. Riwayat Git tetap menyimpan versi sebelumnya pada commit 43e16a1. Hasil dan tanggal helper: [laporan pembersihan](development/2026-11-01-CLEANUP.json). Tabel di bawah adalah snapshot audit sebelum penghapusan. portable-runtime/warnet-common tetap aktif; selesai-portable diganti nama selesai-sesi.

# Audit file dan kandidat pengarsipan — 1 November 2026

Permintaan: optimalkan repo untuk workflow clone lokal + bridge dan beri daftar file yang tidak lagi menjadi jalur aktif. **Saat audit awal belum ada penghapusan; pelaksanaan berikutnya tercatat di atas.** Tidak dipakai workflow sekarang berbeda dari aman dihapus permanen.

Dasar inventaris: tree Git `722b868`, 969 file tracked, 56.077.896 byte (56,08 MB desimal). Ukuran berdasarkan blob Git, bukan newline CRLF hasil checkout. Cache `local-rbxl/`, runtime portable di luar repo, dan ukuran riwayat `.git` tidak termasuk. File setup/dokumen yang ditambahkan sesi audit ini juga belum masuk hitungan dasar tersebut. Angka dan identitas blob dicatat di [inventaris](development/2026-11-01-REPO-INVENTORY.json).

## Kandidat dipisahkan dari checkout harian

| Prioritas | Path | Jumlah/ukuran dasar | Mengapa bukan jalur aktif | Syarat sebelum dipisahkan |
| --- | --- | --- | --- | --- |
| 1 | `src copy/` | 81 file; 20.800 byte | Arsip percobaan migrasi; tidak dipakai bridge/runtime aktif | Arsip berhash dahulu. Hanya60 dari81 file memiliki isi identik dengan suatu file di src; 21 lainnya tidak boleh diasumsikan duplikat. |
| 1 | `src/` | 512 file; 232.933 byte | Source ekspor Argon/Rojo lama, bukan studio-sync | Arsip bersama default.project.json; simpan keterlacakan baseline. Jangan menimpa WORKING dari source ini. |
| 2 | `migration-v2/` | 97 file; 4.581.308 byte | Kandidat migrasi Rojo yang belum menggantikan WORKING; aset binary lama | Arsip satu paket dengan konfigurasi/helper/hasil verifikasinya. Script inventaris lama juga menyebut path ini. |
| 2 | `default.project.json`, `migration-v2.syncback.project.json`, `rokit.toml` | 3 file kecil | Konfigurasi migrasi lama; Rojo/Argon tidak diperlukan setup aktif | Pisahkan bersama src/migration; jangan sekadar menghapus konfigurasi sambil meninggalkan panduan yang mengarahkan build. |
| 2 | `scripts/build-migration-v2.ps1`, `scripts/syncback-migration-v2.ps1` | 2 helper | Hanya untuk jalur Rojo lama | Arsip bersama paket migrasi; perbarui tautan/perintah yang merujuknya. |
| 2 | `scripts/inventaris-baca-saja.luau` | 1 helper | Inventaris historis berisi path migration-v2/src | Arsip atau sesuaikan dependensinya sebelum migration-v2 dipisahkan. Inventaris binary aktif rbxl-local/rbxl-prompt-hold tetap dibutuhkan. |
| 3 | `assets/audio-male.aup4` | 18.219.008 byte (18,22 MB) | Proyek authoring audio, tidak dibaca game/bridge saat runtime | Kandidat terbesar untuk arsip aset terpisah berhash. Tetap simpan agar audio bisa diedit/reproduksi; jangan menghapus satu-satunya master. |
| 3 | `MIGRASI_ROJO_STATUS.md`, `MIGRASI_ROJO_V2.md` | 2 dokumen | Riwayat migrasi, bukan instruksi setup baru | Boleh dipindah ke docs/arsip bersama paket migrasi setelah memperbaiki semua tautan. |
| 4 | `ALUR_SINKRONISASI.md`, `WARNET-CEPAT.md`, `PANDUAN-WARNET-3-JAM.md`, `PAKAI-FLASHDISK.md` | 4 panduan | Banyak petunjuk lama/duplikat; pintu utama kini KERJA-WARNET-LOKAL | Konsolidasikan bagian yang masih relevan, lalu arsipkan dengan banner riwayat. Jangan menjadikan targetlama integrasiL1 sebagai tugas ulang. |
| 4 | `MULAI-PORTABLE.cmd`, `TERMINAL-PORTABLE.cmd`, `SELESAI-PORTABLE.cmd` dan helper portable terkait | Launcher lama | Jalur USB tidak lagi menjadi cara kerja utama | Wrapper bisa diarsip setelah pengganti diuji. **portable-runtime.ps1 tetap dependensi aktif**, selesai-portable/cadangkan/stop masih dapat dipakai penutupan; jangan menghapus semuanya berdasarkan nama portable. |
| 4 | `scripts/mulai-warnet.ps1`, `scripts/selesai-warnet.ps1` | 2 helper lama | Mulai hanya pull/buka; selesai hanya mengurus WORKING, tidak seluruhsource/dokumen | Digantikan setup baru dan penutupan oleh AI yang mereview seluruhscope. Arsip setelah panduan lama diselaraskan. |
| 5 | `scripts/edit-papan-informasi-l1.luau`, `scripts/studio-fix-l1-kiosk.commandbar.luau` | Helper satu kali | Konstruksi/perbaikan objek terdahulu, bukan start sesi rutin | Periksa objek/properti hasilnya benar-benar SavedalamWORKING dan simpan bukti sebelum arsip; jangan menerapkan ulang otomatis. |

Tiga direktori source migrasi berjumlah **690 file (71,2% jumlah file dasar)** tetapi hanya **4.835.041 byte (4,84 MB)**. Memisahkannya terutama mengurangi kerumitan checkout, jumlah folder dan risiko path Windows terlalu panjang. Memisahkan master `.aup4` terutama mengurangi ukuran data aktif. Memindahkan semuanya ke folder arsip **di repo yang sama** merapikan tampilan, tetapi tidak mengurangi file/byte clone.

## Tetap diperlukan

| Path | Alasan |
| --- | --- |
| `places/RobloxLearningMedia-WORKING.rbxl` | Game utuh kanonis; source teks saja tidak memuat semua objek/aset. |
| `studio-sync/` | Source aktif, template/builder input, recorder, konfigurasi dan plugin. Jangan menghapus generatedsource yang dibaca bridge. |
| `scripts/setup-*`, `portable-runtime`, `start/stop/install/package-studio-bridge`, `studio-bridge`, `rbxl-local`, `rbxl-prompt-hold`, `verify-studio-save` | Rantai setup, penghubung dan pembuktian Save. |
| Builder, tes game/bridge/setup dan converter rekap | Menjaga isi penelitian, perilaku dan pengolahan catatan; ukurannya kecil. |
| `AGENTS.md`, `README.md`, `KERJA-WARNET-LOKAL.md`, `LANJUTKAN.md`, `KONTEKS-AI.md`, log | Pintu masuk AI nol konteks dan keterlacakan hasil. Riwayat panjang boleh dipisah dengan hati-hati, bukan dibuang. |
| `docs/desain/` | Snapshot storyboard, bank isi dan gambar untuk implementasi/penelitian. Besar sekitar24,7MB tetapi tetap acuan aktif, termasuk Level3 berikutnya. |
| `docs/development/` | Bukti sesi/verifikasi. Catatan lama bukan berarti hasil penelitian boleh dihapus. |
| MP3 di `assets/` | Sumber ekspor/reupload dan varian audio. Jangan menyimpulkan tak dipakai dari nama male/female saja; game memakai asset ID dan mapping perlu diperiksa. |

## Cache lokal dan riwayat Git

`local-rbxl/` sudah di-ignore Git sehingga tidak membebani clone. Isinya bukan semuanya sampah: dapat memuat source konflik, recovery, receipt Save, proses bridge, runtime dan compiler. Jangan hapus seluruhfolder tanpa memastikan semua pekerjaan tersimpan. Cache unduhan resmi yang sudah terpasang dan fixture tes dapat dibersihkan kemudian setelah proses terkait berhenti; provenance dan cadangan yang belum diamankan dipertahankan.

Menghapus file pada commit baru tidak menghapus blob dari riwayat `.git`. Untuk PC warnet yang hanya butuh versi terkini, clone dangkal (`git clone --depth 1 <remote-repo> <folder-lokal-pendek>`) dapat membatasi riwayat yang diunduh; riwayat lengkap tetap di GitHub dan bisa diambil jika diperlukan. Tidak ada rewrite history, force-push, atau perubahan Git LFS dalam audit ini.

## Urutan optimasi yang diusulkan

1. Buat arsip migrasi/master audio di lokasi cadangan yang sehat, dengan manifest path/hash dan commit acuan; uji salinan bisa dibaca.
2. Pisahkan paket migrasi beserta config/helper historis dari checkout aktif melalui perubahan terfokus; perbaiki referensi dan pertahankan penjelasan sumber arsip.
3. Konsolidasikan panduan lama ke satu pintu aktif. Sebagian sudah diberi penunjuk; README kini merujuk setup baru dan audit ini.
4. Jalankan tes setup/bridge serta verifikasi bahwa WORKING tidak berubah. Uji fresh clone dan bootstrap di PC warnet sebelum menyatakan optimasi operasional selesai.

Daftar ini mendokumentasikan audit awal. Sesudahnya pengguna secara eksplisit mengizinkan penghapusan paket lama, master AUP, launcher/panduan/helper lama; daftar tersebut telah dilaksanakan. WORKING, source aktif, MP3, rancangan dan bukti penelitian tetap utuh.
