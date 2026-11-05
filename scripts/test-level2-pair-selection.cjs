const fs=require('fs'),cp=require('child_process');
const source=fs.readFileSync('studio-sync/templates/Level2FlowHandler.client.luau','utf8');
const rules=source.split('-- PAIR_SELECTION_BEGIN')[1].split('-- PAIR_SELECTION_END')[0];
const test=`
local s={}
choosePair(s,2,1); assert(s[2]==1 and s[1]==nil)
choosePair(s,2,1); assert(s[2]==nil) -- tap selected item to undo
choosePair(s,2,1); choosePair(s,1,2); assert(s[1]==2 and s[2]==1)
choosePair(s,1,1); assert(s[1]==1 and s[2]==2) -- occupied evidence swaps, never duplicates
choosePair(s,2,1); assert(s[1]==2 and s[2]==1)
local t={}; choosePair(t,1,1); choosePair(t,2,1); assert(t[1]==nil and t[2]==1)
for a=1,2 do for b=1,2 do choosePair(t,a,b); assert(not t[1] or not t[2] or t[1]~=t[2]) end end
print("PASS L2 pairs: select, undo, change, swap, incomplete move, unique evidence IDs")
`;
fs.writeFileSync('local-rbxl/test-l2-pair-selection.luau',rules+test);
process.stdout.write(cp.execFileSync('local-rbxl/luau/luau.exe',['local-rbxl/test-l2-pair-selection.luau'],{encoding:'utf8'}));
