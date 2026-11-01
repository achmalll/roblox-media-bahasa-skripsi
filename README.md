# Media pembelajaran Bahasa Indonesia di Roblox

Proyek implementasi skripsi. **Pintu masuk PC warnet baru: buka clone lokal di Codex dan ketik "Setup warnet dan lanjutkan workflow repo".** AI wajib mengikuti AGENTS.md dan [workflow otomatis](KERJA-WARNET-LOKAL.md). SETUP.cmd menyiapkan tahap awal yang sama; AI terus memeriksa editor dan file sesudahnya.

## Pegangan aktif

| File/folder | Fungsi |
| --- | --- |
| AGENTS.md | Instruksi AI baru; route setup/lanjut/offline |
| KERJA-WARNET-LOKAL.md | Prosedur satu pintu dan tabel tahap/tindakan otomatis |
| LANJUTKAN.md, KONTEKS-AI.md | Target dan status terkini; baca entri paling atas dahulu |
| places/RobloxLearningMedia-WORKING.rbxl | File game kanonis; dibuka/simpan dari disk lokal PC |
| studio-sync/src/, templates/, recording/ | Source aktif, template generated dan recorder server |
| studio-sync/project.json | Daftar source/properti terkelola bridge; sekarang11source |
| scripts/ | Setup, bridge, verifikasi file, builder, tes dan ekspor rekap |
| docs/desain/ | Snapshot rancangan dan bank isi penelitian; baca bagian relevan |
| docs/LOG-PENGEMBANGAN.md | Bukti dan serah-terima tiap sesi |
| docs/LEARNING-RECORDS.md | Skema jawaban/waktu per pemain, aktivasi dan batas pengujian |

Source terbaru dan GitHub tidak otomatis berarti isi WORKING sudah terbaru. Saat pembaruan1November, delapan source baru menunggu bridge/Edit -> Save -> verifikasi11 -> Play/cloud. Helper melaporkan kondisi aktual tanpa mengklaim QA yang belum dilakukan.

Di kos: edit dan tes offline dari clone laptop. Di warnet: clone/update ke path pendek disk internal, setup, uji/Save/verifikasi dan push sebelum pulang. USB hanya transfer/cadangan. GitHub menyimpan commit yang sudah dipush; repo tidak membawa aplikasi, login, atau izin plugin PC.

## Arsip dan ukuran repo

Paket Rojo/Argon (src, src copy, migration-v2, konfigurasi dan helper), master audio AUP, panduan/launcher lama dan dua helper satu kali Oktober telah dihapus atas permintaan pengguna 1 November. MP3, WORKING, source aktif, setup/bridge, pencadangan dan bukti penelitian tetap tersedia. Riwayat Git tidak diubah.

[Audit dan hasil pembersihan](docs/AUDIT-KEBERSIHAN-REPO.md) mencatat scope, ukuran dan commit sebelum penghapusan. Penutupan opsional memakai scripts/selesai-sesi.ps1; portable-runtime.ps1 dan warnet-common.ps1 tetap menjadi dependensi aktif.
