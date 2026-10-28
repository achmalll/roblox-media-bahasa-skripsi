const fs = require('node:fs');
const path = require('node:path');
function packagePlugin(root) {
  const source = fs.readFileSync(path.join(root, 'studio-sync/Bridge.plugin.luau'), 'utf8');
  const escaped = source.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const xml = `<roblox version="4"><Item class="Script" referent="RBX0"><Properties><string name="Name">CodexLocalBridge</string><ProtectedString name="Source">${escaped}</ProtectedString></Properties></Item></roblox>`;
  const out = path.join(root, 'local-rbxl/bridge/CodexLocalBridge.rbxmx');
  fs.mkdirSync(path.dirname(out), { recursive: true }); fs.writeFileSync(out, xml);
  return out;
}
module.exports = { packagePlugin };
if (require.main === module) console.log(packagePlugin(path.resolve(__dirname, '..')));
