# Revisi keterbacaan dan UI HP — 5 November 2026

## Permintaan dan acuan

Pengguna meminta memperbaiki panel materi/latihan/evaluasi Level 1–3 yang terpotong di HP, konsistensi ukuran/font, instruksi latihan, pesan akses, ruang kosong dan pembuka. Acuan utama: [Dokumentasi Roblox pengguna](https://docs.google.com/document/d/15yRqB9c4xXZ64redzaw6bDAKYVTe8qKOKeR81KARl1c/edit), dibaca melalui connector pada 5 November 2026, metadata modifiedTime 2026-11-05T05:11:35.146Z. Seluruh teks catatan dan 40 screenshot ditinjau (10 individual, sisanya melalui lembar tinjauan). Gambar sementara berada di local-rbxl/ui-audit/doc-screens; tidak dimasukkan Git karena merupakan bukti pribadi/lokal. Tautan ChatGPT Library dari pesan pengguna gagal diakses melalui web; tidak diklaim sudah dilihat.

Snapshot storyboard 27 Oktober tetap sebagai arsip rancangan. Keputusan terbaru pengguna mengesampingkan mekanik drag L2/L3 dan pilihan bukti terpisah pada Latihan 2 L3. Materi bacaan, audio, soal, kunci evaluasi, ambang 75, skor dan syarat kemajuan dipertahankan. Narasi pengantar/petunjuk antarmuka diperjelas agar sesuai aktivitas aktual, termasuk istilah sistem operasi dan penyebutan Level.

## Implementasi

- `studio-sync/ui/ResponsiveLearning.luau`: helper bersama yang di-inline ke tiga client existing. Shade memenuhi viewport (`ScreenInsets.None`), panel interaktif menghitung core/hardware safe area; ukuran mengikuti viewport tanpa mengecilkan seluruh UI. Konten panjang di-scroll, tinggi teks dihitung ulang saat teks/ukuran berubah, tombol minimal 48–56 px dan font utama 20/24 px. Panel dibatasi lebar 1080/tinggi 800 agar baris bacaan tidak memenuhi seluruh desktop.
- Level 1 kini mempunyai template. Pengantar dan materi memakai teks native yang mengalir. Revisi awal keliru menyembunyikan foto lokasi panduan selain peta; pengguna menolak perubahan itu karena susunan panduan sudah clear. Koreksi terbaru wajib mempertahankan seluruh foto, banner dan panah panduan existing beserta layout layar lebarnya, dengan scroll teks/stack foto hanya pada layar sempit. Audio memakai area scroll dengan kontrol existing. Latihan tetap pilih kartu lalu tempat tujuan, dua kolom jika lebar area >=700 dan tersusun vertikal jika lebih sempit. Isi dan kunci A/B tetap. Evaluasi memakai scroll untuk status dan kartu hasil berfont lebih besar. Tombol asli dipertahankan sebagai anak langsung frame agar callback handler legacy tetap menemukan tombol.
- Level 2/3: header, area scroll, footer tetap, umpan balik berada di awal scroll. Pada layar pendek, judul lengkap juga ada dalam konten scroll; header ringkas tidak mengambil seluruh tinggi layar. Posisi scroll dipertahankan pada pilihan berikutnya dan kembali ke atas saat umpan balik salah/selesai perlu dibaca.
- L2 Latihan 2: ketuk simpulan lalu ketuk bukti. Kesimpulan/bukti dan pemetaan ID tetap sama. L3 Latihan 1: ketuk gagasan lalu fungsi; urutan tampil diacak sekali per sesi dan tidak identik urutan jawaban, ID untuk rekaman tetap.
- L3 Latihan 2: satu kutipan sumber benar disediakan langsung pada setiap ronde; pemain hanya memilih satu dari tiga bagian draf untuk dicoret. Empat ronde, draf, kutipan sumber/final dan keyPart tetap. Tidak mengaku pemain memilih bukti yang disediakan.
- Recorder membedakan varian `provided_source_v2`: choices berisi satu ID bagian draf, evidenceProvided=true, validation server tetap memeriksa pilihan. Bentuk lama dua pilihan masih diterima untuk kompatibilitas. Katalog mencatat varian dan contentRevision baru. Ini perubahan bentuk respons latihan yang diotorisasi, bukan perubahan bank evaluasi.
- Sambutan existing diaktifkan kembali saat Play, sekali per sesi pemain. Pesan akses menjadi panel yang bisa digulir dan ditutup, menyebut prasyarat serta langkah berikutnya. Sentuhan pintu yang masih terkunci dapat menjelaskan syarat nilai tanpa mengubah collision/unlock. Tidak ada bypass atau auto Play/Save/publish.

Build setelah perubahan helper/template: `node scripts/build-responsive-ui.cjs` (L1, L2, L3, lalu recorder/katalog). Untuk L2/L3, builder individual juga meng-inline helper. Jangan mengedit generated source tanpa template/helper. Source `Level1ScoreHandler`, `Level2ScoreHandler`, `Level3ScoreHandler` dan ArrowGuide tidak diubah substansinya.

## Bootstrap dan kondisi awal

PC DESKTOP-9M46HUB, root C:/Users/FILKOM/roblox-media-bahasa-skripsi, HEAD acuan 4b64943. Perubahan awal user: WORKING diganti salinan cloud, 2950817 byte SHA256 85dfdf694196e46eb53153ae3e240c7451e9641a4aa8462cea5cfbb9d455dc0a; tiga handoff telah diperbarui audit sebelumnya. CONNECT-STUDIO sebelumnya gagal saat `Get-FileHash`/akses plugin dalam sandbox. Helper install/start pada shell aktif dengan eskalasi berhasil; tidak mengubah kebijakan global atau helper. Studio semula Place1; pengguna membuka WORKING lokal, lalu status online/Edit/11 sinkron terverifikasi sebelum perubahan.

## Pemeriksaan aktual dan temuan Play

Compile keempat source berubah PASS (L1/L2/L3 client dan LevelProgress recorder). Tes L2/L3 bank/alur/penilaian, score/progress, recorder runtime live mock/Studio off/on dan CSV PASS. Tes varian recorder memastikan satu respons dicatat, jawaban salah dibedakan dan payload dua pilihan untuk varian baru ditolak. `test-responsive-ui.cjs` menjalankan helper/shell dengan mock pada delapan viewport x dua safe insets: ruang scroll positif, footer terpisah, target sentuh, status, identitas tombol legacy dan dismiss notice. Ukuran: 320x568, 360x640, 390x844, 768x1024, 640x360, 844x390, 1280x720, 1920x1080. Ini simulasi geometri/teks aproksimasi, bukan render Roblox atau bukti semua perangkat. Fixture pertama gagal karena mock belum memiliki ClearAllChildren; diperbaiki, bukan kegagalan kode game.

Save pertama oleh pengguna: disk/editor 11/11, WORKING 2956115 byte SHA256 e05c80c074096f79f3da2f58b90c7c234b49e2c9e882f141daab7b1bc61a9f0f. Pengguna Play emulator iPhone XR landscape dan melaporkan terpotong. Screenshot Studio dibaca melalui Computer Use (observasi saja): label tombol sambutan bergeser keluar di kiri, karena AnchorPoint lama pada TextLabel turunan ImageButton. Ini kegagalan visual nyata; tidak dinyatakan clear. Isi panjang di scroll, scrollbar terlihat. Output yang tampak juga memuat warning existing `[L2 Server] Missing L2_MejaPasangan`; belum didiagnosis sebagai perubahan baru.

Pengguna Stop. UI.action diperbaiki: reset AnchorPoint/Position/Size/Rotation/AutomaticSize label turunan, buang constraint label yang mewarisi geometri lama, ratakan teks tombol ke tengah. Tambah regression assertion jangkar label dan petunjuk scroll panduan/sambutan; kartu hasil L1 dipertegas. Compile empat source, fixture UI dan recorder PASS ulang. Pengguna Save kedua; verifikasi disk/editor 11/11 dan 10 prompt 1 detik PASS. WORKING 2956289 byte SHA256 0ca23458231862aa77b3c6e19c424e8c3d6acc7a8356f81faaf155704ed9dffb. Bukti lokal `local-rbxl/setup/responsive-ui-status.json` dan `local-rbxl/bridge/saved-verification.json`. Pembacaan file hasil Save perlu eskalasi EPERM; tidak mengubah ACL.

ContentRevision saat Save kedua: `89a6ba1b546104c5d058f96aaa9984175a9ae33caf9c49f38364bfebc95747eb`. Play ulang setelah fix jangkar diamati lewat screenshot: tombol Sebelumnya/Berikutnya panduan berada di dalam tombol; isi scroll dapat lewat di belakang tombol tutup pada versi awal panduan. Pengguna kemudian menegaskan foto petunjuk lokasi dan layout panduan asli tidak boleh dihilangkan. Helper UI.guide disiapkan untuk mempertahankan foto/banner/panah dan susunan layar lebar, serta menumpuk foto pada portrait sempit. Fixture foto/layout/rotasi PASS. Koreksi panduan ini BELUM dibuild/diterapkan ketika catatan ini ditulis karena Studio masih Play; tunggu Stop pengguna, build, compile, sinkronisasi, Save dan verifikasi ulang. Tidak mengklaim panduan baru lolos Play. Tidak commit/push/publish. Dokumen akademik ../../docs/CONTEXT.md dan AGENTS.md tidak tersedia di clone ini.

## QA berikutnya — pengguna mengendalikan Studio

1. Ulang Play iPhone XR landscape: sambutan, teks tombol berada di tengah, gulir sampai petunjuk kontrol, tutup, gerak kembali normal.
2. Papan panduan: lima halaman, teks sesuai Level, tombol sebelumnya/berikutnya/tutup tetap berfungsi; peta tetap terlihat.
3. L1: pembuka; audio 1/2/3 sampai selesai/jeda/lanjut; informasi; latihan pilih kartu/tetapkan/ganti/salah/benar; pra-evaluasi, soal/alasan/feedback, gagal/retry/lulus/hasil.
4. L2: pembuka, tiga halaman berita, dua halaman istilah, bukti salah/benar, pasangan pilih/ganti/salah/benar, evaluasi/hasil. Periksa penanda tanda tanya di kios (catatan user; bentuk dunia belum diubah).
5. L3: pembuka, tiga halaman abstrak/istilah, gagasan acak/pilih/ganti, empat ronde sumber tunggal/coret salah/benar/final, evaluasi/hasil.
6. Portrait 390x844 atau 360x640, landscape 844x390 atau 640x360, tablet, desktop. Untuk setiap panel: semua konten dapat dicapai dengan scroll, tombol tidak tertutup, font terbaca, tidak ada overlap, tidak mengandalkan warna untuk status. Uji rotasi saat panel terbuka.
7. Pemberitahuan akses: prasyarat spesifik, dapat ditutup, tidak hilang sebelum selesai dibaca, tidak membuka akses. Pastikan medali/rekap/foto existing tetap berfungsi; belum ada QA ulang bagian akhir.

Uji bertahap memakai screenshot aktual; Stop sebelum perubahan, Save dan verifikasi ulang sebelum Play. Jangan menyebut responsif semua ukuran hanya dari fixture. Optimasi byte aset gambar panduan belum dilakukan: aset asli tidak diganti/diunggah ulang; mayoritas narasi kini native text. Tanda tanya kios dan warning existing memerlukan pemeriksaan terpisah bila masih mengganggu. Ringkasan untuk chat naskah: respons UI/varian latihan berubah, evaluasi/kunci/skor tetap; belum validasi ahli atau hasil eksperimen baru.

## Lanjutan: pemasangan koreksi foto dan gambar depan

Pengguna mengotorisasi pemasangan. Studio sudah Edit; koreksi UI.guide dibuild, empat source compile PASS, fixture UI/foto/rotasi serta tes Level 2/3 PASS, editor 11/11 sinkron. ContentRevision dd60edb9093df20128f360c432305d4001c4e674f956fb926c13a381a2d9da8c. Pada pemeriksaan 05:53 UTC disk masih Save kedua (7/11 source cocok); Save dan Play ulang koreksi foto belum terverifikasi. Ini memperbarui status pending build di bagian riwayat sebelumnya.

Permintaan gambar depan telah menghasilkan sampul dan ikon dengan judul final Pembelajaran Bahasa Indonesia, sesuai koreksi pengguna; lihat assets/branding/README.md dan manifest.json. Artwork baru memakai dua pelajar berseragam biru dan kampus/air mancur. Belum diunggah ke Roblox, bukan pengganti foto petunjuk lokasi.

## Save koreksi foto terverifikasi — 13:03 WIB

Pengguna mengonfirmasi Save. Editor 11/11, disk 11/11, 10 prompt 1 detik PASS; tahap ready_for_play. WORKING 2956876 byte SHA256 40687d8b01f859489716ec1168b4a6f1af8e3edeaddaf279f1dd1cf5edf8917a, contentRevision dd60edb9093df20128f360c432305d4001c4e674f956fb926c13a381a2d9da8c. Ini memperbarui status awaiting_save di riwayat sebelumnya. Belum Play ulang setelah koreksi foto; QA visual tetap terbuka. Tidak publish/commit/push.

## Narasi panduan dan pemusatan teks — 13:37 WIB

Pengguna meminta narasi lebih informatif dan posisi tengah setelah screenshot L1/aula. GuideCopy L1–L3 dan aula diubah menjadi paragraf tujuan, aktivitas dan hasil/akses berikutnya. UI.guide mempertahankan foto/banner/panah, menengahkan blok yang muat, dan beralih ke atas saat overflow. Batas ukuran/padding warisan label dibuang untuk mencegah isi terpotong. Font pada panel pendek20, selainnya20/24. Tes baru centering/overflow/constraint dan fixture lama PASS; compile4source PASS. Editor11sync. ContentRevision8423b4cccc4915dd9a8db586338fc1cf0d8a982aa3450cde5fbe43dc13023f05. Save/Play ulang revisi ini belum terverifikasi; tungguCtrlS pengguna.

## Save narasi panduan terverifikasi — 5 November 2026

Pengguna mengonfirmasi Ctrl+S setelah revisi narasi dan posisi baca. Verifikasi aktual: ready_for_play, editor 11/11, disk 11/11; verify-studio-save PASS dan 10 prompt 1 detik. WORKING 2957398 byte, SHA256 6e61ded672bff80081dce8dea2e49ef38d5d481b5a5047e295213d1bf9adc1a6. Koreksi narasi Level1–3/aula dan helper center/overflow kini tersimpan lewat Save Studio pengguna. Bukti local-rbxl/setup/responsive-ui-status.json dan local-rbxl/bridge/saved-verification.json. Belum Play ulang revisi ini; berikut pengguna Play desktop dan cek empat halaman panduan beserta foto/teks/tombol/scroll sebelum meneruskan alur. Tidak publish/commit/push atau perubahan materi/kunci/skor.


## Level 1: pulihkan karakter desain, bukan rombak panel — 5 November 2026

Pengguna mengirim enam screenshot Play Level 1, menolak tombol full-width, perombakan pembuka/materi serta hasil yang menumpuk. Cakupan terbaru: Level 1 dulu; pertahankan desain acuan yang sudah bagus, sesuaikan keterbacaan/font/whitespace/instruksi, desktop dan HP berbeda. Pengguna Stop; bridge online/Edit WORKING lokal.

Template L1 memakai adapter UI lokal (helper bersama dan template L2/L3 tidak diubah): batas panel desktop940x620 (audio tinggi560), font utama20 desktop/18 sempit, heading28/24. Pembuka mengembalikan banner existing dan tombol mulai proporsional, narasi tiga paragraf; tidak ada petunjuk gulir permanen. Materi mengembalikan empat kartu sumber daya, dua kolom pada layar cukup lebar dan satu kolom sempit. Audio kembali komposisi awal: judul/status/progres, Putar/Jeda terpusat36persen, tombol kembali/lanjut40persen; tidak full-width dan tidak semua elemen dalam list vertikal. Latihan tetap pilih kartu lalu tujuan, instruksi ringkas; tombol Tutup lebih sempit. Evaluasi mengurangi ukuran opsi dan lebar tombol aksi. Hasil memakai ImageLabel mahkota dari quizFrame/ResultBackground/ResultLulus/ImageLabel existing, skor tunggal sebagai fokus, statistik jawaban/alasan label terpisah. Semua tindakan penilaian/gate/recording tetap; belum mengklaim mahkota tampil sebelum Play.

File berubah: studio-sync/templates/Level1Handler.client.luau, generated studio-sync/src/Level1Handler.client.luau, LevelProgressHandler.server.luau dan docs/development/recording-content-v1.json untuk revision. ContentRevision eef145ce64902efb397be966924089c551eae3ea40bdbc338547878b17dd720a. Compile L1 PASS; tes score/progress dan recorder runtime live mock/Studio off/on PASS. Tes kode bukan bukti visual. Editor11source sinkron; Save revisi ini belum terverifikasi. Baseline terakhir WORKING2957398byte SHA2566e61ded672bff80081dce8dea2e49ef38d5d481b5a5047e295213d1bf9adc1a6. Berikut pengguna CtrlS, verify11/11, Play desktop L1 pembuka/audio/materi/latihan/feedback/hasil; cek mahkota/font/proporsi dan layar pendek, baru mobile. Format konsisten antarlevel tetap target berikut setelah L1 disetujui, jangan merombak L2/L3 sekarang. PC DESKTOP-9M46HUB, HEAD4b64943; tidak autoPlay/Save/publish/commit/push. Konteks akademik luar clone tidak tersedia.


## Save perbaikan desain Level 1 terverifikasi — 5 November 2026

Pengguna mengonfirmasi CtrlS. Hasil aktual: ready_for_play, editor 11/11, disk 11/11; verify-studio-save PASS dan10prompt1detik. WORKING 2958418 byte SHA256 c14101032843fd138bf7da9a62946bfe36678d7a0ca62a7e1988ab184f36ff12. ContentRevision eef145ce64902efb397be966924089c551eae3ea40bdbc338547878b17dd720a. Pembuka/banner, audio bertombol proporsional, kartu materi, font Level1 dan hasil dengan mahkota existing/skor terpisah kini tersimpan. Belum Play ulang atau persetujuan visual; berikut pengguna Play desktop Level1 terlebih dahulu, kirim screenshot masalah, Stop sebelum fix. L2/L3 tidak direvisi pada putaran ini; konsistensi berikutnya mengikuti L1 yang disetujui. Tidak publish/commit/push. Bukti local-rbxl/setup/responsive-ui-status.json dan local-rbxl/bridge/saved-verification.json.


## Latihan 2 Level 2: status pilihan dan pasangan dipermudah — 5 November 2026

Pengguna mengirim screenshot Latihan2 Simpulan dan Bukti, menilai status dipilih/dipasangkan tidak jelas dan meminta riset UX. Acuan dibaca: NN/g Visibility of System Status (https://www.nngroup.com/articles/visibility-system-status/) untuk feedback pilihan langsung dengan warna/penanda; W3C Dragging Movements (https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements) untuk alternatif klik/ketuk. Keputusan desain merupakan penerapan/inferensi pada game, bukan klaim validasi UX atau kepatuhan WCAG penuh.

Pengguna Stop. Template Level2FlowHandler mengubah latihan pasangan menjadi satu simpulan A/B per halaman, bukti dipilih langsung (tanpa dua tahap pilih simpulan lalu tujuan), indikator terisi A/B dengan lingkaran, opsi radio kosong/terisi, label DIPILIH, latar biru dan outline3px. Bukan hijau benar sebelum Periksa. Ketuk ulang membatalkan, mengganti bukti yang dipakai pasangan lain menukar/memindahkan penetapan sehingga tidak ada duplikasi; feedback meminta cek ulang pasangan. Navigasi A/B mempertahankan pilihan; status salah/selesai dibawa ke atas scroll. Kunci, isi dua simpulan/dua bukti, alur prasyarat dan penilaian tetap. Choices recorder tetap evidence slot assigned to conclusion i; urutan tampil2,1 tidak mengubah ID.

File: studio-sync/templates/Level2FlowHandler.client.luau, source L2, scripts/test-level2-pair-selection.cjs; generated LevelProgress dan recording-content-v1.json diperbarui melalui build-level2/build-recording. ContentRevision5ef29875341c9b0f6ad4d1a08fda686dd4694ddb73ef53dd961795d12e3186dd. Tes baru select/undo/change/swap/incomplete move/unique IDs PASS, compile L2/LevelProgress PASS, tes bank/alur/skor L2 dan recorder runtime PASS. Belum Play visual. Tidak merombak desain L1/L3 atau materi/evaluasi.

Baseline Save terakhir WORKING2958418byte SHA256c14101032843fd138bf7da9a62946bfe36678d7a0ca62a7e1988ab184f36ff12. Editor sinkron diperiksa setelah build; Save revisi ini belum terverifikasi. Berikut penggunaCtrlS, verify11/11, Play L2Latihan2 cekradio/outline/indikatorA-B/batal/ganti/Periksa salah-benar pada desktop lalu HP. PC DESKTOP-9M46HUB, HEAD4b64943; tidak autoPlay/Save/publish/commit/push. Konteks akademik luar clone tidak tersedia.


## Save interaksi pasangan Level 2 terverifikasi — 5 November 2026

Pengguna CtrlS. Hasilaktual ready_for_play, editor 11/11 dan disk 11/11; verify-studio-save PASS,10prompt1detik. WORKING 2958800byte SHA256 b37e9b41d048fe22d1424d665b23c854418e22e718f5427f6ff550c56ea5c315. ContentRevision5ef29875341c9b0f6ad4d1a08fda686dd4694ddb73ef53dd961795d12e3186dd. Latihan2 L2 satu simpulan perhalaman/radio/outline/indikatorA-B dan perubahan pilihan kini tersimpan melalui Save pengguna. BelumPlayvisual; berikut penggunaPlay cekpilih/batal/ganti/navigasi/Periksa salah-benar. Bukti local-rbxl/setup/responsive-ui-status.json dan local-rbxl/bridge/saved-verification.json. Tidakpublish/commit/push.


## Konsistensi hasil evaluasi Level 1–3 — 5 November 2026

Pengguna meminta semua hasil jelas dan konsisten setelah screenshot skor50 Level2. User Stop. Template L1/L2/L3: status Lulus/Belum lulus eksplisit berdasarkan skor percobaan>=75; mahkota existing hanya saat lulus; skor utama38/46px tanpa kotak/border hitam; rincian jawaban/alasan terpisah dan penjelasan alasan bukan skor kelulusan. L2/L3 menambahkan penjelasan jika percobaan sekarang gagal tetapi akses tetap terbuka dari kelulusan sebelumnya. Tombol belajar/retry/lanjut dan logika skor/gate tetap. L1 mahkota kini disembunyikan saat gagal.

Build-responsive-ui contentRevision92e526b2ac6df39066b02c4598399aac6348d9e4dc8ae7246c9c07424406d1bf; template3client,generated3client/LevelProgress/katalog berubah. Compile L1 dan tesL2/L3 termasukcompile PASS; belumPlayvisual. Save baru belumterverifikasi, baseline sebelumnya WORKING2958800byte/hashb37e9b41d048fe22d1424d665b23c854418e22e718f5427f6ff550c56ea5c315. BerikutCtrlS/verify11/11 laluPlayhasilgagal50/lulus75-100/ulangsetelahlulusketigalevel. TidakautoPlay/Save/publish/commit/push; PC DESKTOP-9M46HUB HEAD4b64943; akademikluarclonetidaktersedia.


## Save hasil evaluasi konsisten terverifikasi — 5 November 2026

Pengguna CtrlS. Aktual ready_for_play, editor 11/11 disk 11/11; verify-studio-save PASS10prompt1detik. WORKING 2959092byte SHA256 f5eb4106655bad4d2fddc4f78b9a0c1e328bf328535d81174f5e8f1cb18a4be6. Penyajian hasil Level1–3 kini tersimpan; belumPlayulang, bukanpersetujuanvisual. BerikutuserPlaygagal/lulus/retrysetelahlulus,cekstatus/mahkota/skor/alasan/tombol. Tidakpublish/commit/push. Bukti local-rbxl/setup/responsive-ui-status.json dan local-rbxl/bridge/saved-verification.json.

