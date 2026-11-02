> Pembaruan 2 November 2026: recorder terbaru sudah terpasang dan Save terverifikasi di WORKING, termasuk latihan/evaluasi dua tingkat Level3. Uji DataStore TEST nyata Level1 berhasil menurut JSON yang dibaca pengguna dari dashboard setelah Stop: 7event lengkap, latihan salah→benar, nilai100/alasan4, durasi188.33detik first_interaction, sessionClosedtrue/player_left dan droppedEvents0. Belum uji cloudL2/L3, evaluasi gagal/retry, banyak pemain, rejoin atau ekspor data nyata. Bagian status1November di bawah adalah riwayat dan tidak mewakili status pemasangan terbaru. Tidak menyimpan data mentah/identitas pemain ke repo.
# Rekap belajar per pemain

Status 1 November 2026: source siap dan diuji offline. Belum dipasang/Save ke WORKING, belum Play atau diuji ke DataStore Roblox asli. WORKING tetap checkpoint Level 2 tanggal 31 Oktober. Gunakan laporan sesi untuk hash dan kondisi terakhir.

## Cakupan

| Kebutuhan | Implementasi source | Bukti offline |
| --- | --- | --- |
| Waktu L1/L2/L3 per pemain | Jam server, awal aktivitas sampai lulus pertama | test-learning-records, test-recording-runtime |
| Jawaban latihan L1 | Kartu untuk slot pesan utama dan informasi pendukung; setiap Periksa | test-recording-runtime |
| Jawaban latihan L2 | Dua pilihan bukti dan penempatan dua simpulan; salah/benar, bantuan, setiap Periksa | test-recording-runtime |
| Evaluasi L1/L2 | Pilihan jawaban dan alasan per soal, termasuk percobaan belum selesai; hasil tiap percobaan selesai | test-learning-records, test-score-recording, test-level2 |
| Evaluasi L3 existing | Pilihan empat soal baseline; gagal dan lulus dikirim | test-recording-runtime, test-score-recording |
| Latihan L3 rancangan baru | Belum dibuat; tambahkan adapter ketika fitur L3 dikerjakan | Belum diklaim terpasang/teruji |
| Pemain berbeda dan masuk ulang | UserId + UUID sesi + halaman; sesi baru tidak menimpa sesi lama | test-learning-records, test-recording-runtime |

Nilai kelulusan tetap 75; alasan L1/L2 tetap terpisah. Server L1/L3 sekarang menghitung skor dari pilihan, bukan menerima nilai total client. L3 existing sebelumnya hanya mengirim hasil lulus dan mengirim progress lebih dahulu; kini semua hasil dikirim, server membuka akses berikutnya setelah validasi. Handler progress juga menolak unlock4 sebelum nilai L3 memenuhi syarat. Ini instrumentasi baseline, bukan implementasi ulang materi/latihan Level 3.

## Arti waktu

- L1 dimulai pada interaksi Tutor1 (atau Mulai audio jika start pertama belum tercatat); L2 pada prompt stasiun L2 pertama yang diizinkan; L3 pada prompt pembuka existing, dengan fallback saat kuis dibuka.
- `completedSeconds` adalah detik server dari awal tersebut sampai percobaan pertama dengan nilai >=75. Membaca, diam, modal terbuka, respawn dan retry dalam koneksi yang sama termasuk durasi. Retry sesudah lulus tidak mengubah durasi kelulusan pertama.
- `observedSeconds` menyimpan waktu yang teramati sampai checkpoint/keluar bila belum lulus. `completed=false` berarti belum selesai; jangan menyamakan durasi pengamatan dengan durasi menyelesaikan level.
- Pemain keluar/masuk ulang mendapatkan sesi terpisah. Waktu offline tidak dihitung; belum ada penggabungan durasi lintas sesi atau pemulihan progres gameplay.
- Jika start tidak tertangkap dan hanya hasil akhir diterima, `timingQuality=evaluation_only` dan `completedSeconds` tidak diisi. Angka nol tidak dipakai untuk mengarang waktu penyelesaian. `first_observed_activity` menandai fallback dari jawaban pertama.
- Ini elapsed time selama sesi, bukan pengukuran waktu aktif/atensi. Identitas dan jam ditetapkan server; kejadian interaksi dilaporkan client dan diberi label validasi sesuai sumbernya.

## Penyimpanan dan pembacaan

Source recorder berada di `studio-sync/recording/`. Builder menyisipkannya ke Script existing `LevelProgressHandler`; tidak perlu membuat Script baru secara manual. Remote `LearningRecordEvent` dibuat server saat game berjalan. Bridge kini mengelola 11 Script/LocalScript existing; tiga tambahan adalah handler flow/kuis/skor L3, dengan path diverifikasi dari WORKING.

Game live menggunakan DataStore `LearningRecords_v1`, scope `u<UserId>`, key `<UUIDtanpahubung>:000001`, `:000002`, dst. Setiap halaman maksimum 64 event; event dan rekap level disimpan sebagai JSON-compatible table. `contentRevision` mengaitkan pilihan angka/huruf ke `docs/development/recording-content-v1.json` dan riwayat Git. Katalog memuat teks pilihan, soal dan latihan, agar jawaban dapat ditafsirkan kembali.

