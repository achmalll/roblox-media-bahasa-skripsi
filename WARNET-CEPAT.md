# Panduan kerja Roblox: laptop, PC warnet, dan pindah warnet

Diperbarui: 25 Oktober 2026.

**Setiap sesi: tarik pembaruan → buka WORKING → edit → uji Play → Stop → Save to File → commit dan push berhasil → baru pindah PC.**

Panduan utama di repository adalah `WARNET-CEPAT.md`. File dengan nama sama di folder dokumen skripsi merupakan salinan pendamping; samakan keduanya ketika panduan diperbarui.

File utama game selalu `places/RobloxLearningMedia-WORKING.rbxl` di dalam clone repository. File `.rbxl` menyimpan isi place, termasuk map, objek, UI, dan script. Setelah edit disimpan ke file ini, Git dapat menyimpan versinya dan mengirimkannya ke GitHub. Path lengkap berbeda pada setiap PC.

## 1. Pertama kali memakai PC atau warnet baru

Pastikan Git, Roblox Studio, internet, dan akses akun GitHub ke repository private tersedia. Akun Roblox digunakan di Studio. Untuk alur place utuh, Rojo, Argon, Node, dan plugin sinkronisasi tidak wajib.

Buka PowerShell di folder kerja yang diizinkan PC tersebut:

```powershell
git clone https://github.com/achmalll/roblox-media-bahasa-skripsi.git
cd roblox-media-bahasa-skripsi
```

Jika diminta login, gunakan autentikasi GitHub yang tersedia. Jangan menaruh token/password dalam perintah atau repository. Jika clone sudah ada, gunakan folder itu; tidak perlu clone ulang. Jika komputer direset/deep-freeze dan folder hilang, clone lagi.

Jika commit meminta identitas penulis, atur untuk repository ini saja:

```powershell
git config --local user.name "Nama Anda"
git config --local user.email "Email GitHub Anda"
```

Ganti contoh isian dengan identitas yang sesuai; email noreply GitHub dapat dipakai sesuai pengaturan akun. Ini identitas commit, bukan pengganti login.

## 2. Sebelum mengedit: tarik versi terbaru

Pastikan pekerjaan PC sebelumnya sudah disimpan dan berhasil di-push. Tutup WORKING di Studio sebelum menarik pembaruan. Jalankan dari **folder utama repository**, yaitu folder yang berisi `scripts`, `places`, dan `README.md`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\mulai-warnet.ps1
```

Script memeriksa file, menolak pull jika WORKING mempunyai perubahan lokal, menarik pembaruan dengan fast-forward, lalu mencetak path file, SHA256, dan status Git. Jika berhenti karena error, selesaikan penyebabnya sebelum melanjutkan dari salinan yang belum jelas.

**Jika terminal terlanjur berada di folder `places`**, gunakan satu tingkat ke atas:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ..\scripts\mulai-warnet.ps1
```

Setelah berhasil, buka Roblox Studio → **Open from File** → pilih WORKING pada path yang dicetak. Opsi `-OpenStudio` pada script bisa dipakai jika asosiasi file `.rbxl` tersedia.

## 3. Saat mengedit dan menguji

1. Edit map, UI, atau script sesuai rancangan dalam mode edit Studio.
2. Simpan berkala menggunakan **Save to File** ke WORKING di dalam clone.
3. Jalankan Play untuk memeriksa perubahan. Catat apa yang dicoba, hasil aktual, dan pesan Output jika ada.
4. Tekan **Stop** sebelum menyimpan hasil akhir. Perubahan yang hanya dilakukan pada simulasi Play jangan dianggap otomatis menjadi perubahan permanen pada mode edit.

Save to File memperbarui file lokal yang dilacak Git. Publish ke Roblox adalah tindakan terpisah dan tidak menggantikan Save to File atau push GitHub. Helper tidak menekan tombol Save di Studio.

Jangan memakai WORKING arsip di luar clone atau hasil `migration-v2/build/` sebagai file kerja harian. `src/`, `src copy/`, dan `default.project.json` adalah arsip percobaan migrasi; jangan menjalankan build konfigurasi lama di atas WORKING.

## 4. Sebelum pulang atau pindah PC: simpan dan kirim

Di Studio: **Stop → Save to File → WORKING yang sama**. Dari folder utama repository:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\selesai-warnet.ps1 -Message "Level 1: tambah kontrol tiga klip audio"
```

Ganti pesan dengan pekerjaan yang benar-benar dilakukan. Jika terminal masih di `places`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ..\scripts\selesai-warnet.ps1 -Message "Level 1: tambah kontrol tiga klip audio"
```

Script men-stage hanya WORKING, membuat commit bila berubah, lalu push dan memeriksa tidak ada commit lokal tertinggal serta WORKING tidak berubah lagi. Jika file lain sudah di-stage, script berhenti agar file itu tidak ikut dalam commit WORKING. Push tetap mengirim seluruh commit cabang yang belum terkirim; tinjau commit terpisah bila ada pekerjaan lain.

**Sesi selesai setelah script berakhir tanpa error dan menampilkan “Commit lokal sudah terkirim”.** Jika file berubah lagi sesudahnya, simpan dan jalankan script selesai lagi. Bila hanya mencoba tanpa mengedit, tidak perlu membuat commit; script juga tidak membuat commit kosong.

