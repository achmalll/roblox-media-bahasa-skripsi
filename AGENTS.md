# Petunjuk untuk AI pada repository ini

## Baca sebelum menjawab atau bekerja

1. Baca `KONTEKS-AI.md` di root repository untuk tujuan penelitian, keputusan tetap, status terakhir dan cara membantu pengguna.
   Untuk memahami flow atau mengerjakan Roblox, lanjutkan ke `docs/ACUAN-DESAIN.md`, `docs/desain/README.md`, dan storyboard aktivitas yang relevan. Baca entri terakhir `docs/LOG-PENGEMBANGAN.md` agar pekerjaan yang sudah dilakukan tidak diulang.
2. Tentukan cakupan dari permintaan terbaru. Untuk brief, diskusi, rencana atau persiapan bimbingan, bantu pada cakupan itu; jangan langsung mengubah game atau menjalankan Play.
3. Jika pengguna meminta implementasi, periksa struktur proyek, status Git dan file WORKING aktual sebelum mengubah apa pun. Snapshot konteks bukan pengganti pemeriksaan keadaan terkini.
4. Pada workspace skripsi lengkap, baca juga `../../docs/CONTEXT.md` dan `../../docs/AGENTS.md`; keduanya memuat konteks akademik serta aturan dokumen. Pada clone warnet yang tidak menyertakannya, gunakan brief repo dan nyatakan sumber yang belum tersedia bila diperlukan. Jangan menebak isi sumber yang tidak terbaca.

## Batas pekerjaan

- Gunakan Bahasa Indonesia yang jelas. Ikuti instruksi terbaru pengguna; jangan membuka ulang semua keputusan desain tanpa masalah konkret.
- File kerja game: `places/RobloxLearningMedia-WORKING.rbxl`. Pertahankan baseline A/pendahulu dan perubahan lokal pengguna. Jangan membangun ulang source arsip untuk menimpa place.
- Bedakan rancangan, kode disiapkan, terpasang di WORKING, hasil Play, penilaian ahli dan hasil eksperimen. Jangan mengklaim tahap berikutnya selesai dari bukti tahap sebelumnya.
- Jangan mengubah data penelitian, dokumen Word/PDF sumber, materi/kunci/skor/tujuan tanpa cakupan permintaan dan penjelasan yang sesuai. Jangan menyimpan kredensial atau data pribadi responden dalam repo.
- Setelah pekerjaan implementasi, lakukan pemeriksaan yang relevan dan laporkan batas pengujian.
- Commit/push mengikuti otorisasi pengguna dan cakupan pekerjaan. Jangan memasukkan perubahan lain hanya karena ada di working tree.

## Jika sumber tidak bisa diakses

Jangan mengaku sudah membaca file atau riwayat chat. Untuk AI tanpa akses repository private/lokal, minta pengguna melampirkan `KONTEKS-AI.md` dan hanya file pendamping yang diperlukan. Kehadiran file ini di GitHub tidak otomatis membuat semua aplikasi AI memuatnya.

## Wajib memperbarui konteks pada setiap perubahan

- Setiap perubahan kode, objek/map/UI, konfigurasi, dokumen/panduan, keputusan rancangan, status pengujian atau rencana kerja harus tercatat sebelum sesi berakhir atau commit dibuat. Catat juga percobaan gagal yang memberi temuan baru atau meninggalkan pekerjaan terbuka. Ini berlaku meskipun perubahan kecil; tidak menunggu dianggap material.
- Perbarui `KONTEKS-AI.md` untuk kondisi saat ini dan langkah berikutnya, serta tambahkan entri `docs/LOG-PENGEMBANGAN.md` untuk rincian sesi. Beberapa perubahan dalam satu rangkaian kerja boleh dicatat bersama, tetapi masing-masing perubahan dan dampaknya harus jelas; tidak perlu membuat versi file baru setiap ketikan.
- Catatan wajib mencakup tanggal/PC bila diketahui, permintaan, kondisi awal, file/path objek yang berubah, apa dan mengapa diubah, acuan desain/kode layar, status pemasangan di WORKING, langkah uji dan hasil aktual, bukti gambar/log, masalah tersisa, langkah berikutnya, serta versi/hash dan keadaan commit/push yang diketahui. Isi yang belum diketahui ditandai, bukan ditebak.
- Untuk Roblox, bedakan perubahan source dari perubahan place, mode edit dari Play, snapshot rancangan dari screenshot implementasi, dan rencana uji dari hasil aktual. Jelaskan cukup rinci agar AI baru dapat meneruskan tanpa seluruh riwayat chat.
- Jika snapshot rancangan diperbarui, catat sumber/tanggal/perbedaannya di indeks desain dan manifest; jangan mengklaim salinan lokal otomatis mengikuti Docs. Jika sumber bertentangan dengan keputusan terbaru yang sudah dikonfirmasi, tandai konflik sebelum mengubah substansi.
- Pada workspace lengkap, selaraskan juga `../../docs/CONTEXT.md` sesuai aturan dokumen. Pada clone warnet tanpa file itu, tetap perbarui konteks dan log dalam repo, lalu tandai ringkasan yang perlu diserahkan ke chat naskah.
- Commit yang mengubah sesuatu harus menyertakan pembaruan konteks/log yang relevan. Jangan mengaku push berhasil sebelum diverifikasi. Tidak perlu mengubah commit berulang hanya untuk menuliskan hash commit itu sendiri; gunakan ringkasan cakupan, hash WORKING atau commit acuan, dan laporkan hash final setelah commit.
