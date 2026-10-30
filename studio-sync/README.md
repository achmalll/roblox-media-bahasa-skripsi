# Codex ↔ Studio lokal, versi 1

Untuk paketflashdisk, [PAKAI-FLASHDISK.md](../PAKAI-FLASHDISK.md) dan `MULAI-PORTABLE.cmd` menyiapkan Git/Node dari `../tools`. Resolver menolak Node tanpa ZSTD dan memilih runtimeportable lebih dahulu. Bridge tetap berjalan perPC; helper memasangplugin dan memeriksa identitasclone, tidak otomatis Play/Save/publish. `SELESAI-PORTABLE.cmd` memverifikasiSave, cadangan, reviewcommit/push dan penghentianPID terverifikasi.

## Instruksi untuk AI pada sesi baru

Untuk tugas Roblox, jangan berhenti setelah membaca status proyek. Dari root clone, jalankan `CONNECT-STUDIO.cmd`, pastikan Studio membuka `places/RobloxLearningMedia-WORKING.rbxl`, lalu verifikasi bridge online, mode Edit, dan source terkelola sinkron sebelum mengedit. Pada PC baru, helper memasang atau memperbarui plugin lokal; clone Git sendiri tidak dapat memasang plugin ke profil Roblox Studio.

Koneksi yang berhasil bukan izin untuk otomatis menjalankan Play, Save, publish, membuat objek, atau memperluas cakupan perubahan. Ikuti permintaan pengguna dan catat hasil verifikasi aktual. Jika bootstrap gagal, jangan menimpa WORKING lewat patch biner sebagai jalan pintas.

Status 28 Oktober 2026: implementasi dan uji nyata satu PC berhasil. Script yang dikelola baru **Level1Handler**; properti yang dikelola baru **HoldDuration** dua prompt pada project.json. Objek/map tetap diedit di Studio. Tidak mengubah source arsip atau membangun ulang place.

## Mulai pada PC ini atau PC baru

1. Clone/pull repo yang sudah memuat file bridge dan WORKING terbaru. Tutup sesi penulis di PC lama setelah Stop, Save, commit/push yang terverifikasi. Jangan edit biner di dua PC bersamaan.
2. Klik dua kali `CONNECT-STUDIO.cmd` di root repo. Helper mencari Node dari PATH atau runtime Codex lokal, membuat plugin dari source repo, menyalin plugin ke folder lokal Studio bila versinya berbeda, dan menjalankan server tersembunyi di 127.0.0.1:34873. Tidak mengubah kebijakan PowerShell permanen.
3. Jika plugin baru dipasang/diperbarui: simpan pekerjaan lalu buka ulang Studio. Buka `places/RobloxLearningMedia-WORKING.rbxl` dari clone itu. Jangan buka salinan cloud/arsip untuk kerja harian.
4. Tanggapi sendiri izin koneksi localhost/akses script jika diminta Studio. Jangan mengubah game settings untuk setup bridge.
5. AI/perintah file membaca `local-rbxl/bridge/status.json`: online=true, gameName=WORKING dan script status=synced_in_editor. Timestamp lastSeen harus segar. Server mengecek clone pada port yang sama; satu koneksi Studio aktif pada satu waktu.

Clone tidak dapat otomatis mendaftarkan plugin ke aplikasi desktop. Setup per PC tetap diperlukan, tetapi ditangani helper; tidak perlu mengedit path/kode game. Node, Studio/login, izin plugin dan kebijakan warnet tidak dibawa Git. Jika runtime Node tidak ditemukan, helper berhenti dengan pesan; runtime belum dibundel atau diunduh otomatis. Pengujian PC kedua belum dilakukan. Server harus dijalankan kembali setelah logout/reboot.

`install-studio-bridge.ps1` hanya memperbarui file plugin milik bridge ini, mencadangkan versi lama bila berbeda. `start-studio-bridge.ps1` menguji /health agar tidak menjalankan dua server untuk clone yang sama. Ia menolak port yang dipakai clone berbeda. Jangan menjalankan default.project.json/migration-v2 sebagai live sync bersamaan.

## Edit rutin

AI mengedit `studio-sync/src/Level1Handler.client.luau`. Server mendeteksi perubahan file, membandingkan source snapshot/Studio/lokal, lalu plugin memakai ScriptEditorService.UpdateSourceAsync dengan compare-and-set. Kode tidak dieksekusi di host. Edit melalui editor Studio dapat diimpor kembali jika source lokal tidak berubah; jika keduanya berubah, source lokal dipertahankan dan salinan Studio disimpan sebagai *.studio-conflict.luau. Status conflict membutuhkan penyelesaian, bukan overwrite otomatis.

Perubahan lokal tidak menulis WORKING. Setelah status editor sinkron: Play uji → Stop → Ctrl+S di WORKING. AI memverifikasi hasil simpan dengan `node scripts/verify-studio-save.cjs`. Verifikasi ini membaca file disk dan mencocokkan source; bukan hasil Play otomatis. Bila folder berada di System32, sandbox Codex mungkin meminta izin baca file yang baru disimpan Studio; jangan mengubah ACL/setting keamanan untuk mengatasinya.

Source tersinkron bukan berarti sudah lolos compiler atau Play. V1 belum mempunyai lint Luau dan Save otomatis. Isi latihan/evaluasi tidak diubah tanpa cakupan permintaan. Tidak ada operasi generik untuk membuat/menghapus objek/UI pada v1.

Untuk perubahan HoldDuration, AI menaruh JSON perintah pada `local-rbxl/bridge/requests/NAMA.json`:

