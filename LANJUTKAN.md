# Mulai di warnet: satu pintu untuk pengguna dan AI

Diperbarui 29 Oktober 2026. Ini rencana sesi berikutnya, bukan klaim bahwa seluruh Level1 sudah selesai. AI wajib memperbarui file ini pada setiap akhir sesi agar pengguna tidak perlu menjelaskan ulang progres.

## Untuk pengguna: cukup empat langkah

1. Colok flashdisk → buka folder roblox → klik MULAI.cmd.
2. Buka/login Studio dan Codex. Buka folder roblox-media-bahasa-skripsi pada flashdisk sebagai proyek Codex; buka places/RobloxLearningMedia-WORKING.rbxl pada Studio. Bila plugin baru dipasang, buka ulang Studio dan tanggapi izin yang diminta.
3. Kirim satu pesan ini di Codex: **Lanjutkan sesi warnet sesuai LANJUTKAN.md. Baca konteks dan log terbaru, periksa koneksi, lalu pandu saya mengerjakan target berikut. Saya yang mengendalikan Play/Stop/Save Studio. Catat progres hari ini dan perbarui handoff sebelum selesai.**
4. Ikuti instruksi konkret AI. Menjelang pulang: Stop/Save dan tutup place; minta AI memperbarui konteks/log/fileini, lalu klik SELESAI.cmd. Tinjau daftar file, isi pesan commit dan ketik YA. Tutup aplikasi yang memakai flashdisk dan Eject Windows setelah berhasil.

Studio/Codex harus tersedia pada PC dan akun berizin perlu login. Colok USB tidak otomatis menjalankan aplikasi. Proyek, rancangan, Git, runtimeNode dan helper sudah dibawa; tidak perlu clone ulang selama folder ini dipakai terus.

## Untuk AI: jangan minta pengguna mencari sumber dari nol

1. Baca AGENTS.md, KONTEKS-AI.md dan entri terbaru docs/LOG-PENGEMBANGAN.md. Log mengandung beberapa entri lama yang urutannya tidak kronologis; utamakan tanggal terbaru dan checkpoint yang jelas, bukan kalimatstatuslama di tengah file.
2. Baca docs/ACUAN-DESAIN.md → docs/desain/README.md → storyboard aktivitas yang relevan. Link Docs rancangan ada di petaacuan. Gunakan snapshot jika konektor tidak bisa membacaDocs dan sebut batasnya; jangan meminta loginGoogle hanya untuk membaca snapshot yang sudah ada.
3. Aktifkan environment portable pada setiap shell Git/Node sesuai AGENTS. Jalankan bootstrap hanya jika belum aktif, lalu periksa rootclone, timestampstatus, WORKING benar, modeEdit dan source sinkron. Status lama atau serverlocalhost hidup bukan bukti Studio sudah terhubung.
4. Periksa git status dan versi file aktual; jangan overwrite perubahan pengguna atau pull saat masih ada pekerjaanlokal. Tidak perlu clone ulang atau setupmanualruntime di PCbaru bila helper berhasil.
5. Jawab pembuka dalam tiga poin: yang sudah selesai, yang belum selesai, dan satu target sesiini. Lalu berikan langkah yang bisa dilakukan langsung beserta lokasi/tombol Studio; jangan hanya memberi rencana abstrak.
6. Pengguna mengendalikan Studio. AI dapat menyiapkan/mengubah source melalui jalur yang diizinkan, tetapi jangan mengambilalih klik/Play/Stop/Save tanpa permintaan eksplisit. Jika perlu tindakan manusia, sebut tepat apa dan hasil yang harus muncul. Jangan menyamakan userclear dengan seluruhskenariolulus.

## Posisi yang sudah aman

- Checkpoint Save pengguna pada commitcea89a6 sudah terkirim. WORKING hash2b590468c0754b23ac7a83a5c1cb427e4159214f9afb7346a0918fd541063029,2.707.026byte; source terkelola cocok denganfiledisk,9prompt1detik.
- Pemutar tiga segmen male dengan desainterbaru sudah disimpan; pengguna menyatakan perubahanterbaru clear. Female ditunda. Latihan duáslot dan evaluasi empatsoal tier1→tier2→feedback→hasil sudah ada pada source.
- Perangkatportable sudah diuji pada laptop/flashdisk; PCwarnetlain dan izin/loginnya belum dapat dijamin dariPCini. Tidakada langkah format atau pemindahancredential.
- **Belum selesai:** showResult evaluasi baru menampilkankelulusan/arahLevel2; jalurhasil→skor/progressserver→unlockLevel2 belum dituntaskan. PengujianL1seluruhcabang belum lengkap. Jangan mengulang membangun papan/audio dari nol.

