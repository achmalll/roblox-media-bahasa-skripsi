// Inspect prompt paths and patch one existing HoldDuration, preserving all other data.
const fs = require('node:fs');
const path = require('node:path');
const { read, hash } = require('./rbxl-local.cjs');
function str(b, p) { const end = p + 4 + b.readUInt32LE(p); if (end > b.length) throw Error('Truncated string'); return { value: b.toString('utf8', p + 4, end), end }; }
function u32(b, p, n, i) { if (p + 4 * n > b.length) throw Error('Truncated array'); return (b[p + i] * 0x1000000 + (b[p + n + i] << 16) + (b[p + 2 * n + i] << 8) + b[p + 3 * n + i]) >>> 0; }
function refs(b, p, n) { let previous = 0; return Array.from({ length: n }, (_, i) => { const v = u32(b, p, n, i); previous += (v >>> 1) ^ -(v & 1); return previous; }); }
function floatAt(b, p, n, i) { const v = u32(b, p, n, i), tmp = Buffer.alloc(4); tmp.writeUInt32BE(((v >>> 1) | (v << 31)) >>> 0); return tmp.readFloatBE(0); }
function inventory(input) {
  const r = read(input), classes = new Map(), nodes = new Map(), properties = [];
  for (const c of r.chunks.filter(c => c.tag === 'INST')) {
    const id = c.data.readUInt32LE(0), name = str(c.data, 4), count = c.data.readUInt32LE(name.end + 1), ids = refs(c.data, name.end + 5, count);
    if (classes.has(id)) throw Error('Duplicate class ID');
    classes.set(id, { name: name.value, count, ids });
    ids.forEach((ref, index) => { if (nodes.has(ref)) throw Error('Duplicate referent'); nodes.set(ref, { ref, classId: id, class: name.value, index }); });
  }
  for (const c of r.chunks.filter(c => c.tag === 'PROP')) {
    const cls = classes.get(c.data.readUInt32LE(0)), prop = str(c.data, 4), type = c.data[prop.end], start = prop.end + 1;
    if (!cls) throw Error('Missing class');
    if (prop.value === 'Name') {
      if (type !== 1) throw Error('Unsupported Name encoding');
      let p = start; cls.ids.forEach(id => { const s = str(c.data, p); nodes.get(id).name = s.value; p = s.end; });
      if (p !== c.data.length) throw Error('Name array mismatch');
    }
    if (type === 1 && ['SoundId', 'Text', 'ActionText', 'ObjectText'].includes(prop.value)) {
      let p = start;
      cls.ids.forEach(id => {
        const s = str(c.data, p);
        const node = nodes.get(id);
        node.properties ||= {};
        node.properties[prop.value] = s.value;
        p = s.end;
      });
      if (p !== c.data.length) throw Error(prop.value + ' array mismatch');
    }
    if (cls.name === 'ProximityPrompt') properties.push({ chunk: c, cls, property: prop.value, type, start });
  }
  const parents = r.chunks.filter(c => c.tag === 'PRNT');
  if (parents.length !== 1 || parents[0].data[0] !== 0) throw Error('Unsupported PRNT');
  const b = parents[0].data, n = b.readUInt32LE(1), children = refs(b, 5, n), parentIds = refs(b, 5 + n * 4, n);
  if (b.length !== 5 + n * 8 || n !== nodes.size) throw Error('PRNT length/count mismatch');
  const seenChildren = new Set();
  children.forEach((id, i) => { if (!nodes.has(id) || seenChildren.has(id) || (parentIds[i] !== -1 && !nodes.has(parentIds[i]))) throw Error('Invalid parent referent'); seenChildren.add(id); nodes.get(id).parent = parentIds[i]; });
  function nodePath(node) { const result = [], seen = new Set(); while (node) { if (seen.has(node.ref) || node.name === undefined) throw Error('Cycle or missing Name'); seen.add(node.ref); result.unshift(node.name); node = node.parent === -1 ? null : nodes.get(node.parent); } return result; }
  const prompts = [...nodes.values()].filter(v => v.class === 'ProximityPrompt').map(v => {
    const hold = properties.find(p => p.cls.ids[v.index] === v.ref && p.property === 'HoldDuration');
    if (!hold || hold.type !== 4) throw Error('Missing float HoldDuration');
    return { ...v, instancePath: nodePath(v), holdDuration: floatAt(hold.chunk.data, hold.start, hold.cls.count, v.index), hold };
  });
  const instances = [...nodes.values()].map(v => ({
    ref: v.ref,
    class: v.class,
    name: v.name,
    instancePath: nodePath(v),
    properties: v.properties || {},
  }));
  return { r, prompts, instances };
}
function patchHold(input, output, expectedHash, targetPath, referencePath) {
  if (path.resolve(input).toLowerCase() === path.resolve(output).toLowerCase() || fs.existsSync(output)) throw Error('Candidate output must be new');
  const inv = inventory(input);
  if (hash(inv.r.bytes) !== expectedHash) throw Error('Stale input hash');
  function unique(p) { const hits = inv.prompts.filter(v => JSON.stringify(v.instancePath) === JSON.stringify(p)); if (hits.length !== 1) throw Error('Prompt path missing or ambiguous'); return hits[0]; }
  const target = unique(targetPath), reference = unique(referencePath), value = reference.holdDuration;
  if (!Number.isFinite(value) || value < 0) throw Error('Invalid reference duration');
  const data = Buffer.from(target.hold.chunk.data), f = Buffer.alloc(4); f.writeFloatBE(value);
  const bits = f.readUInt32BE(0), encoded = ((bits << 1) | (bits >>> 31)) >>> 0;
  for (let col = 0; col < 4; col++) data[target.hold.start + col * target.hold.cls.count + target.index] = (encoded >>> (24 - col * 8)) & 255;
  const unchanged = data.equals(target.hold.chunk.data);
  const header = Buffer.from(target.hold.chunk.raw.subarray(0, 16)); header.writeUInt32LE(0, 4); header.writeUInt32LE(data.length, 8);
  const bytes = unchanged ? inv.r.bytes : Buffer.concat([inv.r.bytes.subarray(0, 32), ...inv.r.chunks.map(c => c === target.hold.chunk ? Buffer.concat([header, data]) : c.raw)]);
  const verified = inventory(bytes); let changedChunks = 0;
  if (!bytes.subarray(0, 32).equals(inv.r.bytes.subarray(0, 32)) || verified.r.chunks.length !== inv.r.chunks.length) throw Error('Structure changed');
  verified.r.chunks.forEach((c, i) => { if (!c.raw.equals(inv.r.chunks[i].raw)) { changedChunks++; if (inv.r.chunks[i] !== target.hold.chunk) throw Error('Unrelated chunk changed'); } });
  if (changedChunks !== (unchanged ? 0 : 1)) throw Error('Unexpected changed chunk count');
  verified.prompts.forEach(v => { const original = inv.prompts.find(p => p.ref === v.ref); if (!original || v.holdDuration !== (v.ref === target.ref ? value : original.holdDuration)) throw Error('Prompt verification failed'); });
  // Ensure no byte in the decoded property except the target's four float bytes changed.
  for (let i = 0; i < data.length; i++) if (data[i] !== target.hold.chunk.data[i] && ![0, 1, 2, 3].some(col => i === target.hold.start + col * target.hold.cls.count + target.index)) throw Error('Unrelated property byte changed');
  if (hash(fs.readFileSync(input)) !== expectedHash) throw Error('Input changed before output');
  fs.writeFileSync(output, bytes, { flag: 'wx' });
  const result = { inputSha256: expectedHash, outputSha256: hash(bytes), target: targetPath, reference: referencePath, before: target.holdDuration, after: value, changedChunks, binaryVerified: true, studioOpened: false, playTested: false };
  fs.writeFileSync(output + '.report.json', JSON.stringify(result, null, 2), { flag: 'wx' });
  return result;
}
module.exports = { inventory, patchHold, floatAt };
if (require.main === module) {
  const inv = inventory(process.argv[2]);
  console.log(JSON.stringify(inv.prompts.map(({ instancePath, holdDuration }) => ({ instancePath, holdDuration })), null, 2));
}
