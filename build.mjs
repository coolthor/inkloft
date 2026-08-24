import fs from 'node:fs';
import path from 'node:path';

const ROOT='content/stories';
const out={};
for(const dir of fs.readdirSync(ROOT)){
  const wdir=path.join(ROOT,dir);
  if(dir.startsWith('.')||!fs.statSync(wdir).isDirectory())continue;
  const meta=JSON.parse(fs.readFileSync(path.join(wdir,'meta.json'),'utf8'));
  const chdir=path.join(wdir,'chapters');
  const chapters=[];
  for(const f of fs.readdirSync(chdir).sort()){
    if(!f.endsWith('.md'))continue;
    const raw=fs.readFileSync(path.join(chdir,f),'utf8');
    const fm=raw.match(/^---\n([\s\S]*?)\n---\n/);
    const body=fm?raw.slice(fm[0].length):raw;
    const m2={};
    if(fm){for(const line of fm[1].split('\n')){const m=line.match(/^([A-Za-z]+):\s*(.*)$/);if(m)m2[m[1]]=m[2].replace(/^"|"$/g,'');}}
    const n=parseInt(m2.n||'0');
    const paras=body.split(/\n\s*\n/).map(p=>p.trim()).filter(Boolean);
    chapters.push({
      n,
      t:m2.title||f.replace(/\.md$/,''),
      w:m2.wc||('约 '+paras.join('').length+' 字'),
      date:m2.date||'',
      body:paras
    });
  }
  chapters.sort((a,b)=>a.n-b.n);
  out[dir]={title:meta.title,en:meta.en||'',status:meta.status||'',tagline:meta.tagline||'',cover:meta.cover||'',chapters};
}
fs.writeFileSync('data.json',JSON.stringify(out,null,2));
console.log('data.json 生成:', Object.keys(out), '章数:', Object.values(out).reduce((s,w)=>s+w.chapters.length,0));
