// Optional static DCL audit. This does not claim rendering or interaction tests.
import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
let errors=0,dialogs=0;
for(const name of fs.readdirSync(path.join(root,'dialogs')).filter(x=>x.endsWith('.dcl'))) {
  const source=fs.readFileSync(path.join(root,'dialogs',name),'utf8');
  const tokens=source.replace(/\/\/[^\n]*/g,'').match(/"(?:\\.|[^"\\])*"|[{}]|[^\s{}]+/g)||[];
  let depth=0;
  for(const token of tokens) {if(token==='{')depth++;if(token==='}')depth--;if(depth<0)errors++;}
  if(depth!==0){console.error(`${name}: unbalanced braces`);errors++;}
  for(const match of source.matchAll(/(\w+)\s*:\s*dialog\s*\{/g)) {
    dialogs++;let i=match.index+match[0].length,d=1,quoted=false,body='';
    while(i<source.length&&d){let c=source[i++];if(c==='"'&&source[i-2]!=='\\')quoted=!quoted;if(!quoted){if(c==='{')d++;if(c==='}')d--;}body+=c;}
    const keys=[...body.matchAll(/key\s*=\s*"([^"]+)"/g)].map(x=>x[1]);
    if(new Set(keys).size!==keys.length){console.error(`${name}/${match[1]}: duplicate tile keys`);errors++;}
    if(!/is_cancel\s*=\s*true|ok_cancel/.test(body)){console.error(`${name}/${match[1]}: no cancel action`);errors++;}
    console.log(`${name}: ${match[1]}, ${keys.length} explicit keys`);
  }
}
console.log(`${dialogs} dialog definitions, ${errors} static errors. GUI acceptance remains required.`);
process.exitCode=errors?1:0;
