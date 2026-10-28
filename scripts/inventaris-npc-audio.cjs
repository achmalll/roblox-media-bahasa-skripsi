// Read-only inventory of likely NPC/audio objects from an RBXL file.
const { inventory } = require('./rbxl-prompt-hold.cjs');

const input = process.argv[2];
if (!input) throw Error('Usage: node scripts/inventaris-npc-audio.cjs INPUT.rbxl');

const inv = inventory(input);
const pathKey = path => JSON.stringify(path);
const humanoids = inv.instances.filter(item => item.class === 'Humanoid');
const characterRoots = inv.instances.filter(item => item.class === 'Model' && humanoids.some(h => {
  if (h.instancePath.length <= item.instancePath.length) return false;
  return item.instancePath.every((part, index) => h.instancePath[index] === part);
}));
const instances = inv.instances.filter(item => {
  const joined = item.instancePath.join('/');
  return /npc|tutor|space1|audio|narration|naration|male|female|level1development|kios/i.test(joined)
    || (item.class === 'Sound' && joined.startsWith('StarterGui/Level1Gui/'));
});

console.log(JSON.stringify({
  input,
  scope: 'Read-only names/classes/paths; does not execute scripts or modify the RBXL',
  instances,
  level1Sounds: inv.instances.filter(item => item.class === 'Sound' && item.instancePath.join('/').startsWith('StarterGui/Level1Gui/')),
  characterRoots: characterRoots.map(item => ({ class: item.class, name: item.name, instancePath: item.instancePath })),
  prompts: inv.prompts.map(({ instancePath, holdDuration }) => ({ instancePath, holdDuration })),
}, null, 2));
