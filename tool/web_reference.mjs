// Orijinal web oyununu headless Chrome'da aynı senaryolarla çalıştırıp referans görüntü alır.
// node tool/web_reference.mjs [çıktı-kökü] [yalnız-önek]
import { spawn } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

const root = process.argv[2] ?? 'docs/verification';
const only = process.argv[3] ?? '';
const date = new Date().toISOString().slice(0, 10);
const { base, scenarios } = JSON.parse(readFileSync('tool/scenarios.json', 'utf8'));
const page = 'file://' + resolve('pati-sampiyonlari/dist/index.html');
const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const port = 9333;

const proc = spawn(chrome, [
  '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${mkdtempSync(join(tmpdir(), 'pati-chrome-'))}`,
  '--hide-scrollbars', '--no-first-run', '--autoplay-policy=no-user-gesture-required', 'about:blank',
], { stdio: 'ignore' });
const sleep = ms => new Promise(r => setTimeout(r, ms));

let targets;
for (let i = 0; i < 50 && !targets; i++) {
  await sleep(200);
  try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); } catch {}
}
const ws = new WebSocket(targets.find(t => t.type === 'page').webSocketDebuggerUrl);
await new Promise(r => ws.addEventListener('open', r, { once: true }));
let nextId = 0;
const pending = new Map(), listeners = [];
ws.addEventListener('message', e => {
  const msg = JSON.parse(e.data);
  if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); }
  else listeners.forEach(l => l(msg));
});
const send = (method, params = {}) => new Promise((ok, fail) => {
  const id = ++nextId;
  pending.set(id, m => (m.error ? fail(new Error(method + ': ' + m.error.message)) : ok(m.result)));
  ws.send(JSON.stringify({ id, method, params }));
});
const event = name => new Promise(r => { const l = m => { if (m.method === name) { listeners.splice(listeners.indexOf(l), 1); r(m); } }; listeners.push(l); });
const evaluate = async expression => {
  const res = await send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true });
  if (res.exceptionDetails) throw new Error(res.exceptionDetails.exception?.description ?? expression);
  return res.result.value;
};

// Determinizm: rAF durur, zaman elle ilerler, Math.random Flutter tarafıyla aynı (mulberry32).
await send('Page.enable');
await send('Page.addScriptToEvaluateOnNewDocument', { source: `
  (function(){let a=12345;Math.random=function(){a|=0;a=a+0x6D2B79F5|0;let t=Math.imul(a^a>>>15,1|a);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296;};})();
  window.__t=0;performance.now=()=>window.__t;window.requestAnimationFrame=()=>0;
  window.__advance=s=>{const n=Math.round(s*60);for(let i=0;i<n;i++){window.__t+=1000/60;tick(window.__t);}};
` });

const J = JSON.stringify;
const actions = {
  begin: () => 'beginRace()',
  advance: s => `__advance(${s})`,
  open: k => `openPanel(${J(k)})`,
  inventoryTab: t => `inventoryTab=${J(t)};openPanel('inventory')`,
  info: i => `document.querySelector('[data-info="${i}"]').click()`,
  support: () => `document.getElementById('settings-support').click()`,
  reset: () => `document.getElementById('reset-ask').click()`,
  rewardsMenu: () => `document.getElementById('rewards-trigger').click()`,
  upgrade: i => `upgrade(${i})`,
  openChest: t => `openChest(${J(t)});openPanel('chests')`,
  chooseChest: i => `document.querySelector('[data-chest-choice="${i}"]').click()`,
  campusFacility: id => `showCampusFacility(${J(id)})`,
  spinUsed: () => 'state.spinDate=todayKey()',
  dailyClaimed: () => 'state.daily=Date.now()',
  keepToast: () => 'window.__keepToast=true',
  tapMove: () => 'tapMove()',
};
const settle = () => evaluate(`(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(i=>i.complete?0:new Promise(r=>{i.onload=i.onerror=r})));await new Promise(r=>setTimeout(r,250));})()`);

await send('Page.navigate', { url: page });
await event('Page.loadEventFired');
for (const s of scenarios) {
  if (only && !s.name.startsWith(only)) continue;
  const [width, height] = s.size ?? [390, 844];
  await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 1, mobile: true });
  const preset = { ...base, ...(s.state ?? {}) };
  await evaluate(`state=Object.assign(initial(),${J(preset)},{last:Date.now()});save();`);
  const loaded = event('Page.loadEventFired');
  await send('Page.reload', { ignoreCache: false });
  await loaded;
  await evaluate(`(()=>{const st=document.createElement('style');st.textContent='*,*:before,*:after{transition:none!important;animation:none!important}';document.head.append(st);})()`);
  await settle();
  for (const [action, arg] of s.steps ?? []) await evaluate(actions[action](arg));
  await evaluate(`if(!window.__keepToast)document.getElementById('toast').classList.remove('visible')`);
  await settle();
  const shot = await send('Page.captureScreenshot', { format: 'png' });
  const dir = join(root, `${s.name}-${date}`);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, `${s.name}-web.png`), Buffer.from(shot.data, 'base64'));
  process.stdout.write(`web ${s.name}\n`);
}
ws.close();
proc.kill();
