const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8').replace(/\r\n/g,'\n'),write=(p,s)=>fs.writeFileSync(path.join(root,p),s);
const bank=require('../docs/desain/storyboard-level3/isi-sumber.json'),{rounds}=require('../docs/desain/storyboard-level3/bank-ronde-editor.cjs');
const story=read('docs/desain/storyboard-level3/STORYBOARD.md');
function section(id){return story.split('## '+id+' —')[1].split('\n').slice(2).join('\n').split('Perilaku:')[0].trim();}
const data={intro:section('L3-01B'),terms:[section('L3-02B1'),section('L3-02B2')],pages:[bank.material[0],bank.material[1]+'\n\n'+bank.material[2],bank.material[3]],headings:['Masalah dan motivasi','Tren perangkat keras dan pendekatan','Implementasi dan evaluasi'],questions:bank.questions,rounds,cards:['Lapisan kompatibilitas dan overhead membatasi pemanfaatan perangkat keras modern.','Pendekatan data-centric dirancang untuk memudahkan berbagi data dan mengurangi beban akses data.','Twizzler dievaluasi melalui studi kasus dan aplikasi yang di-porting.']};
const template=read('studio-sync/templates/Level3FlowHandler.client.luau');
write('studio-sync/src/Level3FlowHandler.client.luau',template.replace('local DATA = nil -- GENERATED_CONTENT','local DATA = Http:JSONDecode([==['+JSON.stringify(data)+']==])'));
const key=(q,t)=>q['key'+t].match(/: ([A-E])/)[1].charCodeAt(0)-64;
write('studio-sync/src/Level3ScoreHandler.server.luau',read('studio-sync/templates/Level2ScoreHandler.server.luau').replaceAll('Level2','Level3').replaceAll('level1','level2').replaceAll('Level1','Level2').replaceAll('Level 1','Level 2').replace('progress.Value<2','progress.Value<3').replace('progress.Value,3','progress.Value,4').replace('progress.Value>=3','progress.Value>=4').replace('[L2 Server]','[L3 Server]').replace('-- GENERATED_KEYS','local answerKeys = {'+bank.questions.map(q=>key(q,1))+'}\nlocal reasonKeys = {'+bank.questions.map(q=>key(q,2))+'}'));
write('studio-sync/src/Level3QuizHandler.client.luau','-- Evaluation is owned by Level3FlowHandler; legacy callbacks retired.\n');
console.log('Built Level3: 3 reading pages, 3 drag cards, 4 editor rounds, 4 two-tier questions.');
