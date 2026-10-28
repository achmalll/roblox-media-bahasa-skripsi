const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { read, hash } = require('./rbxl-local.cjs');
const { inventory } = require('./rbxl-prompt-hold.cjs');
const root = path.resolve(__dirname, '..');
const working = path.join(root, 'places/RobloxLearningMedia-WORKING.rbxl');
const parsed = read(working), config = JSON.parse(fs.readFileSync(path.join(root, 'studio-sync/project.json'), 'utf8'));
for (const item of config.scripts) {
  const names = parsed.props.find(p => p.class === item.className && p.property === 'Name').values;
  const ids = names.map((v, i) => v.toString() === item.instancePath.at(-1) ? i : -1).filter(i => i >= 0);
  assert.equal(ids.length, 1, 'Managed source identity is ambiguous');
  const source = parsed.props.find(p => p.class === item.className && p.property === 'Source').values[ids[0]];
  assert.ok(source.equals(fs.readFileSync(path.join(root, item.file))), 'Saved source differs from local source');
}
const prompts = inventory(working).prompts.map(({ instancePath, holdDuration }) => ({ instancePath, holdDuration }));
const result = { sha256: hash(parsed.bytes), bytes: parsed.bytes.length, managedSourceMatches: true, prompts, playEvidence: 'See session report; this command only verifies saved file' };
fs.mkdirSync(path.join(root, 'local-rbxl/bridge'), { recursive: true });
fs.writeFileSync(path.join(root, 'local-rbxl/bridge/saved-verification.json'), JSON.stringify(result, null, 2));
console.log(JSON.stringify({ sha256: result.sha256, bytes: result.bytes, managedSourceMatches: true, promptCount: prompts.length, allPromptsOneSecond: prompts.every(p => p.holdDuration === 1) }));
