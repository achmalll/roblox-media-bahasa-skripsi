# Latihan 2 — empat ronde editor simpulan dan bukti

Keputusan kerja24Oktober2026: pengguna meminta latihan tidak berhenti pada satu kasus. Rancangan aktif diperluas menjadi4ronde berbeda dalam satu panel, masih diLevel3 Membaca lanjutan dengan abstrak yang sama. Bukan empat gedung/levelutama baru, bukan validasi ahli, dan belum implementasiStudio. Latihan1 tetap drag tiga fungsi gagasan. Materi lengkap dan empat soal evaluasi tidak diubah.

## Alur

Dari papan gagasan → berjalan ke papan simpulan → tahanE sekali → ronde1 → ronde2 → ronde3 → ronde4 → rangkuman4/4 → tutup → berjalan ke kios. Antarronde tidak berjalan/interaksiE ulang. Setelah dua pilihan tepat, Ronde berikutnya muncul; tidak otomatis meloncat. Tombol Ke kios hanya pada rangkuman jika semua ronde selesai.

Setiap ronde memakai tiga rentang draf parafrase dan dua kalimat sumber utuh. Pemain coret satu rentang yang melampaui bukti, lalu tunjuk kalimat pendukung sesuai instruksi. Tidak mengetik/drag; tampilan awal seragam. Menandai kalimat adalah bentuk respons, sedangkan tujuan tetap memahami cakupan/relasi informasi. Draf tidak meminta koreksi tata bahasa. Hasil akhir dan tanda baca sudah disiapkan.

## Ronde 1/4 — Kendala dalam bacaan

Sasaran: Menemukan akibat yang dinyatakan teks dan membedakannya dari akibat yang dibesar-besarkan.

Instruksi: Coret akibat yang berlebihan. Tunjuk kalimat tentang keterbatasan programmer.

Sumber: paragraf1, kalimat1 dan 3 (verbatim dari isi-sumber.json).

Bukti b1: Sistem operasi dibangun dan dirancang berdasarkan dua kekuatan utama, yaitu kapabilitas perangkat keras dan tuntutan perangkat lunak.

Bukti b2: Akibatnya, programmer menjadi terbatas dalam mengekspresikan bagian-bagian penting dari program mereka karena adanya lapisan kompatibilitas dan overhead yang terus dipertahankan, meskipun tuntutan terhadap throughput yang lebih tinggi dan latency yang lebih rendah terus meningkat.

Draf parafrase:

d1: Lapisan kompatibilitas dan overhead membatasi programmer dalam mengekspresikan bagian penting program,

d2: meskipun tuntutan throughput lebih tinggi dan latensi lebih rendah meningkat;

d3: akibatnya peningkatan perangkat keras tidak memberi manfaat apa pun.

Kunci penelaah: d3+b2. ID tidak terlihat padaUI.

Hasil revisi: Lapisan kompatibilitas dan overhead membatasi programmer dalam mengekspresikan bagian penting program, meskipun tuntutan throughput lebih tinggi dan latensi lebih rendah meningkat.

Petunjuk revisi: Bacaan menjelaskan keterbatasan, bukan ketiadaan seluruh manfaat perangkat keras.

Petunjuk bukti jika belum sesuai: Kalimat yang dipilih menjelaskan dasar perancangan sistem. Cari akibat lapisan kompatibilitas terhadap programmer.

Frasa bantuan setelah kesalahan berulang: programmer menjadi terbatas.

## Ronde 2/4 — Peluang bukan hasil yang sudah terjadi

Sasaran: Membedakan status peluang kajian dari klaim bahwa perubahan telah berlaku menyeluruh.

Instruksi: Coret klaim perubahan yang sudah pasti terjadi. Tunjuk kalimat tentang peluang pergeseran model.

Sumber: paragraf2, kalimat1 dan 2 (verbatim dari isi-sumber.json).

Bukti b1: Saat ini, terdapat peluang untuk mengkaji bagaimana pertemuan berbagai tren dapat menggeser model pemrograman dari sudut pandang tradisional yang berpusat pada proses (process-centric) menuju pendekatan yang berpusat pada data (data-centric), di mana data menjadi entitas utama dalam sistem.

Bukti b2: Peluang ini muncul seiring dengan perkembangan perangkat keras yang secara langsung memengaruhi cara pandang terhadap jalur akses data serta tanggung jawab sistem operasi dan kernel.

Draf parafrase:

d1: Peralihan ke data-centric telah terjadi pada seluruh sistem operasi;

d2: abstrak menyebut peluang mengkaji pergeseran model pemrograman

d3: seiring pertemuan berbagai tren perangkat keras.

Kunci penelaah: d1+b1. ID tidak terlihat padaUI.

Hasil revisi: Abstrak menyebut peluang mengkaji pergeseran model pemrograman seiring pertemuan berbagai tren perangkat keras.

Petunjuk revisi: Perhatikan status pernyataan: peluang untuk mengkaji tidak sama dengan perubahan menyeluruh yang telah selesai.

Petunjuk bukti jika belum sesuai: Kalimat itu menjelaskan latar perkembangan perangkat keras. Cari kalimat yang menyatakan status peluang dan arah pergeseran model.

Frasa bantuan setelah kesalahan berulang: terdapat peluang untuk mengkaji.

## Ronde 3/4 — Batas perubahan yang diusulkan

Sasaran: Menghubungkan dua perubahan yang disebut teks dan menolak generalisasi di luar cakupannya.

