// Optional development checker. Node.js is not an AutoCAD runtime dependency.
import fs from 'node:fs';
import path from 'node:path';
const root = path.resolve(import.meta.dirname, '..');
let errors = 0, count = 0;
const names = new Map();
const references = [];
function audit(file) {
  const s = fs.readFileSync(file, 'utf8'); let i = 0, line = 1;
  function fail(m) { throw Error(`${file}:${line}: ${m}`); }
  function skip() { while (i < s.length) {
    if (/\s/.test(s[i])) { if(s[i++] === '\n') line++; }
    else if(s[i] === ';') { while(i < s.length && s[i] !== '\n') i++; }
    else break;
  } }
  function expr() {
    skip(); const start = line, c = s[i++];
    if(c === '(') {
      const items = []; skip();
      while(s[i] !== ')') { if(i >= s.length) fail('unclosed list'); items.push(expr()); skip(); }
      i++;
      const dots = items.map((x,j)=>x.atom==='.'?j:-1).filter(j=>j>=0);
      if(dots.length && (dots.length!==1 || dots[0]===0 || dots[0]!==items.length-2)) fail('malformed dotted pair');
      return {items, line:start};
    }
    if(c === ')') fail('unexpected closing parenthesis');
    if(c === "'") return {quote:expr(),line:start};
    if(c === '"') { let text = '', done = false;
      while(i < s.length) { const x = s[i++]; if(x === '\n') line++;
        if(x === '"') {done = true; break;} if(x === '\\') {text += s[i++];} else text += x;
      } if(!done) fail('unterminated string'); return {string:text,line:start};
    }
    let atom = c; while(i < s.length && !/[\s();']/.test(s[i])) atom += s[i++];
    if(!atom || /[`#]/.test(atom)) fail(`invalid reader token ${atom}`);
    if (!['1+','1-'].includes(atom) && /^[+-]?\d/.test(atom) && !/^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$/.test(atom)) fail(`malformed numeric token ${atom}`);
    return {atom:atom.toUpperCase(),line:start};
  }
  function walk(n, parent) {
    if(!n.items) return;
    const a=n.items, op=a[0]?.atom;
    if(op && /^(?:TT:|C:TT)/.test(op)) references.push({name:op,file,line:n.line});
    const arity={IF:[3,4],SETQ:[3,9999],DEFUN:[3,9999],QUOTE:[2,2]};
    if(arity[op] && (a.length<arity[op][0] || a.length>arity[op][1]))
      throw Error(`${file}:${n.line}: wrong ${op} form length ${a.length}`);
    if(op==='SETQ' && a.length%2!==1) throw Error(`${file}:${n.line}: odd SETQ pairs`);
    if(op==='DEFUN') {
      const name=a[1]?.atom, args=a[2]?.items;
      if(!name || !args || args.some(x=>!x.atom)) throw Error(`${file}:${n.line}: malformed DEFUN`);
      if(args.filter(x=>x.atom==='/').length>1 || args.some(x=>x.atom!== '/' && /^[0-9.]|^T$|^NIL$/.test(x.atom))) throw Error(`${file}:${n.line}: invalid DEFUN argument`);
      if(name!=='*ERROR*') {
        if(parent) throw Error(`${file}:${n.line}: nested ${name}`);
        if(names.has(name)) throw Error(`${file}:${n.line}: duplicate ${name} from ${names.get(name)}`);
        names.set(name,file);
      }
    }
    // Quoted lists are data. Do not inspect as expressions.
    if(op!=='QUOTE') for(const child of a) walk(child, parent || op==='DEFUN');
  }
  skip(); while(i<s.length) {walk(expr(),false); skip();} count++;
}
function files(dir) { for(const e of fs.readdirSync(dir,{withFileTypes:true})) {
  if(e.name.startsWith('.') || ['raw','build','production','artifacts','temp','scratch'].includes(e.name)) continue;
  const f=path.join(dir,e.name); if(e.isDirectory()) files(f);
  else if(e.name.endsWith('.lsp')) try {audit(f);} catch(e) {console.error(e.message); errors++;}
} }
files(root);
for(const ref of references) if(!names.has(ref.name)) {console.error(`${ref.file}:${ref.line}: undefined ${ref.name}`);errors++;}
const loader=fs.readFileSync(path.join(root,'TerraTools.lsp'),'utf8');
for(const [,rel] of loader.matchAll(/"([^"\n]+\.lsp)"/g)) {
  if(!fs.existsSync(path.join(root,rel))) {console.error(`Missing loader module ${rel}`);errors++;}
}
console.log(`${count} Lisp files audited; ${names.size} unique functions; ${errors} errors.`);
process.exitCode=errors?1:0;
