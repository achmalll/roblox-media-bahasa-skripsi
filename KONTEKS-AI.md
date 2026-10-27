# Brief konteks untuk AI — skripsi dan media Roblox

Snapshot: **27 Oktober 2026**. Brief ini disiapkan agar chat baru bisa membantu diskusi, menyusun rencana, memahami progres atau melanjutkan pekerjaan tanpa mengulang penjelasan dari nol. Ini ringkasan operasional; bukan naskah skripsi, hasil penelitian atau bukti fitur selesai.

## 1. Siapa dan apa yang sedang dikerjakan

Pengguna adalah Achmal, mahasiswa yang mengembangkan media pembelajaran bahasa dalam Roblox sebagai bagian skripsi. Produk melanjutkan media penelitian pendahulu Alif Nur Sanubari. Fokus keterampilan: menyimak, membaca dan membaca lanjutan melalui materi konteks Teknologi Informasi; jangan menggesernya menjadi hafalan istilah TI.

Tahap aktif ialah skripsi P1, melanjutkan P0 yang sudah dikumpulkan. Pekerjaan akademik mencakup penyelarasan Bab I–III, perancangan Bab IV, kemudian dokumentasi pengembangan/pengujian Bab V sesuai outline kerja. Model pengembangan yang digunakan ialah 4D. Baseline A dipertahankan sebagai pembanding versi pengembangan B. Jangan mengarang judul penelitian lengkap, data, jumlah peserta, jadwal ahli atau hasil statistik.

## 2. Cara membantu dalam chat ini

**Ikuti tujuan pesan terbaru.** Jika pengguna hanya ingin brief, berdiskusi, bertanya pendapat, mengatur waktu atau menyiapkan bimbingan, jawab kebutuhan itu terlebih dahulu. Tidak perlu otomatis menulis kode, mengedit RBXL atau menyalakan Studio.

- Jelaskan posisi sekarang, pilihan yang relevan dan satu langkah berikutnya secara konkret.
- Bedakan fakta terverifikasi, laporan pengguna, rencana dan pendapat AI.
- Jangan meminta pengguna mengulang informasi yang sudah ada dalam brief/file yang benar-benar bisa dibaca.
- Untuk pekerjaan teknis, jelaskan bagian yang dikerjakan, yang bisa dilakukan AI, langkah Studio pengguna, cara uji, hasil aktual dan sisa pekerjaan.
- Gunakan Bahasa Indonesia yang jelas. Keputusan rancangan yang sudah disepakati dipertahankan kecuali ada masalah konkret.

## 3. Target dan prioritas terkini

Bimbingan berikutnya **Selasa, 3 November 2026**: membawa draf isi Bab IV Perancangan dan progres game yang benar-benar dapat ditunjukkan. Minggu 27 Oktober–1 November dominan development, dengan catatan/gambar setiap sesi. **Senin, 2 November, tetap untuk menyusun Bab IV**, walaupun implementasi belum seluruhnya selesai.

Urutan kerja: tahap0 sumber kerja/baseline → satu Level 1 utuh → pakai ulang komponen Level 2/3 → integrasi/uji. Jika Level 1 terlambat, tuntaskan dahulu. Foto, bonus, dekorasi dan penyempurnaan aula menyusul. Tiga level selesai merupakan target upaya, bukan janji hasil atau syarat yang dikarang atas nama dosen.

Rencana sesi warnet pertama tiga jam: setup diupayakan30 menit, maksimum60; kemudian baseline dan satu papan informasi Level 1/rute pemain. Sisakan30 menit terakhir untuk Save, commit/push, cadangan, gambar/log dan logout. Jika MCP gagal, lanjut lewat Studio manual agar waktu tidak habis untuk setup.

## 4. Keputusan desain yang sudah disepakati

