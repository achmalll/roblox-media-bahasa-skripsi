# Migrasi Rojo v2

Status 25 September 2026: migrasi ulang memakai **Rojo 7.7.0 `syncback`** sudah menghasilkan proyek yang dapat dibangun. `places/RobloxLearningMedia-WORKING.rbxl` tidak ditimpa dan tetap menjadi baseline sampai hasil build dibuka serta diuji Play di Roblox Studio.

## Struktur yang dipakai

- `migration-v2.syncback.project.json`: konfigurasi semua service utama dan aturan syncback.
- `migration-v2/src/`: source hasil ekstraksi dari WORKING.
- `migration-v2/src/StarterPlayer/StarterPlayerScripts/`: 17 script utama berbentuk `.luau` dan dapat diedit/diff di Git.
- `migration-v2/src/ServerScriptService/`: enam server script berbentuk `.luau`.
- GUI, bangunan, terrain, dan aset kompleks disimpan sebagai `.rbxm`. Ini menghindari kehilangan data dan masalah nama instance yang duplikat.
- `migration-v2/build/`: hasil build lokal; diabaikan Git dan harus dibuat ulang.
- `src/` dan `src copy/`: arsip percobaan Argon/Rojo lama. Jangan dipakai sebagai proyek build baru.

## Hasil verifikasi statis

| Pemeriksaan | WORKING | Build migration-v2 |
|---|---:|---:|
| Instance pada header | 22.843 | 22.790 |
| Script | 1.093 | 1.093 |
| Teks GUI | 161 | 161 |
| Perbedaan path/hash isi script | – | 0 |

Selisih 53 instance berasal terutama dari service internal Studio yang tidak didefinisikan sebagai isi proyek. Perbedaan konten yang teridentifikasi ialah `Debris` sebagai service internal dan satu `StringValue` dari artefak `ReplicatedStorage/TestArgon` pada percobaan lama. Semua 1.093 script memiliki path dan hash source yang sama; jumlah teks GUI juga sama. Verifikasi ini belum membuktikan perilaku runtime, audio, tampilan, referensi objek, dan aset secara visual.

## Menyiapkan komputer

Versi dikunci pada `rokit.toml`:

```toml
rojo = "rojo-rbx/rojo@7.7.0"
```

Pasang Rokit dan jalankan `rokit install`, atau pasang binary resmi Rojo 7.7.0. Pastikan `rojo --version` menampilkan `Rojo 7.7.0`. Plugin Studio harus memakai versi yang kompatibel.

## Membuat place dari source

Dari PowerShell di root repository:

```powershell
.\scripts\build-migration-v2.ps1
```

Hasil default berada di `migration-v2/build/RobloxLearningMedia-MIGRATION-V2.rbxl`. Buka hasil itu di Studio dan uji tiga level. Jangan mengganti WORKING sampai pemeriksaan Studio selesai.

## Menarik perubahan Studio kembali ke source

Simpan lebih dulu place hasil edit ke file terpisah. Lihat pratinjau perubahan:

```powershell
.\scripts\syncback-migration-v2.ps1 -InputPath "path\ke\file-hasil-edit.rbxl"
```

Perintah tersebut hanya menampilkan file yang akan ditulis/dihapus. Jika daftarnya sesuai, terapkan:

```powershell
.\scripts\syncback-migration-v2.ps1 -InputPath "path\ke\file-hasil-edit.rbxl" -Write
```

Sesudah syncback, build ulang, buka hasil build, dan cek `git status` sebelum commit. Jangan memakai `-Write` bila pratinjau menunjukkan file di luar bagian yang sengaja diubah.

## Gerbang sebelum migrasi dinyatakan selesai

1. Build migration-v2 terbuka tanpa error di Studio.
2. Ketiga level, dua audio Level 1, materi Level 2–3, 12 soal, skor, lulus/ulang, progres, dan ringkasan berjalan.
3. Tidak ada objek/aset penting hilang atau berpindah.
4. Siklus source → build → edit kecil di Studio → syncback pratinjau/tulis → build ulang berhasil.
5. Hasil uji dilakukan pada setidaknya satu PC pengembangan; sesudah itu clone/pull dan build diuji pada PC kedua.

Sampai lima gerbang itu lulus, statusnya adalah **migrasi teknis berhasil dibangun dan lolos perbandingan statis; validasi Studio belum selesai**.