Catat di log pengembangan yang digunakan:

```text
Tanggal / PC:
Perubahan:
Play yang dicoba dan hasil aktual:
Masalah yang belum selesai:
Commit terakhir:
Push: berhasil / belum berhasil
```

Lihat commit terakhir dengan `git log -1 --oneline`. Jangan mengisi hasil Play sebagai lulus jika belum dicoba.

## 5. Pindah PC, pindah warnet, atau kembali ke laptop

| PC sebelumnya | PC berikutnya |
| --- | --- |
| Stop, Save to File, jalankan script selesai, pastikan push berhasil. | Clone jika belum ada; gunakan clone yang ada jika tersedia. Jalankan script mulai, lalu buka WORKING. |

Jangan mengedit file game yang sama bersamaan di dua PC. `.rbxl` adalah binary; dua versi edit tidak dapat digabung otomatis seperti baris kode. Setelah push berhasil, commit terbaru dapat di-pull di PC mana pun yang berwenang.

Pada PC umum, keluar dari akun Roblox, GitHub di browser, serta akun/kredensial Git yang tersimpan sebelum meninggalkan PC. Pastikan pekerjaan sudah terkirim sebelum folder sementara dibersihkan atau komputer direset. Jangan menyalin kredensial ke flashdisk.

## 6. Memahami output

| Output | Arti dan tindakan |
| --- | --- |
| `File utama: ...WORKING.rbxl` | Path file yang harus dibuka dan disimpan pada PC tersebut. |
| `SHA256: ...` | Sidik jari isi file. Isi sama menghasilkan hash sama; perubahan hash setelah edit dan simpan normal. Tidak dimasukkan ke Studio. |
| `## main...origin/main` tanpa `ahead/behind` | Commit lokal sejajar dengan referensi remote yang terakhir diambil. Setelah pull/fetch berhasil, ini membantu memeriksa sinkronisasi. |
| `M places/RobloxLearningMedia-WORKING.rbxl` | File game berubah lokal; selesaikan save, commit, dan push sebelum pindah. |
| `M default.project.json` | Konfigurasi migrasi berubah lokal. Pada laptop saat panduan dibuat ini memang dipertahankan; helper tidak memasukkannya ke commit WORKING. Jangan membuangnya sembarangan. |
| `ahead`, `behind`, atau error Git | Ada commit belum terkirim/diambil atau proses gagal; sinkronisasi belum dinyatakan selesai. |

Hash sama tidak membuktikan game bebas bug. Play, audio, dan izin aset tetap diperiksa pada PC tujuan. Fitur storyboard baru belum otomatis terpasang hanya karena clone/pull berhasil.

## 7. Jika ada kendala

| Kendala | Langkah |
| --- | --- |
| `scripts/mulai-warnet.ps1` tidak ditemukan | Periksa posisi terminal. Dari `places` gunakan `..\scripts\...`; dari folder utama gunakan `.\scripts\...`. |
| Git tidak dikenali | Siapkan Git, lalu buka ulang PowerShell. Helper juga mendukung Git portable pada `../tools/PortableGit/cmd/git.exe` relatif terhadap folder utama repository. |
| Clone/pull/push meminta login atau ditolak akses | Pastikan akun GitHub yang dipakai mempunyai akses repository private; gunakan login yang tersedia. |
| Mulai ditolak karena WORKING berubah | Jangan pull paksa. Pastikan asal perubahan, simpan, dan kirim pekerjaan yang masih sah sebelum menarik versi lain. |
| Push gagal karena internet | Save to File dan buat salinan WORKING bertanggal pada media pribadi yang dapat dibawa; simpan seluruh clone jika ada commit belum terkirim. Setelah koneksi pulih, jalankan script selesai lagi. PC lain belum mempunyai pekerjaan terbaru sebelum push berhasil. |
| Push ditolak karena remote lebih baru / riwayat berbeda | Cadangkan pekerjaan lokal dan pertahankan clone. Jangan force-push, reset, atau pull/rebase sembarangan. Bandingkan kedua versi dan pindahkan perubahan yang diperlukan melalui Studio sebelum menetapkan satu versi untuk diteruskan. |
| PC lama tidak bisa diakses dan pekerjaan belum di-push | Gunakan cadangan terakhir jika ada. Perubahan yang hanya tersimpan pada PC lama tidak dapat diambil dari GitHub. |

Mode `-Offline` pada script mulai melewati pull dan tidak memastikan versi terbaru. Pakai hanya bila jelas salinan itu sumber pekerjaan terakhir. Opsi `-CheckOnly` pada script mulai/selesai hanya memeriksa file dan status tanpa pull, commit, atau push; opsi itu bukan pengganti sinkronisasi.

## Pemeriksaan sebelum meninggalkan warnet

- [ ] Play dihentikan dan hasil edit disimpan ke WORKING dalam clone.
- [ ] Script selesai berakhir tanpa error; commit lokal sudah terkirim.
- [ ] Perubahan dan hasil Play aktual dicatat.
- [ ] Jika pengiriman gagal, cadangan sudah dibawa dan pekerjaan belum dianggap sinkron.
- [ ] Akun pada PC umum sudah dikeluarkan.
