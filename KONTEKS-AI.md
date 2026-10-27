# Brief konteks untuk AI — skripsi dan media Roblox

Snapshot: **27 Oktober 2026**. Brief ini disiapkan agar chat baru bisa membantu diskusi, menyusun rencana, memahami progres atau melanjutkan pekerjaan tanpa mengulang penjelasan dari nol. Ini ringkasan operasional; bukan naskah skripsi, hasil penelitian atau bukti fitur selesai.

Update 28 Oktober 2026: screenshot Explorer pengguna memperlihatkan `Workspace.Level1Development` berisi `L1_KiosEvaluasi`, `L1_PapanInformasi`, `L1_PapanLatihan`, dan `Papan Petunjuk Kios`. Ini bukti visual nama objek, belum bukti posisi, Anchored, ProximityPrompt, modal, Save, atau Play.

Keputusan modal L1, 28 Oktober 2026: pengguna ingin interaksi tiga objek baru membuka modal dengan komponen/modal yang sama seperti papan panduan dan NPC Level 1 bila tersedia. Modal harus ditambahkan bertahap dan tidak membuat komponen UI duplikat tanpa pemeriksaan. Isi/peran: papan informasi memberi penguatan sistem operasi; papan latihan memberi aktivitas pesan utama vs informasi pendukung; kios memberi pembuka evaluasi Level 1. Prompt AI Roblox harus meminta inspeksi komponen existing, path aktual, LocalScript/RemoteEvent, dan tidak mengubah NPC/papan lain.

Pembatasan implementasi, 28 Oktober 2026: karena server/Studio dikhawatirkan tidak kuat, pekerjaan dipecah satu objek per tahap. Tahap pertama hanya `Workspace.Level1Development.L1_PapanInformasi`: satu ProximityPrompt dan satu modal statis ringan. Papan latihan, kios, NPC, audio, latihan, evaluasi, gating, dan logic lintas objek belum disentuh.

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
- Setiap perubahan wajib dicatat sebelum sesi berakhir atau commit: perbarui keadaan terbaru di file ini dan rincian di `docs/LOG-PENGEMBANGAN.md`. Catat apa/mengapa berubah, acuan layar, file/objek, status pemasangan, hasil uji aktual, bukti, masalah, versi/sinkronisasi dan langkah berikutnya. Jangan menunggu perubahan dianggap besar.

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

**Peta sumber untuk AI:** [docs/ACUAN-DESAIN.md](docs/ACUAN-DESAIN.md). **Snapshot flow/gambar/bank isi:** [docs/desain/README.md](docs/desain/README.md). **Rincian setiap sesi:** [docs/LOG-PENGEMBANGAN.md](docs/LOG-PENGEMBANGAN.md). Paket rancangan bertanggal27Oktober berisi155gambar dan narasi rinci, sehingga clone warnet dapat membaca acuan tanpa harus memiliki folder akademik di laptop. Ini snapshot lokal, bukan sinkronisasi otomatis Docs atau bukti implementasi.

