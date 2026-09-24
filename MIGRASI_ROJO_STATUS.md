# Status migrasi dan sinkronisasi Roblox

Pemeriksaan 24 September 2026. Tujuan praktis: file kerja bisa dibuka dari laptop atau PC warnet melalui repository GitHub private tanpa mengubah baseline Alif.

## Yang sudah menjadi sumber kerja

- `places/RobloxLearningMedia-WORKING.rbxl` adalah **place kanonis**. File ini memuat game utuh dan sudah masuk GitHub private pada commit `9718c22`.
- `../RobloxLearningMedia-BACKUP.rbxl` tetap menjadi arsip penelitian Alif, tidak diedit atau diunggah.
- `../RobloxLearningMedia-MIGRATION.rbxl` identik byte per byte dengan WORKING saat pemeriksaan 24 September; namanya tidak menandakan migrasi Rojo sudah berhasil.
- Panduan perpindahan komputer ada di `ALUR_SINKRONISASI.md`. Sinkronisasi via Git harus diakhiri dengan `push` berhasil pada PC pertama dan `pull` pada PC berikutnya. Karena `.rbxl` bersifat binary, jangan menyunting dua clone secara bersamaan.
- Percobaan *fresh clone* setelah commit `6f2d781` berhasil: `places/RobloxLearningMedia-WORKING.rbxl` pada clone dan workspace memiliki SHA-256 sama (`bce9e821bdf36c7dd9ef3d66787d7a088b98d33d9c3836d55a944b06171a5d41`); 512 berkas `src/` juga tersedia pada clone. Ini membuktikan transfer GitHub, **belum** membuktikan buka/Play di Studio pada PC lain. Folder clone uji sementara telah dibersihkan.

## Yang ditemukan pada percobaan Rojo/Argon

- `src/` berisi 512 file (sekitar 233 KB); `src copy/` berisi 81 file (sekitar 21 KB). Keduanya disimpan sebagai **arsip percobaan migrasi**, bukan tempat menambah fitur saat ini.
- `default.project.json` hanya memetakan sebagian service, sedangkan WORKING berisi lebih dari 22 ribu instance termasuk Workspace dan aset yang tidak terwakili penuh oleh source teks. Build Rojo dari konfigurasi ini belum dapat menggantikan place utuh.
- Metadata pada `src/` membantu menelusuri nama instance, properti tertentu, dan script. Ia belum membuktikan bahwa geometri, terrain, audio, seluruh properti, serta hubungan antar-instance bisa direkonstruksi.
- Tidak ada executable `rojo` pada PATH saat pemeriksaan. File `rokit.toml` saat ini hanya mendeklarasikan Argon. Karena itu tidak ada klaim bahwa build Rojo atau live sync telah lulus uji.

## Keputusan operasional sampai konversi teruji

1. Kembangkan fitur pada salinan WORKING di dalam repository dan simpan hasilnya ke path yang sama.
2. Commit dan push perubahan `.rbxl` setelah setiap sesi. Catat commit yang dipakai untuk pengembangan serta versi A/B penelitian.
3. Simpan `src/` dan `src copy/` untuk audit historis; jangan menjalankan Rojo/Argon sebagai sumber penimpa WORKING.
4. Pada sesi Studio pertama, uji Play tiga level dan lakukan siklus dua komputer: clone/pull → buka → simpan → commit/push → pull di komputer lain → buka kembali. Catat hash dan hasil Play.

## Syarat untuk menyatakan migrasi Rojo penuh berhasil

1. Pasang versi Rojo yang didukung dan plugin Studio; cocokkan project mapping dengan struktur WORKING tanpa menghapus instance yang tidak dipetakan.
2. Ekspor/representasikan komponen yang hendak dikelola Rojo, lalu build place **terpisah**, bukan menimpa WORKING.
3. Bandingkan struktur, script, GUI, properti penting, aset, dan perilaku Play hasil build terhadap WORKING pada ketiga level.
4. Setelah semua pemeriksaan lulus, baru putuskan apakah Rojo menjadi sumber utama. Jika hanya sebagian script yang aman dikelola Rojo, nyatakan batasnya dan pertahankan `.rbxl` sebagai kanonis.

Dokumentasi resmi: [Porting an Existing Game](https://rojo.space/docs/v7/getting-started/existing-game/), [Sync Details](https://rojo.space/docs/v7/sync-details/), dan [Recommended Workflows](https://rojo.space/docs/v7/workflows/). Dokumentasi Rojo menyebut adanya properti/aset yang tidak selalu dapat disinkronkan secara langsung, termasuk Terrain dan beberapa data binary.
