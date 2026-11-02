const fs=require('fs'),cp=require('child_process'),assert=require('assert/strict');
const read=p=>fs.readFileSync(p,'utf8');
const client=read('studio-sync/src/Level3FlowHandler.client.luau');
const data=JSON.parse(client.match(/JSONDecode\(\[==\[([\s\S]*?)\]==\]\)/)[1]);
const bank=require('../docs/desain/storyboard-level3/isi-sumber.json');
assert.deepEqual(data.questions,bank.questions);assert.deepEqual(data.pages,[bank.material[0],bank.material[1]+'\n\n'+bank.material[2],bank.material[3]]);
const key=(q,t)=>q['key'+t].match(/: ([A-E])/)[1].charCodeAt(0)-64;
let test=read('scripts/test-level2.cjs');
const prelude=test.match(/const prelude = `([\s\S]*?)`;/)[1].replace('LevelProgress={Value=2}','LevelProgress={Value=3}').replace('Level1Score={Value=100},Level2Score={Value=0}','Level2Score={Value=100},Level3Score={Value=0}');
let serverTests=`
local a,b=player(),player()
local function p(id,answers,reasons) return {id=id,answers=answers,reasons=reasons or {${bank.questions.map(q=>key(q,2))}}} end
callback(a,p("50",{4,5,5,5})); assert(a.response.score==50 and a.leaderstats.LevelProgress.Value==3)
callback(a,p("75",{4,5,1,5})); assert(a.response.score==75 and a.leaderstats.LevelProgress.Value==4)
callback(a,p("100",{${bank.questions.map(q=>key(q,1))}})); assert(a.response.score==100 and a.response.reasons==4)
local same=a.response;callback(a,p("100",{1,1,1,1})); assert(a.response==same)
callback(a,p("retry",{1,1,2,1})); assert(a.response.score==0 and a.response.best==100 and a.response.unlocked)
assert(b.PlayerScores.Level3Score.Value==0 and b.leaderstats.LevelProgress.Value==3)
b.PlayerScores.Level2Score.Value=50; callback(b,p("deny",{4,5,1,3}));assert(b.response.error)
callback(a,p("bad",{0/0,5,1,3})); assert(a.response.best==100)
print("PASS L3 server: 50/75/100, reason score, duplicate submission, best-score retry, player isolation, prerequisite and invalid input")
`;
const rules=client.match(/-- FLOW_RULES_BEGIN[^\n]*\n([\s\S]*?)-- FLOW_RULES_END/)[1];
let flow=`
local state={intro=false,pages={},page=1,done1=false,done2=false}
local progress={Value=3}
${rules}
assert(stage()=="intro" and prerequisite("exam"))
assert(prerequisite("terms")==nil)
state.intro=true;assert(stage()=="news" and prerequisite("evidence"))
state.pages={true,true};assert(unreadPage()==3 and prerequisite("evidence"))
state.pages[3]=true;assert(stage()=="evidence" and prerequisite("evidence")==nil)
state.done1=true;assert(stage()=="pairs" and prerequisite("exam"))
state.done2=true;assert(stage()=="exam" and prerequisite("exam")==nil)
beginReview();assert(stage()=="news" and state.done1 and state.done2)
progress.Value=2; assert(prerequisite("intro"))
for a=1,3 do for b=1,3 do for c=1,3 do assert(functionsCorrect({a,b,c})==(a==1 and b==2 and c==3)) end end end
`;
for(const r of data.rounds)for(let p=1;p<=3;p++)for(let e=1;e<=2;e++)flow+=`do local a,b=editorCorrect({keyPart=${r.keyPart},keyEvidence=${r.keyEvidence}},${p},${e}); assert(a==${p===r.keyPart} and b==${e===r.keyEvidence}) end\n`;
flow+='print("PASS L3 flow and practice: ordered gates, review, 27 card assignments, 24 editor combinations")';
fs.writeFileSync('local-rbxl/test-l3.luau',prelude+read('studio-sync/src/Level3ScoreHandler.server.luau')+serverTests+flow);
process.stdout.write(cp.execFileSync('local-rbxl/luau/luau.exe',['local-rbxl/test-l3.luau'],{encoding:'utf8'}));
for(const f of ['Level3FlowHandler.client','Level3QuizHandler.client','Level3ScoreHandler.server','LevelProgressHandler.server','ArrowGuideScript.client'])cp.execFileSync('local-rbxl/luau/luau-compile.exe',['studio-sync/src/'+f+'.luau'],{stdio:['ignore','ignore','pipe']});
console.log('PASS L3 bank fidelity and all changed managed source compilation');
