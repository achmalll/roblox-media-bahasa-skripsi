// Single build entrypoint for learning UI, then recorder/catalogue revision.
const fs=require('node:fs'),cp=require('node:child_process');
const inline=require('./inline-responsive.cjs');
fs.writeFileSync('studio-sync/src/Level1Handler.client.luau',inline(fs.readFileSync('studio-sync/templates/Level1Handler.client.luau','utf8')));
for(const file of ['build-level2.cjs','build-level3.cjs','build-recording.cjs'])cp.execFileSync(process.execPath,['scripts/'+file],{stdio:'inherit'});
