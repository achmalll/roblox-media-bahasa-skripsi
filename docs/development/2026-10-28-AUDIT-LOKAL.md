# Audit lokal RBXL — 28 Oktober 2026

## Sumber dan alat

WORKING aktual: `places/RobloxLearningMedia-WORKING.rbxl`, 2.698.673 byte, SHA256 `b64a9d970d55289d7eed0ec6521ae2345e777206909766e241edb5be08804245`. Dibaca dari filesystem melalui Node REPL, bukan source arsip atau sesi Studio. Node REPL menyediakan `node:zlib.zstdDecompressSync`; bundled workspace dependencies tidak dikonfigurasi pada PC ini.

`scripts/rbxl-local.cjs` membaca framing chunk, ZSTD/LZ4, serta Name/Source bertipe string. Properti lain tidak ditafsirkan atau diserialisasi. Acuan format: https://dom.rojo.space/binary.html (dokumentasi implementor rbx-dom, tidak resmi Roblox). Alat tidak menjalankan script game. Hasil ekstraksi lokal di `local-rbxl/2026-10-28/manifest.json`: 2.969 chunk; 18 LocalScript, 2 ModuleScript, 1.072 Script. Jumlah Script bukan jumlah fitur; mencakup script objek/map. Indeks per kelas bukan path instance. Folder local-rbxl diabaikan Git, dapat dibuat ulang dari hash sumber.

Pemakaian pada Node yang mendukung ZSTD:

```text
node scripts/rbxl-local.cjs extract places/RobloxLearningMedia-WORKING.rbxl local-rbxl/OUTPUT-BARU
node scripts/rbxl-local.cjs patch INPUT.rbxl OUTPUT-BARU.rbxl SPEC.json
```

Spec patch memuat inputSha256, class, classIndex, name, sourceSha256, sourceFile. Ambil identitas/hash dari manifest ekstraksi. Output wajib file baru. Alat mengganti satu nilai Source dalam satu PROP chunk, menyalin seluruh chunk lain mentah, kemudian membaca ulang dan membandingkan. Tidak membangun ulang map melalui parser properti Terrain. Alat ini terbatas untuk patch source existing, bukan penambahan UI/objek atau validasi runtime.

## Hasil uji aktual

- Ekstraksi seluruh Source berhasil; hash input tetap sama sebelum/sesudah.
- Patch tanpa perubahan menghasilkan kandidat identik byte/hash dengan WORKING.
- Probe menambah komentar pada Level1Handler hanya pada salinan: tepat satu Source chunk berubah; semua chunk lain identik. Kandidat `local-rbxl/probe-candidate.rbxl`, SHA256 `e667cf91b355760c7dfc8660b63a8e9c209fbf9daa526834decac9b7bd98b9e6`.
- Hash input salah ditolak. WORKING asli tetap hash di atas.
- Probe bukan perbaikan gameplay; belum dibuka di Roblox/Play. Tidak mengklaim engine menerima kandidat hanya dari keberhasilan pembaca sendiri.
- Percobaan impor langsung .cjs melalui dynamic import Node REPL ditolak; createRequire berhasil. Tidak perlu instalasi executable baru.

## Temuan Level1Handler aktual

Source diekstrak di `local-rbxl/2026-10-28/LocalScript/0001-Level1Handler.luau`.

1. Papan informasi dan latihan memang terdapat dalam source WORKING, bukan lagi hanya laporan Assistant. Kode menargetkan Level1Development, papanInfoFrame, latihanFrame dan prompt pada anak Animation 2. Keberadaan setiap target UI/prompt belum diinventaris seluruhnya dari biner.
2. Latihan memanggil resetLatihan setiap interaksi. Susunan/feedback tidak bertahan ketika ditutup lalu dibuka, bertentangan dengan storyboard 07B2/07B5.
3. Setelah jawaban salah, semua tombol dalam blok dinonaktifkan sehingga pemain tidak dapat memperbaiki pada sesi buka yang sama. Feedback langsung membocorkan jawaban; tidak mengikuti pemeriksaan dua tempat dan bantuan storyboard.
4. Bentuk latihan empat blok kategori berbeda dari storyboard 07B1: empat kartu, dua tempat, dua kartu tidak digunakan. Perbaikan lengkap memerlukan audit struktur UI serta atribut aktual, bukan sekadar memperbaiki satu kondisi benar/salah.
5. resetLatihan mengaktifkan tombol tetapi tidak memulihkan BackgroundColor3 dari warna benar/salah sebelumnya.
6. expectedAnswer dan selectedCategory dibandingkan tanpa memastikan atribut ada; dua atribut nil akan dianggap sama. Ini potensi cacat kode, belum bukti atribut aktual hilang.
7. Prompt/close intro mempunyai handler ganda. hideAll hanya mencakup empat frame lama; tidak mencakup papanInfoFrame/latihanFrame. Potensi tumpang tindih perlu diperbaiki setelah menelusuri interaksi modul animasi.
8. Pemutar masih memilih male/female dan membuka quiz langsung setelah audio. Tidak ada alur tiga klip Tutor1/Tutor2, gating audio ke latihan, atau kiosk pada handler ini. Script lain belum diaudit menyeluruh sehingga jangan mengklaim fitur tersebut pasti tidak ada di seluruh place.

## Pekerjaan berikut

Inventaris hierarki UI, teks/atribut tombol dan SoundId dari biner; audit penghubung script lain; cocokkan dengan storyboard 04–08. Baru siapkan perbaikan source dan kandidat RBXL yang terpisah, dengan hash dan diff setiap target. Validasi kode/runtime tetap diperlukan sebelum mengganti WORKING kanonis. Sesi ini membuktikan ekstraksi dan patch source lokal, belum menyelesaikan logika Level 1. Tidak commit/push/publish/Save Studio.