- **Level 1:** papan pemandu → Tutor 1/audio 1 → papan informasi → Tutor 2/audio 2 lalu audio 3 → papan latihan → kios evaluasi → hasil → ulang atau Level 2. Dua tutor berdampingan di depan air mancur, Tutor 1 kiri/Tutor 2 kanan dari arah masuk. Tiga klip terpisah, masing-masing indikator0–100%; jangan menggantinya dengan satu audio panjang. Aset/batas bagian nyata masih perlu diperiksa.
- **Level 2:** bacaan berita Cloud AI Pad dalam tiga bagian; latihan memilih bukti dan memasangkan simpulan dengan bukti. Objek lama di kiri gedung, tambahan di kanan, jalur tengah bebas.
- **Level 3:** abstrak ilmiah dalam tiga bagian; latihan fungsi gagasan dan editor simpulan empat ronde. Objek lama di kanan, tambahan di kiri. Tidak mengganti tugas menjadi mengetik bebas atau hafalan.
- **Evaluasi:** empat soal per level; tier 1 → tier 2 alasan → feedback → hasil. Tier1 benar 25/salah 0, maksimal 100, lulus 75. Tier2 dicatat terpisah 0–4, tidak membatalkan kelulusan tier 1. Latihan tidak menambah skor.
- **Akses:** Level 1 tersedia awal; lulus L1 membuka L2, lulus L2 membuka L3, lulus L3 membuka aula. Status per pemain, tidak turun ketika mengulang. Perlu pemeriksaan server yang sah.
- **Aula:** ringkasan lalu medali terkonfirmasi. Total 225/250/275/300 untuk perunggu/perak/emas/platinum setelah tiap level lulus. Foto manual dan pencarian tiga buku opsional, tidak menambah skor.
- Tes eksternal penelitian berbeda dari kuis game. Pretest/posttest eksternal memakai butir sama dengan urutan berbeda. Jangan mengubahnya menjadi dua paket paralel tanpa keputusan baru.
- Materi, kunci, tujuan dan skor tidak diubah diam-diam. DataStore/penyimpanan lintas sesi bukan tambahan otomatis.

## 5. Sumber kerja dan status yang perlu dibedakan

Root clone adalah folder yang berisi `.git`, `places`, `scripts` dan file ini. Pada laptop sumber, foldernya `roblox-media-bahasa-skripsi` di dalam workspace `skripsi/roblox`; lokasi PC warnet dapat berbeda.

| Bagian | Status snapshot27 Oktober |
| --- | --- |
| WORKING kanonis | `places/RobloxLearningMedia-WORKING.rbxl` dalam clone |
| Hash file lokal terbaru yang diperiksa | `a4e910246c70993a0fb90cfb9e73150412664a88d14d79f25dc0626a380c9eef`,2.691.974 byte |
| Progress bar percobaan kanan atas | Sudah dihapus lokal; pengguna mengonfirmasi place bisa dibuka dan panel hilang |
| Commit perubahan game tersebut | **`e3360cb`** mencatat WORKING terbaru dan penghapusan `migration-v2/src/StarterGui/LevelProgressGui.rbxm`; commit bukan bukti Play lengkap |
| `default.project.json` | Perubahan lokal lama milik pengguna, pertahankan dan jangan ikutkan tanpa alasan |
| Riwayat commit | `4fbc41b` dasar sebelumnya; `58d231f` brief awal; `e3360cb` penyimpanan perubahan game. Pastikan clone PC tujuan memuat commit game tersebut |
| Baseline | File BACKUP pendahulu di luar clone tetap utuh; salinan tambahan lokal telah diverifikasi. Build eksperimenAfinal belum dinyatakan dibekukan/diuji |
| Rancangan | Userflow, contoh hi-fi dan149 low-fi rinci tersedia; total 155 gambar pada dokumen rancangan menurut verifikasi sebelumnya |
| Implementasi fiturbaru | Masih tahapawal; rancangan/prototipe bukan fitur yang sudah terpasang |
| Play lengkap | Audio, kuis, skor, retry, akses lintaslevel belum tercatat lulus seluruhnya |
| Validasi/eksperimen | Belum dinyatakan terlaksana dari snapshot ini; formulir atau rancangan tersedia bukan hasil validasi |

Pada chat yang mempunyai tools/file, **periksa ulang Git dan WORKING sebelum memakai snapshot ini sebagai status hari ini**. Pada chat diskusi tanpa tools, sebutkan bahwa status mengikuti tanggal snapshot dan minta pembaruan hanya bila berpengaruh pada jawaban.

## 6. Hambatan teknis dan alur kerja

