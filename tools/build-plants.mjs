// Optional offline build tool, Node.js 22+. Runtime uses only emitted text files.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {createInterface} from 'node:readline';
const input=process.argv[2], out=process.argv[3];
if(!input || !out) throw Error('Usage: node tools/build-plants.mjs classification.csv OUTPUT_NEW_DIRECTORY');
if(fs.existsSync(out)) throw Error('Output must be a new directory; existing builds are never overwritten.');
const source={name:'World Flora Online Plant List',version:'2026-06',license:'CC0-1.0',
  url:'https://zenodo.org/records/20782718',attribution:'The World Flora Online Consortium (2026)'};
const version='1.0.0', started=Date.now(), accepted=new Map(), counts={input:0,rejected:0,excluded:0,duplicates:0,aliases:0,unresolvedAliases:0};
// WFO backbone is tab-delimited CSV. Respect quoted tabs/newlines/doubled quotes.
async function* rows(file) {
  let row=[],field='',quoted=false,after=false;
  for await(const chunk of fs.createReadStream(file,{encoding:'utf8'})) {
    for(const ch of chunk) {
      if(after) {
        if(ch==='"') {field+='"';after=false;continue;}
        quoted=false;after=false;
      } else if(quoted) {
        if(ch==='"') after=true; else field+=ch;
        continue;
      }
      if(ch==='"' && field==='') quoted=true;
      else if(ch==='\t') {row.push(field);field='';}
      else if(ch==='\n') {row.push(field.replace(/\r$/,''));yield row;row=[];field='';}
      else field+=ch;
    }
  }
  if(quoted && !after) throw Error('Unclosed source CSV string');
  if(field || row.length) {row.push(field);yield row;}
}
async function scan(fn) {
  let headers;
  for await(const row of rows(input)) {
    if(!headers) {headers=row; if(!headers.includes('taxonID') || !headers.includes('taxonomicStatus')) throw Error('Not a WFO backbone');continue;}
    if(row.length!==headers.length) {counts.rejected++;continue;}
    const r={};headers.forEach((h,i)=>r[h]=row[i]);fn(r);
  }
}
console.log('Reading accepted species and infraspecific taxa...');
await scan(r=>{
  counts.input++;
  if(r.taxonomicStatus.toLowerCase()!=='accepted' || !['species','subspecies','variety','form'].includes(r.taxonRank.toLowerCase())) {counts.excluded++;return;}
  if(!/^wfo-\d{10}$/.test(r.taxonID) || !r.scientificName.trim()) {counts.rejected++;return;}
  if(accepted.has(r.taxonID)) {counts.duplicates++;return;}
  accepted.set(r.taxonID,{id:r.taxonID,name:r.scientificName,family:r.family,genus:r.genus,species:r.specificEpithet,
    infra:r.infraspecificEpithet,rank:r.taxonRank,authorship:r.scientificNameAuthorship,aliases:[]});
});
console.log(`${accepted.size} accepted taxa. Resolving source synonym links...`);
await scan(r=>{
  if(r.taxonomicStatus.toLowerCase()!=='synonym') return;
  const target=accepted.get(r.acceptedNameUsageID);
  if(target && r.scientificName && /^wfo-\d{10}$/.test(r.taxonID)) {
    target.aliases.push([r.taxonID,r.scientificName]);counts.aliases++;
  } else counts.unresolvedAliases++;
});
fs.mkdirSync(out,{recursive:true});fs.mkdirSync(path.join(out,'records'));fs.mkdirSync(path.join(out,'index'));
const q=s=>'"'+String(s).replaceAll('\\','\\\\').replaceAll('"','\\"').replace(/[\r\n\t]/g,' ')+'"';
const pair=(k,v)=>`(${k} . ${q(v)})`;
const norm=s=>s.normalize('NFKD').replace(/[\u0300-\u036f]/g,'').toUpperCase().replace(/[^A-Z0-9]+/g,' ').trim();
const buffers=new Map(), flush=()=>{for(const [f,s] of buffers) fs.appendFileSync(path.join(out,f),s,'utf8');buffers.clear();};
const put=(f,s)=>{buffers.set(f,(buffers.get(f)||'')+s+'\n');if(buffers.get(f).length>256000) {fs.appendFileSync(path.join(out,f),buffers.get(f),'utf8');buffers.delete(f);}};
let built=0;
for(const r of [...accepted.values()].sort((a,b)=>a.id.localeCompare(b.id,'en'))) {
  const description=r.family?`${r.name} is recorded in the ${r.family} family.`:`${r.name} is an accepted ${r.rank} in the World Flora Online Plant List.`;
  const id=r.id.toUpperCase(), shard=String(Number(r.id.slice(4))%1024);
  const fields={PLANT_ID:id,CATEGORY:'OTHER',BOTANICAL_NAME:r.name,COMMON_NAME:'',PLANT_CODE:id,SIZE:'',SPACING:'',UNIT_COST:'',SYMBOL_BLOCK:'',NOTES:'',
    SOURCE:source.name,SOURCE_ID:r.id,SOURCE_VERSION:source.version,SOURCE_URL:source.url,SOURCE_LICENSE:source.license,SOURCE_ATTRIBUTION:source.attribution,
    ACCEPTED_TAXON_ID:r.id,ACCEPTED_SCIENTIFIC_NAME:r.name,TAXONOMIC_STATUS:'ACCEPTED',TAXON_RANK:r.rank,AUTHORSHIP:r.authorship,
    FAMILY:r.family,GENUS:r.genus,SPECIES:r.species,INFRASPECIFIC_EPITHET:r.infra,
    GENERATED_DESCRIPTION:description,GENERATED_DESIGN_NOTES:'',DESCRIPTION_GENERATION_VERSION:version,DESCRIPTION_COMPLETENESS:'TAXONOMY_ONLY'};
  let record='(PLANT_RECORD '+Object.entries(fields).map(([k,v])=>k==='CATEGORY'?'(CATEGORY . OTHER)':pair(k,v)).join(' ');
  record+=' (SYNONYMS '+r.aliases.map(a=>q(a[1])).join(' ')+') (SOURCE_ALIAS_IDS '+r.aliases.map(a=>q(a[0])).join(' ')+')';
  record+=` (DESCRIPTION_FACT_FIELDS SCIENTIFIC_NAME ${r.family?'FAMILY':'TAXON_RANK TAXONOMIC_STATUS'}))`;
  put(`records/${shard}.dat`,record);
  const primary=norm(r.name), search=norm([r.name,r.family,...r.aliases.map(a=>a[1])].join(' '));
  const prefixes=new Set(search.split(' ').filter(x=>x.length>=2).map(x=>x.slice(0,2)));
  // Compact search rows carry no full project/source record.
  const index=`(${q(id)} ${q(r.name)} ${q(r.family)} ${q(primary)} ${q(search)})`;
  for(const p of prefixes) put(`index/${p}.dat`,index);
  if(++built%20000===0) {flush();console.log(`Built ${built}`);}
}
flush();
async function sha(file) {const h=crypto.createHash('sha256');for await(const c of fs.createReadStream(file)) h.update(c);return h.digest('hex');}
const checksums={};
for(const folder of ['records','index']) for(const f of fs.readdirSync(path.join(out,folder)).sort()) checksums[`${folder}/${f}`]=await sha(path.join(out,folder,f));
const manifest={database_version:'WFO-2026-06',schema_version:1,build_version:version,index_version:1,description_generation_version:version,
  source,input_file:path.basename(input),input_sha256:await sha(input),counts:{...counts,accepted:built,descriptions:built,taxonomy_only:built,basic:0,enriched:0},
  record_shards:1024,index_files:Object.keys(checksums).filter(x=>x.startsWith('index/')).length,checksums};
fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
fs.writeFileSync(path.join(out,'manifest.dat'),`(TT_PLANT_DATABASE (DATA_SCHEMA_VERSION . 1) (DATABASE_VERSION . "WFO-2026-06") (BUILD_VERSION . "${version}") (INDEX_VERSION . 1) (ACCEPTED_COUNT . ${built}) (ALIAS_COUNT . ${counts.aliases}) (DESCRIPTION_COUNT . ${built}) (RECORD_SHARDS . 1024) ${pair('SOURCE_URL',source.url)} ${pair('SOURCE_LICENSE',source.license)})\n`);
console.log(JSON.stringify({accepted:built,aliases:counts.aliases,seconds:(Date.now()-started)/1000,output:path.resolve(out)}));
