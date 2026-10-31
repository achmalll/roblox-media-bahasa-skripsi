// Exercise the actual Luau server with mocked Roblox remote/player objects.
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict'), cp = require('node:child_process');
const root = path.resolve(__dirname, '..'), file = p => path.join(root, p);
const client = fs.readFileSync(file('studio-sync/src/Level2FlowHandler.client.luau'), 'utf8');
const data = JSON.parse(client.match(/JSONDecode\(\[==\[([\s\S]*?)\]==\]\)/)[1]);
const bank = JSON.parse(fs.readFileSync(file('docs/desain/storyboard-level2/isi-sumber.json'), 'utf8'));
assert.deepEqual(data.questions, bank.questions);
assert.deepEqual(data.pages, [bank.material[0], bank.material[1], bank.material[2] + '\n\n' + bank.material[3]]);
for (const quote of [...data.evidence, data.pairEvidence[1]]) assert.ok(bank.material.join(' ').includes(quote), 'Practice quote must be exact source text');
assert.equal(data.pairEvidence[0], data.evidence[1] + ' ' + data.evidence[2]);
const prelude = `
local callback,removed
local remote={OnServerEvent={Connect=function(_,fn) callback=fn end}}
function remote:FireClient(player,response) player.response=response end
local players={PlayerRemoving={Connect=function(_,fn) removed=fn end}}
game={GetService=function(_,name) if name=="Players" then return players end; return {WaitForChild=function() return remote end} end}
local function folder(values) values.FindFirstChild=function(self,name) return self[name] end; return values end
local function player() return folder({UserId=1,leaderstats=folder({LevelProgress={Value=2}}),PlayerScores=folder({Level1Score={Value=100},Level2Score={Value=0}})}) end
`;
const tests = `
local function payload(id,answers,reasons) return {id=id,answers=answers,reasons=reasons or {3,1,2,4}} end
local a,b=player(),player()
callback(a,payload("50",{1,2,1,1}))
assert(a.response.score==50 and a.leaderstats.LevelProgress.Value==2)
assert(b.PlayerScores.Level2Score.Value==0 and b.leaderstats.LevelProgress.Value==2)
callback(a,payload("75",{1,2,2,1}))
assert(a.response.score==75 and a.leaderstats.LevelProgress.Value==3)
callback(a,payload("100",{1,2,2,3},{3,1,2,4}))
assert(a.response.score==100 and a.response.reasons==4 and a.response.best==100)
local same=a.response
callback(a,payload("100",{5,5,5,5},{1,1,1,1}))
assert(a.response==same and a.PlayerScores.Level2Score.Value==100)
callback(a,payload("retry",{5,5,5,5},{1,1,1,1}))
assert(a.response.score==0 and a.response.best==100 and a.response.unlocked)
assert(a.leaderstats.LevelProgress.Value==3)
local denied=player(); denied.PlayerScores.Level1Score.Value=50
callback(denied,payload("deny",{1,2,2,3}))
assert(denied.response.error and denied.PlayerScores.Level2Score.Value==0)
local bad=player()
callback(bad,100); callback(bad,payload("short",{1,2})); callback(bad,payload("nan",{0/0,2,2,3}))
assert(bad.response==nil and bad.PlayerScores.Level2Score.Value==0)
removed(a)
print("PASS L2 server: 50/75/100, reasons, retry, best score, player isolation, prerequisites, invalid input")
`;
const generated = file('local-rbxl/bridge/test-level2-server.luau');
const template = fs.readFileSync(file('studio-sync/templates/Level2FlowHandler.client.luau'), 'utf8');
const rules = template.match(/-- FLOW_RULES_BEGIN[^\n]*\n([\s\S]*?)-- FLOW_RULES_END/)?.[1];
const flowTests = rules ? `
local state={intro=false,pages={},page=1,done1=false,done2=false}
local progress={Value=2}
${rules}
assert(stage()=="intro" and prerequisite("news") and prerequisite("evidence"))
assert(prerequisite("terms")==nil and stage()=="intro")
state.intro=true
assert(stage()=="news" and prerequisite("news")==nil)
for _,k in ipairs({"evidence","pairs","exam"}) do assert(prerequisite(k)) end
state.pages[1]=true; state.pages[2]=true
assert(unreadPage()==3 and prerequisite("evidence"))
state.pages[3]=true
assert(stage()=="evidence" and prerequisite("evidence")==nil and prerequisite("pairs"))
state.done1=true
assert(stage()=="pairs" and prerequisite("pairs")==nil and prerequisite("exam"))
state.done2=true
assert(stage()=="exam" and prerequisite("exam")==nil)
state.page=3
beginReview()
assert(stage()=="news" and state.page==1)
assert(allRead() and state.done1 and state.done2 and prerequisite("exam")==nil)
state.reviewNews=false
assert(stage()=="exam")
progress.Value=1
assert(prerequisite("exam") and prerequisite("terms"))
print("PASS L2 flow: NPC -> actual news board -> evidence -> pairs -> exam; unread pages and early-entry guards")
` : '';
fs.writeFileSync(generated, prelude + fs.readFileSync(file('studio-sync/src/Level2ScoreHandler.server.luau'), 'utf8') + tests + flowTests);
process.stdout.write(cp.execFileSync(process.argv[2] || file('local-rbxl/luau-0.745/luau.exe'), [generated], {encoding:'utf8'}));
console.log('PASS L2: materials/questions match source bank; practice quotes are exact.');
