const fs=require('node:fs'),path=require('node:path');
const source=()=>fs.readFileSync(path.join(__dirname,'../studio-sync/ui/ResponsiveLearning.luau'),'utf8');
module.exports=s=>s.replace('local UI = nil -- RESPONSIVE_LIBRARY','local UI = (function()\n'+source()+'\nend)()');