```json
{
  "id": "contoh-hold-latihan",
  "op": "set_property",
  "instancePath": ["Workspace", "Level1Development", "L1_PapanLatihan", "Animation 2", "ProximityPrompt"],
  "className": "ProximityPrompt",
  "property": "HoldDuration",
  "before": 0,
  "value": 1
}
```

`before` harus nilai aktual yang dibaca dari status terbaru. Jika sudah sama dengan value, plugin memberi already_applied. Jika berubah ke nilai lain, plugin menolak konflik. ID harus unik untuk perubahan berbeda. Receipt ada pada receipts/ID.json; jangan menyatakan sukses dari file request saja. Request bersifat lokal dan tidak dibawa Git; setelah restart server request lama dapat diperiksa ulang secara idempoten.

## Pengaman dan pemulihan

- Localhost saja, header khusus tanpa CORS, token acak dalam memori per proses, satu session aktif, allowlist target/properti, path anak harus unik, compare-and-set, cache receipt idempoten dan waypoint Undo Studio.
- Play/Run/paused ditentukan dari StudioTestService.EditModeActive dan RunService; antrean tertahan sampai kembali ke Edit. IsRunning saja terbukti tidak cukup pada Edit DataModel saat Play Solo.
- Bridge tidak menjalankan loadstring, shell, Source game, atau operasi hapus. Tidak membuat script loader di place. Plugin berada di folder plugin PC dan source-nya di repo.
- Jika konflik/error, hentikan edit target, simpan kedua versi dan baca receipts/status. Jangan menimpa WORKING dari kandidat biner untuk memaksa sinkron.
- Tombol Connect pada toolbar Codex Local menonaktifkan/mengaktifkan koneksi. Saat server dimulai ulang plugin berpasangan kembali. Jika plugin diperbarui, restart Studio setelah Save.
- Untuk mematikan server, tutup hanya proses Node milik bridge yang PID-nya dicetak helper; jangan menghentikan seluruh proses Node/Codex.

## Uji yang sudah dilakukan

- Fixture controller HTTP: identitas proyek, Origin/token ditolak, satu session, kirim ulang idempoten, source compare-and-set, konflik dua sisi tidak menimpa lokal, antrean saat Play. `node scripts/test-studio-bridge.cjs`.
- Studio live: HoldDuration0→1 dengan receipt/readback; tambah komentar source lokal sementara → editor lalu pulihkan → editor kembali identik.
- Play: karakter diposisikan sementara di depan papan, native InputHoldBegin/End digunakan untuk simulasi tahan; modal latihan terbuka dan Tutup bekerja. Log setelah penundaan observasi0,3detik mencatat elapsed1,316… dan visible=true; ini bukan pengukuran waktu tombol fisik E terpisah.
- Versi guard pertama memakai IsRunning saja dan gagal mendeteksi Play dari Edit DataModel. Diperbaiki; uji ulang menunjukkan running=true, request read_property tertahan queued ketika Play, diproses setelah Stop dengan value1.
- Save melalui Studio ke WORKING, ekstraksi ulang source cocok, semua sembilan prompt1detik; buka ulang WORKING dan Play berhasil. SHA256 hasil Save: 57eb2fbae3c18d7574837d856758d09299ba56eb764746345c959dfbc06666f2, 2.698.703 byte.

Kuis, audio, seluruh logic latihan dan level lain belum diuji pada sesi bridge. Bentuk latihan existing masih berbeda dari storyboard; pemasangan bridge tidak memperbaiki ketidaksesuaian itu.

## Pembaruan 30 Oktober 2026
Target source terkelola kini dua: Level1Handler dan ArrowGuideScript existing. ArrowModel existing tetap digunakan, tujuan Level1 dibagikan melalui atribut client L1GuideTarget/Label/Stage. verify-studio-save.cjs mengikuti project.json dan memeriksa kedua source; receipt editor tetap harus diikuti Save/Play terpisah.

Pembaruan lanjutan30Oktober: empat targetexisting dikelola (duaLocalScript diatas, ServerScriptService/Level1ScoreHandler danLevelProgressHandler). PengujianSave mengikuti keempattarget; sourceScoreL1 juga menstabilkan kios saat startupserver. Tetap butuh ujiPlay terpisah.

## Dukungan objek Level 2 (30 Oktober 2026, perlu reload plugin)
Plugin kini menyediakan inspect_workspace (inventaris model/folder/teks/prompt, maksimum 5000), create_folder khusus Workspace/Level2Development, move_instance ke folder itu dengan objectMoves allowlist pada project.json, serta Text pada TextLabel/TextButton di Workspace dengan properties allowlist dan compare-and-set. Target harus diinventarisasi sebelum mengisi allowlist; jangan memindahkan objek Level 1 asli. Perubahan project.json memerlukan restart server/re-pair; perubahan plugin perlu Save/reload Studio. Dukungan baru baru lulus fixture controller, belum uji Studio. Batas v1 lama di atas adalah riwayat.

Perbaikan berikut30Oktober (perlu reloadplugin): resolve memeriksa keunikan endpoint seluruhpath, sehingga sibling Sign yang berbeda keturunannya dapat dibedakan. move_instance mendukung newName hanya nilaiyang disetujui objectMoves, menolak namatujuanbertabrakan. inspect_workspace memberi objectSummaries terbatas objekL2/targetmoves (parts/unanchored/script/prompt/pivot). Baru tescontroller, bukan bukti ujiStudio.

Targetsourcekelima: Level2FlowHandler existing, menambahkan3prompt/modal kosongruntime sambilmempertahankanflowbaseline. Saveverification mengikuti5target project.json. Promptruntime bukan instancepermanenEdit; Playperluujiuser.
