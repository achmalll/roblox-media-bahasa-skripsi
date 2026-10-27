# Bahan yang diberikan kepada AI agar memahami flow Roblox

Diperbarui 27 Oktober 2026. Ini peta sumber, akses dan urutan baca; bukan keputusan desain baru. Tujuan utamanya agar AI di PC warnet dapat memahami rancangan sebelum mengubah game.

## Paket minimum untuk chat baru

| Bahan | Untuk apa | Kapan dibaca |
| --- | --- | --- |
| [AGENTS.md](../AGENTS.md) | Aturan kerja, batas perubahan dan kewajiban memperbarui konteks | Setiap awal pekerjaan dalam repo |
| [KONTEKS-AI.md](../KONTEKS-AI.md) | Tujuan skripsi, keputusan tetap, progres aktual, hambatan, target dan langkah berikutnya | Diskusi maupun implementasi |
| [LOG-PENGEMBANGAN.md](LOG-PENGEMBANGAN.md) | Rincian perubahan, uji, bukti dan pekerjaan terbuka; baca entri terakhir dahulu | Sebelum melanjutkan pekerjaan |
| [Indeks rancangan](desain/README.md) | Flow global, tautan storyboard dan gambar acuan | Ketika membahas/mengerjakan game |
| Storyboard aktivitas yang dikerjakan | Urutan objek, isi panel, respons, syarat lanjut dan cabang salah/ulang | Hanya bagian yang relevan, tidak semua gambar sekaligus |
| [Panduan warnet tiga jam](../PANDUAN-WARNET-3-JAM.md) | Instalasi/login, clone/pull, MCP, jadwal kerja dan penutupan sesi | Saat masuk PC baru |

Untuk tugas pertama, baca storyboard Level1 bagian00 (denah),05A (objek papan) dan05B (panel penguatan), beserta bagian audio sebelum/sesudahnya agar gating tidak salah. Untuk tahap berikutnya baru buka latihan/evaluasi dan level yang terkait.

## Google Docs rancangan utama

**[Buka Docs rancangan — tab Desain layar dan kerangka ahli media](https://docs.google.com/document/d/1H6V69of2Y9FzAiecZ2L3JSsL21gK5BqmLlzJRbtZKb8/edit?tab=t.838lhhvpqegp#heading=h.y17deuhuu7oj).**

Mulai dari bagian **Userflow utama dan contoh tampilan** di atas: tiga userflow dan tiga contohhi-fi. Sesudahnya terdapat149low-fi rinci menurut catatan verifikasi27Oktober. Gunakan gambar untuk memahami posisi/keadaan layar, serta narasi perilaku untuk aturan interaksi. Desain tersedia tidak berarti kode sudah terpasang atau Play lulus.

Link ini bukan naskah akademik Production dan bukan izin untuk mengedit dokumen. Jangan mengubah Docs/komentar hanya karena memperoleh akses baca. Sesi penyusunan peta ini memakai sumber lokal dan handoff27Oktober; tidak mengklaim telah membaca ulang isi Docs secara live.

## Apakah perlu login akun Google?

- **Untuk kamu melihat Docs:** buka link di browser. Jika dokumen meminta akses, login dengan akun Google milikmu yang memiliki izin dokumen tersebut. Login Roblox, Codex dan GitHub adalah akses yang berbeda.
- **Untuk AI membaca Docs:** link saja belum menjamin akses. Bila AI mempunyai konektor Google Drive/Docs, konektor tersebut harus terhubung ke akun berizin dan berhasil membaca dokumen. Login di tab browser pengguna tidak otomatis memberikan akses itu ke tools AI.
- **Tanpa konektor:** gunakan salinan rancangan dalam repo. Alternatifnya, kamu dapat melampirkan ekspor PDF/gambar halaman yang relevan melalui chat. Jangan menempelkan password, token atau kode2FA.
- **AI tetap bisa mulai dari clone:** paket `docs/desain/` menyediakan narasi, bank isi, tigauserflow, tigahi-fi dan149low-fi lokal. Tidak perlu menunggu koneksi Docs untuk membaca snapshot itu. Akses Studio/MCP diperlukan ketika AI hendak memeriksa/mengubah sesi game, bukan untuk sekadar membaca rancangan.

## Mana yang menjadi acuan bila berbeda?

1. Instruksi terbaru dan keputusan yang dikonfirmasi pengguna.
2. Dokumen rancangan aktif beserta catatan koreksi terbaru yang benar-benar dibaca.
3. Snapshot repo bertanggal, dengan batas pembaruan yang dinyatakan.
4. Screenshot game dan kode/place aktual untuk menentukan apa yang telah diimplementasikan, bukan untuk otomatis mengganti tujuan rancangan.

Jangan menyelesaikan konflik materi/skor/tujuan diam-diam. Sebut bagian yang berbeda dan dampaknya. Folder desain tidak tersinkron otomatis dengan Docs; pembaruan disalin secara terarah dan dicatat, bukan membuat banyak versi aktif.

## Prompt siap salin

> Baca AGENTS.md, KONTEKS-AI.md, entri terakhir docs/LOG-PENGEMBANGAN.md, docs/ACUAN-DESAIN.md dan docs/desain/README.md. Untuk [diskusi/implementasi] kali ini fokus saya adalah [...]. Buka storyboard bagian yang relevan, sebutkan acuan layar dan ringkas flow, syarat lanjut, serta cabang salah/ulangnya. Gunakan Docs rancangan bila konektor punya akses; bila tidak, gunakan snapshot repo dan sebut tanggalnya. Bedakan rancangan dari kondisi WORKING. Setelah setiap perubahan, perbarui konteks serta log dengan hasil aktual dan langkah berikutnya.

Pada AI tanpa aksesfile, lampirkan brief + peta acuan + storyboard/gambar bagian yang ingin dibahas. Untuk diskusi umum, brief dan pertanyaan terbaru cukup; tidak perlu mengunggah seluruh149gambar. Untuk perubahan teknis, tambahkan hasil inventaris kode/Studio yang berkaitan agar AI tidak hanya menebak dari gambar.
