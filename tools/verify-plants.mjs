// Optional package verification. Does not modify installed data.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {createInterface} from 'node:readline';
const root=path.resolve(process.argv[2]||'data/plants/production');
const m=JSON.parse(fs.readFileSync(path.join(root,'manifest.json'),'utf8'));
if(m.schema_version!==1 || m.index_version!==1 || m.source.license!=='CC0-1.0') throw Error('Unsupported manifest');
let records=0,aliases=0,descriptions=0,files=0; const ids=new Set();
for(const [rel,expected] of Object.entries(m.checksums)) {
  if(!/^(records\/[0-9]+|index\/[A-Z0-9]{2})\.dat$/.test(rel)) throw Error(`Unsafe manifest path ${rel}`);
  const file=path.join(root,rel), hash=crypto.createHash('sha256');
  for await(const chunk of fs.createReadStream(file)) hash.update(chunk);
  if(hash.digest('hex')!==expected) throw Error(`Checksum mismatch ${rel}`);
  if(rel.startsWith('records/')) {
    for await(const line of createInterface({input:fs.createReadStream(file,{encoding:'utf8'}),crlfDelay:Infinity})) {
      const id=line.match(/\(PLANT_ID \. "(WFO-\d{10})"\)/)?.[1];
      if(!id || ids.has(id)) throw Error(`Missing/duplicate ID ${rel}`);
      ids.add(id);records++;
      if(!line.includes('(TAXONOMIC_STATUS . "ACCEPTED")')) throw Error('Nonaccepted production record');
      if(!line.includes('(SOURCE_LICENSE . "CC0-1.0")')) throw Error('Missing license');
      if(line.includes('(GENERATED_DESCRIPTION . "') && line.includes('(DESCRIPTION_COMPLETENESS . "TAXONOMY_ONLY")')) descriptions++;
      aliases+=(line.match(/\(SOURCE_ALIAS_IDS ([^)]*)\)/)?.[1].match(/wfo-\d{10}/g)||[]).length;
    }
  }
  files++;
}
if(records!==m.counts.accepted || aliases!==m.counts.aliases || descriptions!==m.counts.descriptions) throw Error('Counts do not match manifest');
console.log(JSON.stringify({status:'PASS',files,records,aliases,descriptions,input_sha256:m.input_sha256},null,2));
