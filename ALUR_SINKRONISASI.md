# Alur sinkronisasi laptop dan warnet

Untuk pembagian objek di Studio dan kode melalui file lokal, baca [panduan bridge](studio-sync/README.md) dan [skema sinkronisasi lokal](docs/development/SKEMA-SINKRONISASI-LOKAL.md). Status 28 Oktober 2026: bridge v1 terpasang dan diuji pada PC sesi ini untuk Level1Handler dan HoldDuration prompt yang didaftarkan. Di PC lain jalankan CONNECT-STUDIO.cmd, lalu buka WORKING; clone saja tidak memuat plugin Studio. Jangan menimpa biner yang sedang terbuka; bridge memperbarui objek editor, lalu Studio menyimpan file.

Panduan operasional utama ada di **[WARNET-CEPAT.md](WARNET-CEPAT.md)**. Dokumen itu mencakup persiapan PC baru, posisi terminal, pembaruan sebelum edit, pengujian dan penyimpanan Studio, commit/push sebelum pindah PC, arti SHA256, serta penanganan gangguan. Ikuti satu panduan tersebut agar instruksi tidak berbeda antarberkas.

Alur ringkas: **clone sekali → jalankan script mulai → buka WORKING → edit dan uji → Stop dan Save to File → jalankan script selesai → pastikan push berhasil → pindah PC**.

## Batas sumber kerja dan penelitian

- Sumber kerja: `places/RobloxLearningMedia-WORKING.rbxl` di dalam clone. Arsip di luar clone tidak menjadi file harian.
- Baseline penelitian pendahulu `../RobloxLearningMedia-BACKUP.rbxl` tetap menjadi pembanding lokal; jangan diedit atau dikirim sebagai hasil pengembangan.
- `src/`, `src copy/`, dan `default.project.json` merupakan arsip percobaan migrasi. Kandidat `migration-v2/` belum menggantikan WORKING sebelum lulus pemeriksaan Play terpisah. Lihat [catatan migrasi](MIGRASI_ROJO_V2.md).
- Catat tanggal, PC, perubahan, hasil Play aktual, dan commit sesi. File binary tidak dapat digabung otomatis ketika dua PC mengedit secara bersamaan.
- Versi A dan B untuk eksperimen dibekukan terpisah setelah siap; jangan mengubah versi perlakuan di tengah pengumpulan data. Sinkronisasi file bukan bukti kelayakan atau keberhasilan eksperimen.
- GitHub menyimpan commit yang sudah berhasil di-push. Perubahan di Studio yang belum Save to File, atau commit lokal yang belum di-push, belum tersedia di PC lain.