## Target sesi berikutnya: lulus Level1 benar-benar membuka Level2

A. Inventaris sourceaktif kuis/hasil, eventskor/progres dan handler server dalamWORKING. Bridgev1 mengelola Level1Handler saja; jangan menganggap edit sourcearsipserver otomatis terpasang. Sebut perubahan server yang diperlukan dan cara memasangnya secara konkret.

B. Telusuri bugserver yang sudah tercatat: assignmentprogres mendahului pembandingan; kuisbaseline mengirimprogres sebelumskor. Buat kontrak penyimpanan skor dan pembukaanakses yang konsisten tanpa mengubah materi/kunci/skor. Jangan sekadar menambahkan syaratskor yang justru menolak event karena urutannya.

C. Integrasikan hasil baru dengan status sah per pemain. Tier1 tetap25/0,maks100,lulus75; alasan0–4 terpisah dan latihan tanpa poin. Kelulusan membukaLevel2; pengulangan tidak menurunkan akses yang sudah didapat. Jangan menambah DataStore atau sistembaru tanpa kebutuhan yang disepakati.

D. Pandu pengguna menguji minimal: 50belum membukaLevel2,75membuka,100tetapbenar, retrytidak menghitungganda atau menurunkanakses, serta pemainlain tidak ikut terbuka. Catat hasilaktual, bukan asumsikode.

E. Jika targetakses selesai, lanjut ujialurL1 utuh: tigaaudio, jeda/tutupbuka/ulang, papaninformasi, dua-slot, kios, tier1/2, feedback, hasil danretry. Level2/3 baru diperluas setelah polaL1 stabil. Foto/bonus/dekorasi tetapbelakangan.

## Alokasi sesi tiga jam

- 0–15menit: login/buka proyek/bootstrapterverifikasi dan ringkasanstatus. Jika PCbaru memerlukaninstall, beri batassetup danjelaskan hambatan; janganhabiskan seluruhsesi.
- 15–40: inventaris hasil/event/server dan tentukan perubahankecil yang akan dipasang.
- 40–115: implementasi serta pemasangan, satu alur dahulu.
- 115–150: penggunaPlaycabang lulus/gagal/retry, AIcatatbug/bukti danperbaikiterarah.
- 150–180: Stop/Save, verifikasi sumberdisk, catatanharian, backup, commit/push, stopbridge danEject.

Bila waktu lebihsingkat, kurangi cakupan fitur, pertahankan waktu simpan. Senin2November tetap untukdrafisiBabIV; bimbingan3November membawa naskah serta demo yang benar-benarberjalan.

## Penutupan harian wajib, dikerjakan AI

Sebelum pengguna menekan SELESAI, AI wajib memperbarui:

1. KONTEKS-AI.md: keadaan terbaru, batasbukti dan hambatan.
2. docs/LOG-PENGEMBANGAN.md: entri tanggalhariitu,PCbila diketahui, tiapperubahan/alasan, acuanlayar, file/pathobjek, pemasangansource/WORKING, langkahuji dan hasilaktual, bukti, versi serta sinkronisasi. Sesi tanpa fiturbaru tetap mencatat apa yang diperiksa dan mengapa belum lanjut.
3. LANJUTKAN.md: posisi yang sudahaman, sisa konkret, targetpertama sesiberikut dan instruksiuser yang masihperlu dilakukan. Detailhistoris ada dilog, bukan membiarkan targetfileini usang.

SELESAI memeriksa Save dan mewajibkan ketigafilehandoff ikut pada perubahan sebelum commit. TugasAI adalah menulisnya, bukan menyuruhpengguna menyusunulang konteks. Jangan menjadwalkan penulisanfiktif pada hari tidak bekerja; catat setiap sesi nyata dengan tanggalaktual.