Sempat ada error ID instance setelah penghapusan GUI, lalu diperbaiki. WORKING terkini berbeda dari kandidat perbaikan lama; jangan menimpanya dengan backup/build lama. Parser lama tidak mendukung kompresiZSTD; Lune0.11.1 membaca parsial dengan peringatan properti Terrain 0x23. Jangan melakukan roundtrip/serialize WORKING melalui alat yang pelestarian datanya belum terbukti. Gunakan Studio untuk menyimpan place.

Bug `LevelProgressHandler` belum diperbaiki: assignment progres mendahului pembandingan kenaikan. Kuis existing mengirim progres sebelum skor. Telusuri kedua event sebelum mengubah validasi; jangan menganggap pemeriksaan akses server sudah andal.

Alur antarPC: satu PC edit → Stop Play → Save to File WORKING → commit/push berhasil → PC berikutnya clone/pull → bukaWORKING. Git jalurutama; flashdisk menyimpan cadangan/bukti. `.rbxl` binary tidak digabung otomatis bila diedit di dua PC. Helper selesai existing hanya men-stage WORKING; penghapusan model dan dokumen/script perlu commit terfokus sendiri.

MCP bawaan Studio menjadi pilihan koneksi AI; koneksi aktual belum terverifikasi pada PC warnet. Setup lokal/login/izin aset tidak otomatis terbawa dari GitHub atau flashdisk. Jangan menyatakan connected hanya karena konfigurasi ada.

## 7. Sumber pendamping bila tersedia

Pada workspace skripsi lengkap (dua tingkat di atas root clone): `docs/CONTEXT.md`, `docs/AGENTS.md`, `docs/ROADMAP_OKTOBER_NOVEMBER_2026.md`, `docs/pengembangan/HANDOFF-DEVELOPMENT.md` dan folder storyboard aktif. Naskah akademik resmi berada pada Google Docs tab Production sesuai konteks akademik; bukan otomatis file Word lokal.

Mulai saat duduk di PC warnet dari [PANDUAN-WARNET-3-JAM.md](PANDUAN-WARNET-3-JAM.md). Panduan, catatan tahap 0 dan script cadangan/cek PC disertakan dalam commit setup pendamping setelah `e3360cb`. Kit ZIP offline tetap merupakan artefak lokal di luar clone, tidak otomatis tersedia melalui GitHub. Brief ini dapat dipakai mandiri untuk diskusi awal.

## 8. Cara memakai brief di chat baru

**AI yang dapat membuka folder proyek:** buka root clone sebagai proyek lalu kirim:

> Baca AGENTS.md dan KONTEKS-AI.md terlebih dahulu. Ringkas posisi terakhir dan batas kepastianmu. Untuk chat ini saya ingin [brief/diskusi/rencana/persiapan bimbingan], belum meminta implementasi game. Pertanyaan saya: [...].

**AI tanpa akses file atau repository private:** lampirkan `KONTEKS-AI.md` atau tempel isinya, lalu tulis tujuan chat dan perubahan terbaru sejak snapshot. Link GitHub saja belum tentu dapat dibaca; login pada browser pengguna tidak otomatis memberi AI akses repo.

GitHub menyimpan konteks; bukan memori otomatis untuk semua AI. File AGENTS membantu klien yang mendukungnya; tetap sebut file brief pada awal chat baru dan pastikanAI benar-benar membacanya. Tidak perlu menempel seluruh riwayat chat. Tambahkan hanya sumber/desain yang relevan untuk pertanyaan khusus.

## 9. Serah-terima singkat untuk diperbarui

Terakhir 27 Oktober: perubahan game telah dicatat pada `e3360cb`; tahap 0, inventaris file, cadangan dan panduan warnet tersedia. Play baru belum dilakukan. Langkah development berikut: clone/pull versi tersimpan → Play baseline → satu `L1_PapanInformasi` dan uji rute → panel/interaksi → segmentasi sesuai aset → latihan/evaluasi. Untuk diskusi, mulai dari tujuan terbaru pengguna, bukan langsung menjalankan daftar implementasi.

Setiap perubahan material, perbarui bagianstatus dan serah-terima file ini dengan tanggal, hasil aktual, bukti/versi, masalah dan langkahberikutnya. Pada workspace lengkap, selaraskan dengan CONTEXT akademik; jangan membuat dua riwayat yang saling bertentangan.
