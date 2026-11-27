// Distractor revisions for Roblox B. The reviewed source bank remains the baseline.
const { questions: baseline } = require('../docs/desain/storyboard-level3/isi-sumber.json');

const revisions = [
  {
    options: {
      A: {
        text: "Peningkatan throughput dan penurunan latensi sebagai tuntutan aplikasi.",
        message: "Keduanya menjelaskan tuntutan kinerja. Pergeseran model dikaitkan dengan perubahan perangkat keras."
      },
      B: {
        text: "Penyederhanaan serialisasi dan pemindahan data melalui referensi.",
        message: "Keduanya adalah ciri pendekatan yang diusulkan, setelah perubahan perangkat keras membuka peluang."
      },
      E: {
        text: "Penyederhanaan lapisan perangkat lunak pada aplikasi yang sudah di-porting.",
        message: "Hal ini muncul sebagai penjelasan hasil evaluasi, setelah model dirancang."
      }
    },
    reasons: {
      A: {
        text: "Abstrak mengaitkan pergeseran terutama dengan target throughput dan latensi aplikasi.",
        message: "Target kinerja disebut sebagai tuntutan. Peluang pergeseran dikaitkan dengan interkoneksi dan penyimpanan persisten."
      },
      B: {
        text: "Abstrak menyebut pengurangan serialisasi sebagai tren perangkat keras yang mendorong perubahan.",
        message: "Pengurangan serialisasi adalah bagian dari desain model yang diusulkan."
      },
      D: {
        text: "Abstrak menjadikan keberhasilan aplikasi yang di-porting sebagai alasan awal merancang model.",
        message: "Porting dipakai ketika mengevaluasi implementasi, setelah model dirancang."
      }
    }
  },
  {
    options: {
      A: {
        text: "Pengelolaan akses data persisten melalui jalur kernel yang lebih terpusat.",
        message: "Pendekatan yang diusulkan mengurangi keterlibatan kernel pada jalur akses data."
      },
      D: {
        text: "Pertukaran data antaraplikasi melalui penyalinan ke ruang alamat masing-masing.",
        message: "Abstrak menjelaskan mobilitas data memakai referensi yang tidak bergantung pada ruang alamat."
      }
    },
    reasons: {
      D: {
        text: "Abstrak menjelaskan pertukaran data dengan menyalin data ke ruang alamat setiap aplikasi.",
        message: "Abstrak justru menonjolkan penggunaan referensi yang tidak bergantung pada ruang alamat."
      }
    }
  },
  {
    options: {
      B: {
        text: "Karena penyimpanan persisten memerlukan lebih banyak serialisasi daripada media penyimpanan lama.",
        message: "Abstrak menjelaskan overhead model tradisional, tanpa menyatakan bahwa penyimpanan persisten menuntut lebih banyak serialisasi."
      },
      C: {
        text: "Karena tuntutan latensi yang lebih rendah berasal dari penyimpanan persisten saja.",
        message: "Abstrak membahas beberapa tren, termasuk interkoneksi, penyimpanan persisten dan pemisahan komputasi dari memori."
      },
      D: {
        text: "Karena keterbatasan utama terletak pada kurangnya dukungan bahasa pemrograman untuk aplikasi baru.",
        message: "Abstrak mengaitkan keterbatasan dengan lapisan kompatibilitas dan overhead, bukan dukungan bahasa."
      },
      E: {
        text: "Karena perangkat baru memerlukan penambahan lapisan kompatibilitas untuk memanfaatkan kinerjanya.",
        message: "Lapisan kompatibilitas yang dipertahankan justru ikut membatasi pemanfaatan perangkat keras modern."
      }
    },
    reasons: {
      A: {
        text: "Abstrak menganggap masalah utama berasal dari dukungan bahasa untuk aplikasi baru.",
        message: "Sumber mengaitkan masalah dengan kompatibilitas dan overhead model lama."
      },
      C: {
        text: "Abstrak membatasi perubahan kebutuhan performa pada penyimpanan persisten.",
        message: "Penyimpanan persisten adalah salah satu tren. Penjelasan kendala mencakup model dan antarmuka lama."
      }
    }
  },
  {
    options: {
      A: {
        text: "Hasil pada aplikasi yang diuji sudah cukup untuk menyimpulkan bahwa performa akan meningkat juga pada aplikasi serupa yang belum diuji.",
        message: "Temuan berlaku pada konteks yang diuji. Aplikasi serupa tetap memerlukan bukti."
      },
      B: {
        text: "Peningkatan kinerja terutama berasal dari peningkatan kecepatan perangkat keras selama pengujian.",
        message: "Abstrak mengaitkan peningkatan dalam banyak kasus dengan penyederhanaan lapisan perangkat lunak."
      },
      D: {
        text: "Manfaat Twizzler hanya terlihat pada perangkat lunak yang dibuat khusus untuknya.",
        message: "Abstrak juga melaporkan peningkatan kinerja dalam banyak kasus pada aplikasi yang di-porting."
      },
      E: {
        text: "Penelitian baru mengusulkan rancangan Twizzler tanpa menguji aplikasi.",
        message: "Abstrak menjelaskan evaluasi melalui studi kasus dan aplikasi yang di-porting."
      }
    },
    reasons: {
      A: {
        text: "Abstrak menganggap kemiripan aplikasi cukup untuk menerapkan hasil pada aplikasi yang belum diuji.",
        message: "Abstrak melaporkan hasil pada studi kasus dan aplikasi yang diuji."
      },
      B: {
        text: "Abstrak mengaitkan peningkatan yang dilaporkan dengan pergantian perangkat keras selama pengujian.",
        message: "Dalam banyak kasus, peningkatan dikaitkan dengan penyederhanaan lapisan perangkat lunak."
      },
      C: {
        text: "Abstrak berhenti pada uraian desain tanpa pemeriksaan terhadap aplikasi.",
        message: "Abstrak menyebut evaluasi studi kasus dan aplikasi yang di-porting."
      }
    }
  }
];

module.exports = baseline.map((question,index)=>{
  const revised=structuredClone(question);
  const {options,reasons}=revisions[index];
  for(const [choices,changes,offset] of [[revised.options,options,0],[revised.reasons,reasons,5]]){
    for(const [letter,{text,message}] of Object.entries(changes)){
      const choiceIndex=letter.charCodeAt(0)-65;
      choices[choiceIndex]=letter+'. '+text;
      revised.feedback[offset+choiceIndex].message=message;
    }
  }
  return revised;
});
