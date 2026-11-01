const assert=require('node:assert/strict'),{summarize,csv}=require('./export-learning-records.cjs');
const page=(userId,sessionId,n,rev)=>({schemaVersion:1,userId,sessionId,page:n,revision:rev,contentRevision:'fixture',sessionClosed:true,
 levels:{1:{completed:true,completedSeconds:180,observedSeconds:180,timingQuality:'first_interaction',bestScore:75}},
 events:[{sequence:n,level:1,kind:'practice',atMs:1000,elapsedSeconds:5,data:{choices:['A','B'],correct:true}}]});
const old=page(1,'a',1,1),fresh=page(1,'a',1,2),second=page(1,'a',2,1),other=page(2,'b',2,1);
fresh.events[0].data.correct=false;
const out=summarize([old,fresh,second,other]);
assert.equal(out.events.length,3);assert.equal(JSON.parse(out.events[0].details).correct,false);
assert.equal(out.levels[0].completedMinutes,3);assert.equal(out.levels[0].pagesComplete,true);
assert.equal(out.levels[1].pagesComplete,false);
const interrupted=page(1,'again',1,1);interrupted.levels[1]={completed:false,observedSeconds:15,timingQuality:'evaluation_only'};
assert.equal(summarize([interrupted]).levels[0].completedSeconds,'');
assert.throws(()=>summarize([{...fresh,revision:2,events:[]},fresh]),/Conflicting/);
assert.ok(csv([{x:'a,"b"\nnext'}],['x']).includes('"a,""b""\nnext"'));
console.log('PASS CSV: revisions, raw choices, users/sessions, minute conversion, interrupted/missing duration, page gaps, escaping');
