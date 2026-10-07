// Optional static DCL audit. This does not claim rendering or interaction tests.
import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
let errors=0,dialogs=0;
const allKeys=new Set(), dialogNames=new Set();
for(const name of fs.readdirSync(path.join(root,'dialogs')).filter(x=>x.endsWith('.dcl'))) {
  const source=fs.readFileSync(path.join(root,'dialogs',name),'utf8');
  const tokens=source.replace(/\/\/[^\n]*/g,'').match(/"(?:\\.|[^"\\])*"|[{}]|[^\s{}]+/g)||[];
  let depth=0;
  for(const token of tokens) {if(token==='{')depth++;if(token==='}')depth--;if(depth<0)errors++;}
  if(depth!==0){console.error(`${name}: unbalanced braces`);errors++;}
  for(const match of source.matchAll(/(\w+)\s*:\s*dialog\s*\{/g)) {
    dialogs++;dialogNames.add(match[1]);let i=match.index+match[0].length,d=1,quoted=false,body='';
    while(i<source.length&&d){let c=source[i++];if(c==='"'&&source[i-2]!=='\\')quoted=!quoted;if(!quoted){if(c==='{')d++;if(c==='}')d--;}body+=c;}
    const keys=[...body.matchAll(/key\s*=\s*"([^"]+)"/g)].map(x=>x[1]);
    for(const key of keys) allKeys.add(key);
    if(/ok_cancel/.test(body)){allKeys.add('accept');allKeys.add('cancel');}
    if(new Set(keys).size!==keys.length){console.error(`${name}/${match[1]}: duplicate tile keys`);errors++;}
    if(!/is_cancel\s*=\s*true|ok_cancel/.test(body)){console.error(`${name}/${match[1]}: no cancel action`);errors++;}
    console.log(`${name}: ${match[1]}, ${keys.length} explicit keys`);
  }
}
// Literal tile and dialog references. Dynamic/generated names still need review.
for(const rel of ['core/tt-ui.lsp','core/tt-ux.lsp','core/tt-managers.lsp','core/tt-record-ui.lsp','planting/tt-plant-ui.lsp']) {
  const source=fs.readFileSync(path.join(root,rel),'utf8');
  for(const match of source.matchAll(/\((?:action_tile|set_tile|get_tile|mode_tile|start_list)\s+"([^"]+)"/g))
    if(!allKeys.has(match[1])){console.error(`${rel}: unknown literal tile ${match[1]}`);errors++;}
  for(const match of source.matchAll(/\(new_dialog\s+"([^"]+)"/g))
    if(!dialogNames.has(match[1])){console.error(`${rel}: unknown dialog ${match[1]}`);errors++;}
  for(const match of source.matchAll(/\(action_tile\s+"[^"]+"\s+("(?:\\.|[^"\\])*")/g)) {
    const callback=JSON.parse(match[1]);let depth=0,quoted=false,escape=false;
    for(const ch of callback){
      if(escape){escape=false;continue;}
      if(ch==='\\'&&quoted){escape=true;continue;}
      if(ch==='"'){quoted=!quoted;continue;}
      if(!quoted){if(ch==='(')depth++;if(ch===')')depth--;if(depth<0)break;}
    }
    if(depth!==0||quoted){console.error(`${rel}: malformed literal action callback`);errors++;}
  }
}
// Menus dispatch trusted literal function symbols, which direct-call audits miss.
const loader=fs.readFileSync(path.join(root,'TerraTools.lsp'),'utf8');
const loadedFunctions=new Set();
for(const [,rel] of loader.matchAll(/"([^"\n]+\.lsp)"/g)) {
  for(const [,name] of fs.readFileSync(path.join(root,rel),'utf8').matchAll(/\(defun\s+([^\s()]+)/gi))
    loadedFunctions.add(name.toUpperCase());
}
const tasks=fs.readFileSync(path.join(root,'core/tt-ux.lsp'),'utf8');
for(const [,name] of tasks.matchAll(/\("[^"\n]+"\s+((?:TT:|C:TT)[^\s()]+)/gi)) {
  if(!loadedFunctions.has(name.toUpperCase())){console.error(`Workflow task target is not loaded: ${name}`);errors++;}
}
console.log(`${dialogs} dialog definitions, ${errors} static errors. GUI acceptance remains required.`);
process.exitCode=errors?1:0;
