// Node.js with node:zlib ZSTD support. Extraction/candidate patch; never executes game code.
// Format reference: https://dom.rojo.space/binary.html
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const zlib = require('node:zlib');
const hash = b => crypto.createHash('sha256').update(b).digest('hex');
function stringAt(b, p) {
  if (p + 4 > b.length) throw Error('Truncated string length');
  const end = p + 4 + b.readUInt32LE(p);
  if (end > b.length) throw Error('Truncated string');
  return { value: b.subarray(p + 4, end), end };
}
function lz4(b, size) {
  const out = Buffer.alloc(size); let p = 0, q = 0;
  function length(n) { if (n === 15) { let v; do { if (p >= b.length) throw Error('Truncated LZ4'); v = b[p++]; n += v; } while (v === 255); } return n; }
  while (p < b.length) {
    const token = b[p++], n = length(token >>> 4);
    if (p + n > b.length || q + n > size) throw Error('Invalid LZ4 literals');
    b.copy(out, q, p, p + n); p += n; q += n;
    if (p === b.length) break;
    if (p + 2 > b.length) throw Error('Truncated LZ4 offset');
    const back = b.readUInt16LE(p); p += 2;
    const count = length(token & 15) + 4;
    if (!back || back > q || q + count > size) throw Error('Invalid LZ4 match');
    for (let i = 0; i < count; i++) { out[q] = out[q - back]; q++; }
  }
  if (q !== size) throw Error('LZ4 output size mismatch');
  return out;
}
function read(file) {
  const bytes = Buffer.isBuffer(file) ? file : fs.readFileSync(file);
  if (bytes.length < 32 || bytes.subarray(0, 14).toString('hex') !== '3c726f626c6f782189ff0d0a1a0a' || bytes.readUInt16LE(14) !== 0) throw Error('Invalid RBXL header/version');
  const chunks = [], classes = new Map(); let p = 32;
  while (p < bytes.length) {
    if (p + 16 > bytes.length) throw Error('Truncated chunk header');
    const compressed = bytes.readUInt32LE(p + 4), size = bytes.readUInt32LE(p + 8), end = p + 16 + (compressed || size);
    if (end > bytes.length) throw Error('Truncated chunk');
    const raw = bytes.subarray(p + 16, end);
    const data = !compressed ? raw : raw.subarray(0, 4).equals(Buffer.from('28b52ffd', 'hex')) ? zlib.zstdDecompressSync(raw) : lz4(raw, size);
    if (data.length !== size) throw Error('Chunk size mismatch');
    chunks.push({ tag: bytes.toString('ascii', p, p + 4), data, raw: bytes.subarray(p, end) }); p = end;
  }
  if (chunks.at(-1)?.tag !== 'END\0' || chunks.at(-1).data.toString() !== '</roblox>') throw Error('Missing END');
  for (const c of chunks.filter(c => c.tag === 'INST')) {
    const n = stringAt(c.data, 4);
    classes.set(c.data.readUInt32LE(0), { name: n.value.toString(), count: c.data.readUInt32LE(n.end + 1) });
  }
  const props = [];
  for (const c of chunks.filter(c => c.tag === 'PROP')) {
    const cls = classes.get(c.data.readUInt32LE(0)), n = stringAt(c.data, 4);
    if (!['Script', 'LocalScript', 'ModuleScript'].includes(cls?.name) || !['Name', 'Source'].includes(n.value.toString())) continue;
    if (c.data[n.end] !== 1) throw Error('Unsupported script property encoding');
    let at = n.end + 1; const values = [];
    for (let i = 0; i < cls.count; i++) { const s = stringAt(c.data, at); values.push(s.value); at = s.end; }
    if (at !== c.data.length) throw Error('Unexpected trailing script property data');
    props.push({ class: cls.name, property: n.value.toString(), values });
  }
  return { bytes, chunks, props };
}
function extract(input, output) {
  if (fs.existsSync(output)) throw Error('Output directory exists; choose a new directory');
  const r = read(input), entries = [];
  fs.mkdirSync(output, { recursive: true });
  for (const cls of ['LocalScript', 'ModuleScript', 'Script']) {
    const names = r.props.find(p => p.class === cls && p.property === 'Name')?.values || [];
    const sources = r.props.find(p => p.class === cls && p.property === 'Source')?.values || [];
    if (names.length !== sources.length) throw Error('Name/source count mismatch');
    fs.mkdirSync(path.join(output, cls));
    for (let i = 0; i < names.length; i++) {
      const name = names[i].toString(), safe = name.replace(/[^a-zA-Z0-9_-]/g, '_').slice(0, 80) || 'unnamed';
      const file = `${cls}/${String(i).padStart(4, '0')}-${safe}.luau`;
      fs.writeFileSync(path.join(output, file), sources[i], { flag: 'wx' });
      entries.push({ class: cls, classIndex: i, name, file, sha256: hash(sources[i]) });
    }
  }
  const manifest = { input: path.resolve(input), inputSha256: hash(r.bytes), bytes: r.bytes.length, chunks: r.chunks.length, scope: 'Source extraction only; class index is not an instance path; no Play or serialization', entries };
  fs.writeFileSync(path.join(output, 'manifest.json'), JSON.stringify(manifest, null, 2));
  if (hash(fs.readFileSync(input)) !== manifest.inputSha256) throw Error('Input changed during extraction');
  return manifest;
}
// Patch only one Source value. All unrelated chunks remain byte-for-byte original.
// Output must be a new candidate file, never the input WORKING file.
function patch(input, output, spec) {
  if (path.resolve(input).toLowerCase() === path.resolve(output).toLowerCase() || fs.existsSync(output)) throw Error('Output must be a new candidate file');
  const r = read(input);
  if (hash(r.bytes) !== spec.inputSha256) throw Error('Input hash mismatch');
  const names = r.props.find(p => p.class === spec.class && p.property === 'Name')?.values;
  const sources = r.props.find(p => p.class === spec.class && p.property === 'Source')?.values;
  const i = spec.classIndex;
  if (!Number.isInteger(i) || i < 0 || !names?.[i] || names[i].toString() !== spec.name || hash(sources[i]) !== spec.sourceSha256) throw Error('Target identity/hash mismatch');
  const replacement = fs.readFileSync(spec.sourceFile);
  if (replacement.equals(sources[i])) { fs.writeFileSync(output, r.bytes, { flag: 'wx' }); return { changed: false, sha256: hash(r.bytes) }; }
  let changed = 0;
  const encoded = r.chunks.map(c => {
    if (c.tag !== 'PROP') return c.raw;
    const cls = r.props.find(p => p.class === spec.class && p.property === 'Source');
    const className = r.chunks.find(x => x.tag === 'INST' && x.data.readUInt32LE(0) === c.data.readUInt32LE(0));
    if (!className || stringAt(className.data, 4).value.toString() !== spec.class) return c.raw;
    const property = stringAt(c.data, 4);
    if (property.value.toString() !== 'Source') return c.raw;
    const parts = [c.data.subarray(0, property.end + 1)];
    cls.values.forEach((value, index) => { const v = index === i ? replacement : value, len = Buffer.alloc(4); len.writeUInt32LE(v.length); parts.push(len, v); });
    const data = Buffer.concat(parts), header = Buffer.from(c.raw.subarray(0, 16));
    header.writeUInt32LE(0, 4); header.writeUInt32LE(data.length, 8);
    changed++; return Buffer.concat([header, data]);
  });
  if (changed !== 1) throw Error('Expected exactly one changed Source chunk');
  fs.writeFileSync(output, Buffer.concat([r.bytes.subarray(0, 32), ...encoded]), { flag: 'wx' });
  const verify = read(output);
  if (verify.chunks.length !== r.chunks.length) throw Error('Chunk count changed');
  let different = 0;
  verify.chunks.forEach((c, index) => { if (!c.raw.equals(r.chunks[index].raw)) different++; });
  const actual = verify.props.find(p => p.class === spec.class && p.property === 'Source');
  if (different !== 1 || !actual.values[i].equals(replacement) || actual.values.some((v, index) => index !== i && !v.equals(sources[index]))) throw Error('Patch verification failed');
  if (hash(fs.readFileSync(input)) !== spec.inputSha256) throw Error('Input changed');
  return { changed: true, changedChunks: different, sha256: hash(verify.bytes), runtimeValidated: false };
}
module.exports = { read, extract, patch, hash, lz4 };
if (require.main === module) {
  const [command, input, output] = process.argv.slice(2);
  if (command === 'patch') { console.log(JSON.stringify(patch(input, output, JSON.parse(fs.readFileSync(process.argv[5], 'utf8'))))); process.exit(0); }
  if (command !== 'extract' || !input || !output) throw Error('Usage: node scripts/rbxl-local.cjs extract INPUT.rbxl NEW_OUTPUT_DIR | patch INPUT.rbxl NEW_OUTPUT.rbxl SPEC.json');
  const m = extract(input, output);
  console.log(JSON.stringify({ inputSha256: m.inputSha256, scripts: m.entries.length, chunks: m.chunks, output }));
}
