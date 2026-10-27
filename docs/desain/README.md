# Snapshot rancangan Roblox untuk dibaca AI

Snapshot sumber lokal: **27 Oktober 2026**. Berisi155gambar:149low-fi +3userflow +3contohhi-fi, disertai storyboardteks dan bank isi. Seluruh salinan sumber dicatat pada [manifest](manifest-sumber.json) dengan SHA256. File sumber akademik di luar repo tidak diubah.

Ini salinan file rancangan lokal yang sudah dipakai pada pekerjaan desain, bukan ekspor ulang Google Docs saat ini. Jangan menganggap gambar sebagai screenshot implementasi atau bukti Play. Pembaruan Docs tidak otomatis masuk folder ini. Sumber/izin akses dijelaskan pada [ACUAN-DESAIN.md](../ACUAN-DESAIN.md).

## Mulai dari flow global

Urutan: spawn → sambutan → panduan → Level1 → Level2 → Level3 → aula/ringkasan/medali → pilihanopsional. Perpindahan objek mengharuskan pemain berjalan; pergantian bagianbacaan/klip/ronde dapat tetap pada panel/objek yang sama.

| Acuan | Isi |
| --- | --- |
| [UF-01](ringkasan-visual/userflow-01.png) | Pembuka dan Level1, materi/latihan/evaluasi serta retry |
| [UF-02](ringkasan-visual/userflow-02.png) | Level2 danLevel3 |
| [UF-03](ringkasan-visual/userflow-03.png) | Aula, medali dan kegiatanopsional |
| [Keterangan visual](ringkasan-visual/ISI-DOCS.md) | Caption dan batas interpretasi keenamcontoh |

## Pilih storyboard yang sedang dikerjakan

| Bagian | Narasi dan gambar | Data/aturan pendamping |
| --- | --- | --- |
| Pembuka/Level1 | [STORYBOARD](storyboard-pembuka-level1/STORYBOARD.md) | [JSON](storyboard-pembuka-level1/storyboard.json), [isi evaluasi](storyboard-pembuka-level1/isi-evaluasi.json) |
| Aksesgedung | [ATURAN-AKSES](akses-gedung/ATURAN-AKSES.md) | Gambar pada folderyangsama |
| Level2 | [STORYBOARD](storyboard-level2/STORYBOARD.md) | [JSON](storyboard-level2/storyboard.json), [isi sumber](storyboard-level2/isi-sumber.json) |
| Level3 | [STORYBOARD](storyboard-level3/STORYBOARD.md) | [JSON](storyboard-level3/storyboard.json), [isi sumber](storyboard-level3/isi-sumber.json), [spesifikasi latihan2](storyboard-level3/LATIHAN-2-SPESIFIKASI.md), [bank empat ronde](storyboard-level3/bank-ronde-editor.cjs) |
| Aula | [STORYBOARD](storyboard-aula/STORYBOARD.md) | [JSON](storyboard-aula/storyboard.json) |
| Bonus | [STORYBOARD](storyboard-bonus/STORYBOARD.md) | [JSON](storyboard-bonus/storyboard.json) |

Bank `.cjs` adalah data/acuan authoring rancangan, bukan script yang langsung dipasang pada Roblox. Tidak perlu menjalankan generator untuk membaca flow atau melakukan setupwarnet.

## Gaya tampilan

Gunakan panel existing: krem `#F4DDCD`, bingkai `#D19C74`, teks `#472003`, judulpita dan tombolmerahbata. Contohkonsep: [audioLevel1](ringkasan-visual/hifi-audio-level1.png), [buktiLevel2](ringkasan-visual/hifi-bukti-level2.png), [editorLevel3](ringkasan-visual/hifi-editor-level3.png). Latar pada hi-fi ilustratif, bukan koordinat map; denah storyboard dan posisi aktual Studio menjadi acuan penempatan.

## Checklist pemahaman sebelum mengubah satu aktivitas

- Sebut kode layar dan lokasi objek; bedakan objekexisting dengan tambahannya.
- Jelaskan apa yang dilihat/dilakukan pemain, respons panel, syaratakses, kondisi selesai dan tujuanselanjutnya.
- Periksa tutup/bukaulang, salah, bantuan, retry dan progres yang harusdipertahankan.
- Cocokkan stimulus/kunci/skor dengan bankisi. Materi/tujuan/skor tidak diganti untuk mempermudah coding.
- Periksa keberadaan kode/asetdiStudio; jangan menganggap flow tergambar sudah diimplementasikan.
- Catat hasilimplementasi/uji pada logpengembangan dan perbarui konteks.

Prioritas sprint tetap Level1utuh; aula/foto/bonus tidak mendahului alurbelajarutama. Saat ini seluruh gambar dalam folder ini berstatus **rancangan**.