Instruksi: Coret perubahan yang tidak didukung. Tunjuk kalimat yang menyebut kernel dan serialisasi.

Sumber: paragraf3, kalimat2 dan 4 (verbatim dari isi-sumber.json).

Bukti b1: Pendekatan ini merumuskan ulang tujuan sistem operasi dan memungkinkan peninjauan kembali teknik pemrograman sistem klasik ke dalam model yang memfasilitasi berbagi data, alih-alih menghambatnya.

Bukti b2: Sebaliknya, pendekatan data-centric ini mengurangi keterlibatan kernel dalam jalur akses data, menjadikan data bersifat mobile melalui referensi invarian yang tidak bergantung pada ruang alamat atau mesin, serta menghilangkan kebutuhan akan serialisasi.

Draf parafrase:

d1: Pendekatan data-centric mengurangi keterlibatan kernel dalam jalur akses data,

d2: menghilangkan seluruh kompleksitas dan biaya dalam setiap sistem operasi,

d3: serta menghilangkan kebutuhan serialisasi pada model yang dijelaskan.

Kunci penelaah: d2+b2. ID tidak terlihat padaUI.

Hasil revisi: Pendekatan data-centric mengurangi keterlibatan kernel dalam jalur akses data serta menghilangkan kebutuhan serialisasi pada model yang dijelaskan.

Petunjuk revisi: Teks menyebut perubahan tertentu, bukan penghapusan seluruh kompleksitas dan biaya pada setiap sistem.

Petunjuk bukti jika belum sesuai: Kalimat itu menyebut tujuan memfasilitasi berbagi data. Cari kalimat yang memuat dua perubahan khusus: kernel dan serialisasi.

Frasa bantuan setelah kesalahan berulang: mengurangi keterlibatan kernel.

## Ronde 4/4 — Hasil penelitian dan batas simpulan

Sasaran: Membedakan hasil kinerja yang dilaporkan dari rekomendasi universal yang tidak didukung.

Instruksi: Coret rekomendasi yang melampaui bukti. Tunjuk kalimat yang mendukung hasil kinerja.

Sumber: paragraf4, kalimat2 dan 3 (verbatim dari isi-sumber.json).

Bukti b1: Evaluasi terhadap Twizzler dilakukan melalui studi kasus yang menunjukkan perilaku sistem, efektivitas, dan kegunaan model pemrograman yang dikembangkan, dengan membangun sejumlah perangkat lunak baru khusus untuk Twizzler.

Bukti b2: Selain itu, aplikasi berukuran besar yang telah di-porting juga digunakan untuk menunjukkan kinerja Twizzler dan model pemrogramannya, yang dalam banyak kasus menunjukkan peningkatan performa semata-mata karena penyederhanaan lapisan perangkat lunak.

Draf parafrase:

d1: Pada banyak kasus yang dilaporkan,

d2: Twizzler menunjukkan peningkatan performa;

d3: karena itu seluruh sistem operasi wajib diganti.

Kunci penelaah: d3+b2. ID tidak terlihat padaUI.

Hasil revisi: Pada banyak kasus yang dilaporkan, Twizzler menunjukkan peningkatan performa.

Petunjuk revisi: Hasil pada banyak kasus tidak menetapkan kewajiban mengganti seluruh sistem operasi.

Petunjuk bukti jika belum sesuai: Kalimat itu menjelaskan pengujian melalui studi kasus. Cari kalimat yang secara khusus menyebut hasil peningkatan kinerja.

Frasa bantuan setelah kesalahan berulang: dalam banyak kasus.

## Pemeriksaan dan progres

Periksa aktif setelah bagianDrafId dan buktiId terisi. Empat kondisi: keduanya tepat→ronde selesai; revisi tepat/bukti belum→tinjau bukti; revisi belum/bukti tepat→tinjau cakupan draf; keduanya belum→tinjau keduanya. Tidak menilai selama pemilihan. Kunci bervariasi dan masing-masing pasangannya tunggal. assess pada bank-ronde-editor.cjs adalah acuan pemeriksaan tertutup, bukan kodeRoblox yang sudah terpasang.

Coba lagi mempertahankan pilihan. Jika masih salah pada pemeriksaan berikutnya, bantuan dapat menyorot frasa terkait ronde dan menjelaskan cakupan, tetapi pemain tetap memilih danPeriksa. Tidak otomatis selesai. Jumlah bantuan/percobaan masih rancangan telaah, bukanSOP eksperimen final. Tidak memakai timer atau poin latihan.

Simpan pilihan, percobaan, bantuan dan status selesai perronde selama sesi. Ronde berikutnya terkunci sebelum ronde sekarang selesai. Selesai bersifat idempoten: mengulang klik tidak menambah jumlah selesai dua kali. Tutup/Baca abstrak mempertahankan ronde dan pilihan; buka kembali melanjutkan ronde pertama yang belum selesai, bukan resetR1. Meninjau ulang ronde selesai tidak menghapus progres atau menghasilkan hadiah tambahan. Empat ronde selesai berarti progres latihan, bukan bukti empiris keterampilan meningkat.

## Layar aktif

05A satu objek akses.05B/C/D contoh awal/salah/tepat ronde1.05R2A/B awal/tepat ronde2;05R3A/B ronde3;05R4A/B ronde4.05Z rangkuman. Keadaan salah semua ronde memakai komponen yang sama dan pesan sesuai bank. Kios06B memperlihatkan contoh2/4 belum lengkap. Visual interaktif lama dalam chat hanya contoh satu kasus untuk memperjelas mekanik, bukan seluruh bank aktif.
