# Log perubahan dan serah-terima development

Catat setiap rangkaian perubahan sebelum mengakhiri sesi atau commit. `KONTEKS-AI.md` menyimpan keadaan terbaru; file ini menyimpan rincian perubahan dan buktinya. Gunakan tanggal aktual dan hasil yang benar-benar diketahui. Jangan menyalin seluruh riwayat chat.

## 27 Oktober 2026 — aturan pembaruan konteks dan paket acuan desain

- **Permintaan:** pengguna mewajibkan pembaruan konteks untuk setiap perubahan, menginginkan konteks cukup rinci, dan menanyakan file/link rancangan serta akses akun yang perlu disiapkan untuk AI.
- **Kondisi awal:** commit game `e3360cb` dan setup `d998b91` sudah dikirim; WORKING hash `a4e910246c70993a0fb90cfb9e73150412664a88d14d79f25dc0626a380c9eef`. Hanya `default.project.json` berubah lokal lama, dipertahankan. Play lengkap dan MCP belum dinyatakan lulus.
- **Perubahan:** aturan AGENTS diperjelas menjadi wajib mencatat setiap perubahan, tidak hanya perubahan material. Ditambahkan peta `docs/ACUAN-DESAIN.md`, indeks/snapshot `docs/desain/`, dan logini. Brief, README serta panduanwarnet diberi penunjuk sumber dan kewajiban pencatatan.
- **Alasan:** AI di clonewarnet perlu aturan, status, flow/gambar, bankisi dan jejak pekerjaan; ringkasan tujuan saja tidak cukup untuk menerapkan interaksi dengan benar. Loginbrowser tidak otomatis memberikan akseskonektorAI.
- **Sumber:** filelokal `docs/pengembangan` pada workspace skripsi, handoff dan konteks27Oktober. Snapshot mencakup149low-fi +3userflow +3hi-fi serta narasi/bankisi. Tidak membacaulang live Docs dan tidak mengubah sumberasli, sharing, materi, skor atau tujuan.
- **Pemasangan:** perubahan hanya dokumentasi dan salinan rancangan di repo. Tidak ada perubahan sourcegame, map, GUIatau WORKING. Semua gambar tetap rancangan; bukan buktiimplementasi.
- **Pemeriksaan aktual:** seluruh172file sumber cocok SHA256, jumlahgambar155, sembilanJSON berhasil diparse. Tautanlokal pada12Markdown yang diperiksa tidak rusak; `git diff --check` lulus. Rincian pada `docs/desain/verifikasi-snapshot.json`. Hasil Play/MCP: belum diuji pada sesiini.
- **Temuan saat staging:** pemeriksaan staged mendeteksi satu bariskosong tambahan di akhir `ringkasan-visual/ISI-DOCS.md` sumber. Salinan sengaja dipertahankan identikhash; pemeriksaan staged dilakukan dengan `core.whitespace=-blank-at-eof` untuk pengecualian EOF tersebut, tanpa mengabaikan jenis kesalahan whitespace lain. Tidak terkait buggame atau hasilPlay.
- **Bukti:** `docs/desain/manifest-sumber.json`; linkDocsdan urutanbaca pada `docs/ACUAN-DESAIN.md`. Snapshot auditsetup lama tetap pada `docs/development/2026-10-27/`.
- **Masalah/sisa:** Docs dapat berubah sesudahsnapshot; perlu pembaruanterarah bilaada keputusanbaru. PCwarnet dan koneksiAI belum diuji. Baselinefungsi/audio/kuis/skor/akses tetap perlu Play.
- **Langkahberikut:** pada PCbaru baca aturan/brief/entriterakhirlog → indeksdesain → storyboardLevel1 relevan → cekWORKING/Studio → kerjakan satuaktivitas sesuai target sesi.
- **Versi/sinkronisasi:** commit acuan game `e3360cb`, setup `d998b91`. Commit dokumentasi sesiini dilaporkan setelah selesai dan diverifikasi; jangan mengisi statuspush berdasarkan rencana. Konfigurasipengguna di luar cakupan.

## Template entri berikutnya

```text
Tanggal / PC (bila diketahui) / tujuan sesi:
Permintaan pengguna dan kondisi awal:
File atau path objek berubah:
Perubahan per bagian + alasan + acuan layar/sumber:
Status: rancangan / source disiapkan / terpasang pada WORKING:
Langkah uji → hasil aktual → error/bug:
Bukti gambar/log dan lokasinya:
Versi/hash WORKING atau commit acuan:
Commit/push: belum / berhasil terverifikasi / gagal + penyebab:
Yang belum dikerjakan / sumber atau keputusan yang belum tersedia:
Langkah berikutnya dan tindakan Studio pengguna:
Ringkasan KONTEKS-AI.md sudah diselaraskan:
```