Semua pemain dicakup tanpa whitelist. Penulisan memakai UpdateAsync, setiap 30 detik, setelah hasil evaluasi, ketika keluar, dan saat server tutup. UUID per koneksi menghindari overwrite lintas sesi/server; revision menjaga snapshot lama tidak menimpa yang lebih baru. Halaman yang sudah penuh dan terkonfirmasi dibebaskan dari RAM, tidak dihapus dari cloud. Kegagalan diulang tiga kali dan buffer dipertahankan untuk autosave berikutnya, termasuk setelah pemain keluar selama server masih hidup.

Status administratif pada atribut Player `LearningRecordStatus`: `pending`, `saved`, `failed`, `incomplete`, atau `disabled_studio`. Tidak ada panel baru untuk pemain. Buffer maksimal 4096 event belum terkonfirmasi; bila habis, warning dan `droppedEvents` dicatat, bukan memangkas riwayat diam-diam. Gangguan cloud berkepanjangan/server crash masih dapat kehilangan data yang belum terkonfirmasi. Fitur belum layak dinyatakan siap pengambilan data sebelum uji simpan-baca nyata.

Pemilik experience dapat membuka Creator Dashboard -> experience -> Configurations -> Data stores manager, memilih store dan mencari prefix scope `u<UserId>`. Nilai key berisi rekap dan event mentah; tanpa UI game tambahan. Sumber resmi: [Data Stores Manager](https://create.roblox.com/docs/cloud-services/data-stores/data-stores-manager).

Untuk analisis lokal, simpan salinan **nilai halaman JSON mentah** ke folder privat di luar Git, lalu jalankan dari root repo:

```powershell
node scripts/export-learning-records.cjs "C:\data-privat\raw-pages" "C:\data-privat\rekap-baru"
```

Folder output wajib baru. `levels.csv` memuat detik/menit per level/sesi, status selesai, kualitas waktu dan kelengkapan halaman/rekaman. `attempts.csv` memuat urutan jawaban dan detail JSON, termasuk pilihan salah. Converter tidak mengambil data cloud atau meminta kredensial; gabungkan halaman dari semua pemain yang hendak dianalisis. Halaman yang hilang ditandai, bukan dianggap lengkap. Cocokkan angka/huruf pada detail dengan katalog sesuai contentRevision; gunakan Git bila versinya berbeda. Jangan commit hasil pemain asli ke repository.

## Aktivasi di PC yang mampu menjalankan Studio

1. Gunakan clone terbaru dan jalankan MULAI/CONNECT-STUDIO satu clone saja. Bila konfigurasi source berubah, restart bridge dan pairing. Buka WORKING, tetap Edit; pastikan 11 source sinkron dengan timestamp segar.
2. Source terbaru belum berada di biner lama: user Save di Studio dan AI menjalankan `node scripts/verify-studio-save.cjs` sampai semua 11 cocok. Jangan patch biner untuk melewati Save.
3. Pada experience uji terpisah yang sudah dipublikasikan, atur akses API Studio sesuai dokumentasi resmi. Recorder Studio **default tidak menulis**, sekalipun API Services diaktifkan. Untuk uji, buat atribut boolean Workspace `EnableLearningRecordStudioTest=true` sebelum Play. Store yang dipakai selalu `LearningRecords_TEST_v1`, bukan store live.
4. Uji dua pemain: latihan salah/benar, alasan salah/benar, evaluasi gagal lalu lulus, retry kirim ID sama, respawn, keluar sebelum lulus dan masuk ulang. Baca Data Stores Manager dan pastikan key/value/durasi benar-benar tersedia setelah server ditutup. Uji juga kegagalan penulisan dan statusnya. QA visual panah/papan L2 tetap diperlukan.
5. Setelah hasil uji disetujui dan source/biner tersimpan cocok, build dapat dipublikasikan melalui Studio untuk pemain live. Belum ada publish atau perubahan pengaturan cloud oleh AI sesi ini.

API: [Data stores](https://create.roblox.com/docs/cloud-services/data-stores), [batas dan error](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits). DataStore memerlukan server; callback UpdateAsync tidak boleh yield. Akses Studio perlu experience uji terpublikasi dan izin API, terpisah dari izin plugin localhost.

## Pengembangan berikut

Urutan build: `node scripts/build-level2.cjs`, lalu `node scripts/build-recording.cjs`. Builder recording juga memperbarui katalog isi. Jangan edit source generated `LevelProgressHandler` atau `Level2FlowHandler` secara langsung. Edit template/runtime yang sesuai.

Untuk latihan L3 nanti, tentukan skema ronde/slot dari storyboard, tambahkan validasi scalar di runtime, panggil recordLearning pada Periksa/Kirim, dan uji salah/benar/ulang/parsial. Jangan mengirim teks bebas atau nilai total sebagai pengganti pilihan. Durasi dan evaluasi baseline L3 sudah memiliki jalur recorder; latihan baru tetap pekerjaan berikutnya.

### Uji cloud tiga level — 2 November 2026
JSONTESTsesiL1-L3yangdibacapenggunadariDashboardmembuktikan27eventlengkap,3levelcompleted,score100semua;alasan4/0/1dari4. Durasi387.81/78.66/332.45detik. LatihaneditorL3salah→bantuan→benartercatat,sessionClosed/player_left,droppedEvents0. Belumpercobaanevaluasigagal/retry,banyakpemain,rejoinparsialataueksporCSVdatanyata. Identitas/JSONmentahtidakdisalinkerepo.