**[Docs rancangan aktif — Desain layar dan kerangka ahli media](https://docs.google.com/document/d/1H6V69of2Y9FzAiecZ2L3JSsL21gK5BqmLlzJRbtZKb8/edit?tab=t.838lhhvpqegp#heading=h.y17deuhuu7oj).** Bila Docs meminta akses, pengguna login dengan akun Google yang memiliki izin. AI membutuhkan akses konektornya sendiri atau lampiran/snapshot; login browser pengguna saja belum membuktikan AI bisa membacanya. Jangan memberikan kredensial ke chat. Tidak mengubah izin sharing untuk menyelesaikan akses tanpa instruksi.

Pada workspace skripsi lengkap (dua tingkat di atas root clone): `docs/CONTEXT.md`, `docs/AGENTS.md`, `docs/ROADMAP_OKTOBER_NOVEMBER_2026.md`, `docs/pengembangan/HANDOFF-DEVELOPMENT.md` dan folder storyboard aktif. Naskah akademik resmi berada pada Google Docs tab Production sesuai konteks akademik; bukan otomatis file Word lokal.

Mulai saat duduk di PC warnet dari [PANDUAN-WARNET-3-JAM.md](PANDUAN-WARNET-3-JAM.md). Panduan, catatan tahap 0 dan script cadangan/cek PC disertakan dalam commit setup pendamping setelah `e3360cb`. Kit ZIP offline tetap merupakan artefak lokal di luar clone, tidak otomatis tersedia melalui GitHub. Brief ini dapat dipakai mandiri untuk diskusi awal.

## 8. Cara memakai brief di chat baru

**AI yang dapat membuka folder proyek:** buka root clone sebagai proyek lalu kirim:

> Baca AGENTS.md, KONTEKS-AI.md dan entri terakhir docs/LOG-PENGEMBANGAN.md terlebih dahulu. Jika membahas flow Roblox, baca docs/ACUAN-DESAIN.md, docs/desain/README.md dan storyboard bagian yang relevan. Ringkas posisi terakhir dan batas kepastianmu. Untuk chat ini saya ingin [brief/diskusi/rencana/persiapan bimbingan], belum meminta implementasi game. Pertanyaan saya: [...]. Catat setiap perubahan dalam konteks dan log.

**AI tanpa akses file atau repository private:** lampirkan `KONTEKS-AI.md` atau tempel isinya, lalu tulis tujuan chat dan perubahan terbaru sejak snapshot. Link GitHub saja belum tentu dapat dibaca; login pada browser pengguna tidak otomatis memberi AI akses repo.

GitHub menyimpan konteks; bukan memori otomatis untuk semua AI. File AGENTS membantu klien yang mendukungnya; tetap sebut file brief pada awal chat baru dan pastikanAI benar-benar membacanya. Tidak perlu menempel seluruh riwayat chat. Tambahkan hanya sumber/desain yang relevan untuk pertanyaan khusus.

## 9. Serah-terima singkat untuk diperbarui

**Status objek L1, 28 Oktober 2026, laporan pengguna:** pengguna melaporkan tiga objek tambahan sudah ditambahkan, sehingga struktur fisik L1 kini ditargetkan menjadi dua NPC existing + satu papan informasi + satu papan latihan + satu kios evaluasi. Nama/path, posisi, ukuran, Anchored dan keterbacaan belum diverifikasi oleh AI; status ini masih laporan pengguna. Pembagian berikutnya mengikuti storyboard aktif: Tutor1/audio1 (bagian definisi dan sumber daya), papan informasi sebagai penguatan audio1, Tutor2/audio2 lalu audio3 pada NPC yang sama, papan latihan sebagai satu aktivitas dua penempatan (pesan utama/informasi pendukung), dan kios sebagai akses evaluasi empat soal. Ini bukan pembagian lima potongan materi yang setara. Langkah berikut: inventaris nama/path dan posisi lima objek, rapikan jarak/jalur, lalu isi label statis; logic/prompt/gating/audio menyusul. Belum ada klaim Play/Save/commit/push.

**Pemeriksaan tab dan prioritas objekL1, 27 Oktober PC-29:** native get_document berhasil memeriksa11tab. Link pengguna `t.838lhhvpqegp#h.y17deuhuu7oj` memang tabaktif `Desain layar dan kerangka ahli media`, heading `Userflow utama dan contoh tampilan`; bagianawal bertanda paketvisual27Oktober. Storyboard00/05A/05B/07A/08A mengatur dua tutor existing dan tiga objek tambahan: papan penguatan, papan latihan, kios. `Arsip desain — hingga 21 Oktober` (`t.50dcuv5bp18r`) secara eksplisit bukan acuanaktif. `Peta tujuan pembelajaran tiga level` (`t.504bs8b94418`) menyimpan isi/bank materi tetapi masih memuat usulan konsol18Oktober; untuk objek/rute ikuti storyboardaktif, bukan membuat konsol tambahan dari usulanlama. Ini perbedaan versi/status, bukan keputusan menghapus materi. Usulan penataan konkret sesuai denah00 (relatif dari arahmasuk): tutor1kiri/tutor2kanan depan air mancur tetap; papanpenguatan dekatTutor1 di tepikiri; papanlatihan tepikanan dekatTutor2; kioskiri pada jalur menujuL2. Papan duplikat sudah teridentifikasi; sisa dua objek dapat ditata sebagai objekstatis dengan nama kerja `L1_PapanLatihan` dan `L1_KiosEvaluasi` (nama rekomendasi, bukan bukti sudahada). Permukaan05A: judulKenali sistem operasi + ringkasanPerangkat lunak/Pengelola sumber daya; isi lengkap05B tetap modalpenguatan dengan tombolKeTutor2/tutup. Tahapobjek cukup label, anchor, ukuran/arahhadap dan uji jalur; logic sesudahnya. Gambar00/05B yang dilihat adalah snapshotlokal, struktur155gambar pada tabaktif terdeteksi tetapi gambarDocs tidak direnderulang. Tidak mengubah Docs/place/source pada pemeriksaan ini; pemasanganmodal/jalur/Save belum terverifikasi. Konteks/log diperbarui, belum commit/push.

**Verifikasi Docs aktif, 27 Oktober PC-29:** pengguna mempertanyakan apakah papan informasi hanya Level2. Konektor GoogleDrive berhasil membaca dokumen rancangan `1H6V69of2Y9FzAiecZ2L3JSsL21gK5BqmLlzJRbtZKb8` melalui link tabDesain, modified_time sumber `2026-10-27T08:29:23.502Z`. Teks terkini mengonfirmasi L1 bagian05A papan tambahan dekatTutor1 dan05B penguatan audio1; secara eksplisit tidak ada padanan pada foto baselineL1. L2-02A ialah papan istilah existing, bantuan opsional dekatNPC; berbeda dari papan penguatanL1. Hasil fetch berupa teks gabungan dokumen; bukan verifikasi ulang gambar tertanam atau seluruh tab. Tidak ada konflik dengan snapshot pada bagian ini. Permintaan pengguna sebelumnya adalah modal05B; script `scripts/edit-papan-informasi-l1.luau` hanya menulis permukaan papan, sehingga bukan pemasangan modal dan tidak perlu dijalankan untuk tujuan editmodal. Tekspermukaan acuan05A ringkas, isi penguatan berada pada modal05B. Pemasanganmodal, gating, jalur danSave tetap belum terverifikasi. Tidak mengubah rancangan atau game pada pemeriksaan ini.

**Papan duplikat dan edit lokal, PC-29, 27 Oktober:** pengguna sudah menduplikasi papan menjadi `Workspace.Halaman depan.L1_PapanInformasi`, terlihat pada screenshot dan inventaris Command Bar pengguna pukul23:35 (Edit). Empat target aktual: masing-masing `Title`, `Animation 1`, `Animation 2`, `Animation 3` → `SurfaceGui.Frame.Edit me`. Inventaris masih berisi tulisan papan panduan lama; belum ada bukti teks baru terpasang. Disiapkan `scripts/edit-papan-informasi-l1.luau` untuk mengganti empat label dengan penguatan05B sesuai permintaan terakhir. Script memeriksa modeEdit, keunikan papan dan seluruh target sebelum mutasi, serta memberi waypointUndo. Ini file kode siap dijalankan melalui CommandBar; belum dieksekusi AI, belum mengubah modal/gating atau menyimpan place. Source proyek default tidak memetakan Workspace dan tidak membuktikan sinkronisasi aktif; jangan build arsip menimpa WORKING. Git saat pemeriksaan: HEAD acuan43b0a8d, konteks/log dan WORKING berubah, lock tak terlacak. WORKING aktual 2.693.258byte, LastWriteTime27Oktober23:32:09 menurut metadata host; SHA256 terbaru gagal dibaca karena akses ditolak, sehingga hash lama bukan hash terkini. ToolsMCP Roblox belum tersedia. Langkah berikut: jalankan fileLuau di CommandBar modeEdit → periksa empat tulisan dan keterbacaan → Save to File WORKING → verifikasi hasil/hash → uji rute. Modal membutuhkan inventaris GUI/penghubung actual tersendiri; SurfaceGui bukan bukti modal tersedia. Belum commit/push. Ringkasan perlu diserahkan ke chat naskah.

**Setup Assistant PC-29, laporan pengguna:** pengguna memilih mencoba API key OpenAI langsung di Roblox Assistant dan menyatakan sudah menambah key. Screenshot memperlihatkan `An unexpected client error occurred. Please try again`; penyebab, provider/model aktif, billing/kuota dan keberhasilan key belum diverifikasi. Tidak menerima/mencatat key. Dokumentasi resmi Roblox mengonfirmasi menu Assistant → … → Manage API Keys. Integrasi ini berbeda dari MCP chat ini dan belum membuktikan koneksi berhasil. Papan/Play baseline belum diselesaikan. Langkah diagnosis: periksa provider/model aktif dan status billing API, coba chat baru, lalu baca detail Output bila gagal; ini saran, belum hasil uji.

**Diskusi lanjutan PC-29:** pengguna meminta pendapat tentang langkah mulai Level 1 berdasarkan kode, posisi objek dan referensi Docs. Rekomendasi sementara: cek baseline existing, kemudian satu papan anchored + uji rute Tutor1–papan–Tutor2 sebagai target awal; setelah itu integrasikan audio1 → panel05B → Tutor2. Source `migration-v2` yang dibaca masih memakai pemilihan suara male/female dan kelanjutan langsung ke kuis; ini tidak membuktikan tiga klip/tugas baru sudah terpasang. Kecocokan source dengan WORKING berasal dari audit terdahulu, belum dibaca ulang live pada sesi ini. Koordinat tutor/papan belum diverifikasi. Rekomendasi ini usulan urutan kerja, bukan perubahan desain yang dikonfirmasi atau implementasi. Gating audio harus menunggu inventaris SoundId/durasi/batas klip aktual. Pembahasan terbaru tidak menjalankan Play/mengubah game.

**Sesi PC-29, 27 Oktober 2026 — pemeriksaan awal masih berlangsung:** pengguna meminta verifikasi MCP, Play baseline, pemasangan satu papan informasi L1 dan uji rute menurut 00/05A–05B. HEAD aktual `43b0a8d`; Git tersedia di `C:/Program Files/Git/cmd/git.exe` tetapi tidak di PATH. Status awal bersih selain file lock Studio tak terlacak. WORKING masih SHA256 `a4e910246c70993a0fb90cfb9e73150412664a88d14d79f25dc0626a380c9eef`, 2.691.974 byte. Dua jendela Studio ditemukan; jendela dengan path WORKING yang benar sedang Play saat diperiksa, avatar/papan panduan terlihat. Ini belum membuktikan spawn awal, sambutan, audio, Output atau jalur lulus. Tools MCP Roblox tidak tersedia pada chat; launcher standar dan entri `Roblox_Studio` pada config tidak ditemukan oleh helper. Studio sebenarnya terpasang di Program Files, sehingga deteksi folder standar helper menghasilkan false. Computer Use dapat membaca keadaan jendela, tetapi percobaan Stop ditolak berulang dengan `user input was detected in this window`; pemulihan target juga ditolak setelah pengguna menyatakan melepas kontrol. Tidak ada input/mutasi game yang dikonfirmasi berhasil. Papan belum dipasang, Save/commit/push belum dilakukan. Lanjut: pengguna Stop Play dan membantu inventaris baca-saja atau menghubungkan MCP; baru tentukan posisi aktual papan dan uji baseline/rute. `../../docs/CONTEXT.md` dan `../../docs/AGENTS.md` tidak tersedia; ringkasan sesi perlu diteruskan ke chat naskah.

Terakhir 27 Oktober: perubahan game telah dicatat pada `e3360cb`; tahap 0, inventaris file, cadangan dan panduan warnet tersedia. Play baru belum dilakukan. Langkah development berikut: clone/pull versi tersimpan → Play baseline → satu `L1_PapanInformasi` dan uji rute → panel/interaksi → segmentasi sesuai aset → latihan/evaluasi. Untuk diskusi, mulai dari tujuan terbaru pengguna, bukan langsung menjalankan daftar implementasi.

Pembaruan dokumentasi berikutnya: kewajiban update setiap perubahan dipertegas; petaDocs/akses, snapshot149low-fi+6visualringkasan dan bankisi tersedia dalamrepo; logpengembangan mulai digunakan. WORKING tetap hash a4e910… dan belum ada Playbaru pada sesi dokumentasi ini. Baca indeks dan sumber relevan agar AI mengetahui flow, bukan hanya daftar fitur.

Pada **setiap perubahan**, perbarui status/serah-terima file ini dan logpengembangan dengan tanggal, perubahan dan alasannya, hasil aktual, bukti/versi, masalah serta langkah berikutnya. Pada workspace lengkap, selaraskan dengan CONTEXT akademik; jangan membuat dua riwayat yang saling bertentangan. Detail boleh panjang bila diperlukan untuk serah-terima, tetapi jangan mengarang fakta atau menduplikasi seluruh naskah.
