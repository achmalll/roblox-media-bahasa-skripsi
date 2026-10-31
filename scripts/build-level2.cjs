const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
const bank = JSON.parse(read('docs/desain/storyboard-level2/isi-sumber.json'));
const storyboard = read('docs/desain/storyboard-level2/STORYBOARD.md');
function section(id) {
  const start = storyboard.indexOf('## ' + id + ' —');
  if (start < 0) throw Error('Missing storyboard section ' + id);
  return storyboard.slice(start, storyboard.indexOf('\n## ', start + 3) < 0 ? undefined : storyboard.indexOf('\n## ', start + 3)).split('\n').slice(2).join('\n').split('Perilaku:')[0].trim();
}
const sentence = (paragraph, prefix) => {
  const sentences = paragraph.match(/[^.!?]+[.!?]/g).map(s => s.trim());
  const found = sentences.find(s => s.startsWith(prefix));
  if (!found) throw Error('Missing source sentence: ' + prefix);
  return found;
};
const material = bank.material;
const android = sentence(material[1], 'Sistem operasi Android');
const windows = sentence(material[1], 'Di sisi lain');
const data = {
  intro: section('L2-01B'),
  terms: [section('L2-02B1'), section('L2-02B2')],
  pages: [material[0], material[1], material[2] + '\n\n' + material[3]],
  headings: ['Perangkat dan gagasan utama', 'Cara kerja kedua sistem', 'Manfaat dan fitur pendukung'],
  evidence: [sentence(material[0], 'Salah satu inovasi'), android, windows, sentence(material[3], 'Selain keunggulan')],
  pairEvidence: [android + ' ' + windows, sentence(material[2], 'Namun, dengan konsep')],
  conclusions: [
    'Pada tablet dalam berita, dua OS tidak berarti keduanya dipasang langsung di perangkat.',
    'Keunggulan yang ditawarkan adalah dua lingkungan yang saling melengkapi kebutuhan pengguna.',
  ],
  questions: bank.questions,
};
const key = (q, tier) => {
  const letter = q['key' + tier].match(new RegExp('Kunci tier ' + tier + ': ([A-E])'))?.[1];
  if (!letter) throw Error('Missing key');
  return letter.charCodeAt(0) - 64;
};
if (bank.questions.length !== 4 || bank.questions.some(q => q.options.length !== 5 || q.reasons.length !== 4 || q.feedback.length !== 9)) throw Error('Unexpected bank schema');
const json = JSON.stringify(data);
if (json.includes(']==]')) throw Error('Unsafe long string delimiter');
const client = read('studio-sync/templates/Level2FlowHandler.client.luau').replace('local DATA = nil -- GENERATED_CONTENT', 'local DATA = Http:JSONDecode([==[' + json + ']==])');
fs.writeFileSync(path.join(root, 'studio-sync/src/Level2FlowHandler.client.luau'), client);
const server = read('studio-sync/templates/Level2ScoreHandler.server.luau')
  .replace('-- GENERATED_KEYS', 'local answerKeys = {' + bank.questions.map(q => key(q, 1)).join(',') + '}\nlocal reasonKeys = {' + bank.questions.map(q => key(q, 2)).join(',') + '}');
fs.writeFileSync(path.join(root, 'studio-sync/src/Level2ScoreHandler.server.luau'), server);
console.log('Built L2 client/server from storyboard and bank: 3 pages, 4 two-tier questions.');
