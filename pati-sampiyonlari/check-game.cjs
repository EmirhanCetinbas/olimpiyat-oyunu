const vm=require('node:vm'),fs=require('node:fs'),assert=require('node:assert/strict');
const elements=new Map(),registered=new Map(),data=new Map();
function element(id){if(!elements.has(id))elements.set(id,{id,style:{},dataset:{},classList:{add(){},remove(){}},textContent:'',innerHTML:'',hidden:false,disabled:false,open:false,value:'',addEventListener(){},setAttribute(){},querySelectorAll(){return[]},showModal(){this.open=true},close(){this.open=false}});return elements.get(id)}
const up=Array.from({length:6},(_,i)=>Object.assign(element('upgrade'+i),{dataset:{upgrade:String(i)}}));
const runners=Array.from({length:6},(_,i)=>element('runner'+i));
const ctx={console,Math,Date,Number,JSON,Array,Error,performance:{now:()=>0},setTimeout:()=>0,clearTimeout(){},requestAnimationFrame(){},localStorage:{getItem:k=>data.get(k)||null,setItem:(k,v)=>data.set(k,v)},window:{addEventListener(){}},document:{querySelector:element,querySelectorAll:s=>s==='[data-upgrade]'?up:s==='.runner'?runners:[],addEventListener(){},modelContext:{registerTool(t){registered.set(t.name,t)}}}};
vm.createContext(ctx);vm.runInContext(fs.readFileSync('dist/chests.js','utf8'),ctx);vm.runInContext(fs.readFileSync('dist/moves.js','utf8'),ctx);vm.runInContext(fs.readFileSync('dist/longjump.js','utf8'),ctx);vm.runInContext(fs.readFileSync('dist/weights.js','utf8'),ctx);vm.runInContext(fs.readFileSync('dist/archery.js','utf8'),ctx);vm.runInContext(fs.readFileSync('dist/game.js','utf8'),ctx);
const run=s=>vm.runInContext(s,ctx);
assert.equal(run('state.money'),3500);assert.equal(run('state.races'),0);assert.equal(run('state.levels.length'),6);assert.equal(run('income()'),45);
let before=run('state.money'),beforeIncome=run('income()');assert.equal(run('upgrade(0).ok'),true);assert.equal(run('state.money'),before-750);assert.equal(run('state.levels[0]'),2);assert.equal(run('income()'),beforeIncome);
run('state.money=0');assert.equal(run('upgrade(1).ok'),false);assert.equal(run('state.levels[1]'),1);
assert.throws(()=>run('upgrade(7)'),/Geçersiz/);
run('state.money=10000');beforeIncome=run('income()');assert.equal(run('upgrade(4).ok'),true);assert.equal(run('income()'),beforeIncome+12);beforeIncome=run('income()');assert.equal(run('upgrade(5).ok'),true);assert.equal(run('income()'),beforeIncome+18);
run('state.auto=false;state.money=3500;beginRace()');assert.equal(run('!!race'),true);assert.equal(run('race.progress.length'),4);assert.equal(run('runnerEls.length'),4);assert.equal(run('beginRace().ok'),false);
for(let i=1;i<=1800;i++)run(`tick(${i*16.667})`);
assert.equal(run('state.races'),1);assert.equal(run('race'),null);assert.ok(run('state.money')>3500);assert.ok(run('state.best')>0);assert.ok(run('state.xp')>=15);
const read=registered.get('read_game_state');assert.equal(read.annotations.readOnlyHint,true);assert.equal(read.execute().races,1);
const action=registered.get('upgrade_athlete');assert.equal(action.execute({index:1}).ok,true);assert.equal(read.execute().levels[1],2);assert.throws(()=>action.execute({index:-1}),/Geçersiz/);
run('save()');const saved=JSON.parse(data.get('pati-champions-v1'));assert.equal(saved.races,1);assert.equal(saved.levels[1],2);
run('state.money=1000000;state.auto=false');
for(let i=0;i<4;i++){for(let star=0;star<3;star++)assert.equal(run(`buyEquipment(${i})`),true);assert.equal(run(`buyEquipment(${i})`),false)}
assert.equal(run('state.equipmentStars.join(",")'),'3,3,3,3');
run('beginRace()');assert.equal(run('race.equipmentStars.join(",")'),'3,3,3,3');
run('state.races=4;race.elapsed=10;race.times=[9,10,11,12];finishRace()');assert.equal(run('state.chests'),1);
run('inventoryTab="items"');assert.match(run('inventoryHTML()'),/Spor Çantaları ×1/);
for(const asset of ['reference.png','stadium.png','park-background.png','facility-icons.png','ui-icons.png','nav-icons.png','equipment-icons.png'])assert.ok(fs.statSync('dist/assets/'+asset).size>1000);
console.log('PASS: race, save, four three-star equipment items, chest rewards, local assets');
// Baked controls must be masked and each dynamic action rendered exactly once.
run('state.dailyStep=0;state.daily=0');
assert.equal((run('settingsHTML()').match(/type="range"/g)||[]).length,2);
assert.equal((run('settingsHTML()').match(/type="checkbox"/g)||[]).length,3);
for(let day=0;day<7;day++){
 run(`state.dailyStep=${day};state.daily=0`);
 const html=run('dailyPanelHTML()');
 assert.equal((html.match(/id="claim-daily"/g)||[]).length,1);
 assert.equal((html.match(/class="daily-control /g)||[]).length,7);
 assert.equal((html.match(/class="daily-control ready"/g)||[]).length,1);
}
run('state.daily=Date.now()');assert.equal((run('dailyPanelHTML()').match(/class="daily-control ready"/g)||[]).length,0);
assert.equal((run('achievementPanelHTML()').match(/data-claim=/g)||[]).length,4);
assert.equal((run('achievementPanelHTML()').match(/<progress/g)||[]).length,5);
const css=fs.readFileSync('dist/style.css','utf8');
for(const selector of ['.exact-ach','.exact-daily'])assert.ok(css.includes(selector+'>img{mask-image:'));
console.log('PASS: single controls, reward states and masks for all three image panels');

assert.doesNotMatch(run('settingsHTML()'),/<img|settings-panel|style="top:/);
assert.match(run('settingsHTML()'),/prefs-panel/);
console.log('PASS: settings uses native markup without screenshot overlay');
// Campus upgrades: playable facilities, permanent income, race snapshots.
ctx.setInterval=()=>0;ctx.document.createElement=()=>element('campus-page');ctx.document.body={append(){},classList:{add(){},remove(){}}};
vm.runInContext(fs.readFileSync('dist/campus.js','utf8'),ctx);
run('state.skillPoints=8;state.campusUpgrades={};race=null');
assert.equal(run("buyCampusUpgrade('sprint',0)"),true);assert.equal(run('state.skillPoints'),6);
assert.equal(run("campusRank('sprint',0)"),1);
assert.equal(run("buyCampusUpgrade('weights',0)"),true);assert.equal(run('state.skillPoints'),4);
assert.equal(run("buyCampusUpgrade('sprint',9)"),false);
const campusIncome=run('passiveIncome()');assert.equal(run("buyCampusUpgrade('stadium',0)"),true);assert.ok(run('passiveIncome()')>campusIncome);
run('beginRace()');assert.equal(run('race.campus[0]'),1);run('state.skillPoints=100');run("buyCampusUpgrade('sprint',0)");assert.equal(run('race.campus[0]'),1);
run('race=null;save()');assert.equal(JSON.parse(data.get('pati-champions-v1')).campusUpgrades.sprint[0],2);
run('state.skillPoints=0');assert.equal(run("buyCampusUpgrade('sprint',1)"),false);
run('state.skillPoints=100');for(let i=0;i<7;i++)run("buyCampusUpgrade('sprint',1)");assert.equal(run("campusRank('sprint',1)"),5);assert.equal(run("buyCampusUpgrade('sprint',1)"),false);
console.log('PASS: campus SP spending, playable facilities, level cap, income effect, snapshot and save');

// Hurdles is a playable branch with six live racers and four separate obstacles per lane.
run('race=null;state.money=10000;state.auto=false;selectBranch("hurdles")');
assert.equal(run('state.branch'),'hurdles');
assert.equal(run('runnerEls.length'),6);
assert.equal((element('#hurdles').innerHTML.match(/class="hurdle"/g)||[]).length,24);
assert.equal(element('#timer').textContent,'◴ 00:00');
assert.equal(run('upgrade(0).ok'),true);
assert.equal(run('state.hurdleLevels[0]'),2);
assert.equal(run('state.levels[0]'),2);
assert.equal(run('beginRace().ok'),true);
assert.equal(run('race.progress.length'),6);
assert.equal(run('race.hurdleLevels[0]'),2);
for(let i=1;i<=1800&&run('race!==null');i++)run(`tick(${30000+i*16.667})`);
assert.equal(run('race'),null);
assert.ok(run('state.races')>=2);
assert.match(element('#timer').textContent,/◴ \d\d:\d\d/);
console.log('PASS: six-lane hurdle race, 24 obstacles, live stopwatch, branch upgrades and finish');

// Swimming uses the same live race system and a distinct saved upgrade tree.
run('race=null;state.money=10000;state.auto=false;selectBranch("swim")');
assert.equal(run('state.branch'),'swim');
assert.equal(run('runnerEls.length'),6);
assert.equal(element('#stadium-art').src,'assets/swim-arena.png');
assert.equal(element('#hurdles').innerHTML,'');
assert.equal(element('#timer').textContent,'◴ 00:00');
assert.match(element('#upgrades').innerHTML,/Kulaç Gücü/);
assert.equal(run('upgrade(1).ok'),true);
assert.equal(run('state.swimLevels[1]'),2);
assert.equal(run('beginRace().ok'),true);
assert.equal(run('race.swimLevels[1]'),2);
run('state.swimLevels[1]=3');assert.equal(run('race.swimLevels[1]'),2);
for(let i=1801;i<=3600;i++)run(`tick(${i*16.667})`);
assert.equal(run('race'),null);
assert.equal(run('state.branch'),'swim');
assert.ok(run('state.races')>=2);
assert.equal(JSON.parse(data.get('pati-champions-v1')).swimLevels[1],3);
assert.ok(fs.statSync('dist/assets/swim-arena.png').size>1000);
console.log('PASS: six-lane swimming, live avatars, standalone upgrades, race snapshot and finish');

// Long jump: one athlete at a time, each landing creates one permanent round marker.
run('race=null;state.money=10000;state.auto=false;selectBranch("longjump")');
assert.equal(run('runnerEls.length'),6);
assert.equal(element('#stadium-art').src,'assets/jump-arena.png');
assert.equal(element('#timer').textContent,'DENEME');
assert.equal(run('activeUpgrades().map(u=>u.title).join(",")'),'Çıkış Hızı,Adımlama,Sıçrama Gücü,İniş Tekniği');
assert.equal(run('upgrade(2).ok'),true);
assert.equal(run('state.longJumpLevels[2]'),2);
assert.equal(run('beginRace().ok'),true);
assert.equal(run('beginRace().ok'),false);
assert.equal(run('race.jump.levels[2]'),2);
run('state.longJumpLevels[2]=20');assert.equal(run('race.jump.levels[2]'),2);
assert.equal(run('race.jump.results.length'),0);
const jumpRaceCount=run('state.races');
run('race.jump.distances=[7,6,5,4,3,2]');
let jumpNow=run('lastFrame');
const jumpSeen=new Set();
for(let i=0;i<600&&run('race!==null');i++){
 jumpNow+=100;run(`tick(${jumpNow})`);
 if(run('race!==null'))jumpSeen.add(run('race.jump.phase'));
 const count=run('jumpCompleted.length');
 assert.equal((element('#jump-flags').innerHTML.match(/class="landing-flag"/g)||[]).length,count);
 // Every other athlete stays on the bench during the current athlete's attempt.
 if(run('race!==null'))for(let lane=0;lane<6;lane++)if(lane!==run('race.jump.turn'))assert.equal(runners[lane].style.top,'85.5%');
}
assert.equal(run('race'),null);
assert.equal(run('jumpCompleted.length'),6);
assert.equal(run('state.races'),jumpRaceCount+1);
assert.equal(run('state.bestJump'),7);
assert.equal(element('#round').textContent,'6 / 6');
for(const phase of ['ready','runup','flight','landed','return'])assert.ok(jumpSeen.has(phase));
assert.equal(JSON.parse(data.get('pati-champions-v1')).bestJump,7);
assert.equal(run('jumpCompleted.map(r=>r.id).join(",")'),run('lineup().join(",")'));
for(let i=0;i<4;i++)assert.ok(run(`longJumpDistance(0,[1,1,1,1].map((v,i)=>i===${i}?2:1),.5)>longJumpDistance(0,[1,1,1,1],.5)`));
assert.match(element('#race-status').textContent,/1. sıra/);
assert.equal(run('beginRace().ok'),true);assert.equal(run('jumpCompleted.length'),0);
assert.equal(element('#jump-flags').innerHTML,'');
run('paused=true');const jumpBefore=run('race.jump.time');run(`tick(${jumpNow+100})`);assert.equal(run('race.jump.time'),jumpBefore);
run('paused=false;race=null;selectBranch("sprint")');assert.equal(element('#jump-flags').innerHTML,'');
assert.ok(fs.statSync('dist/assets/jump-arena.png').size>1000);
assert.ok(fs.statSync('dist/assets/jump-icons-source.png').size>1000);
assert.equal(run('initial().longJumpLevels.length'),4);
console.log('PASS: sequential long jump, bench positions, six landing flags, upgrades, pause, reset and saved best distance');

// Weightlifting: six independent attempts, one moving athlete and one live barbell.
run('race=null;state.auto=false;state.money=10000;selectBranch("weights")');
assert.equal(run('runnerEls.length'),6);
assert.equal(element('#stadium-art').src,'assets/weights-arena.png');
assert.equal(element('#weight-hud').hidden,false);
assert.equal(element('#timer').textContent,'DENEME');
assert.equal(run('activeUpgrades().map(u=>u.title).join(",")'),'Temel Güç,Kavrama,Denge,Son Hamle');
assert.equal(run('upgrade(0).ok'),true);assert.equal(run('state.weightLevels[0]'),2);
assert.equal(run('beginRace().ok'),true);assert.equal(run('beginRace().ok'),false);
run('selectBranch("sprint")');assert.equal(run('state.branch'),'weights');
assert.equal(run('race.weights.levels[0]'),2);
run('state.weightLevels[0]=50');assert.equal(run('race.weights.levels[0]'),2);
run('race.weights.attempts=race.ids.map((id,i)=>({kg:100-i*5,chance:1,success:true}))');
const weightRacesBefore=run('state.races');let weightNow=run('lastFrame');const weightPhases=new Set(),barHeights=new Set();
for(let i=0;i<500&&run('race!==null');i++){
 weightNow+=100;run(`tick(${weightNow})`);barHeights.add(element('#weight-bar').style.top);
 if(run('race!==null')){
  weightPhases.add(run('race.weights.phase'));
  for(let lane=0;lane<6;lane++)if(lane!==run('race.weights.turn'))assert.equal(runners[lane].style.top,'81.5%');
 }
}
assert.equal(run('race'),null);assert.equal(run('weightCompleted.length'),6);
assert.equal(run('state.races'),weightRacesBefore+1);assert.equal(run('state.bestWeight'),100);
assert.equal(JSON.parse(data.get('pati-champions-v1')).bestWeight,100);
assert.equal(element('#round').textContent,'6 / 6');assert.match(element('#race-status').textContent,/1. sıra · 100 KG/);
assert.ok(barHeights.size>5);
for(const phase of ['walk','ready','pull','push','hold','lower','return'])assert.ok(weightPhases.has(phase));
const baseWeight=run('weightAttempt(0,[1,1,1,1],.5,.5)');
assert.ok(run('weightAttempt(0,[11,1,1,1],.5,.5).kg')>baseWeight.kg);
assert.ok(run('weightAttempt(0,[1,11,1,1],.5,.5).chance')>baseWeight.chance);
assert.ok(run('weightAttempt(0,[1,1,11,1],.5,.5).chance')>baseWeight.chance);
assert.ok(run('weightAttempt(0,[1,1,1,11],.5,.5).kg')>baseWeight.kg);
assert.equal(run('weightAttempt(0,[100,100,100,100],.5,.99).success'),false);
const winsBeforeFailure=run('state.wins'),medalsBeforeFailure=run('state.medals');
run('beginRace();race.weights.attempts=race.ids.map(id=>({kg:200,chance:0,success:false}));paused=true');
const pauseWeightTime=run('race.weights.time');run(`tick(${weightNow+100})`);assert.equal(run('race.weights.time'),pauseWeightTime);run('paused=false');
for(let i=0;i<500&&run('race!==null');i++){weightNow+=100;run(`tick(${weightNow})`);}
assert.equal(run('race'),null);assert.equal(run('state.bestWeight'),100);
assert.equal(run('state.wins'),winsBeforeFailure);assert.equal(run('state.medals'),medalsBeforeFailure);
assert.match(element('#race-status').textContent,/başarısız/);
run('selectBranch("sprint")');assert.equal(element('#weight-hud').hidden,true);
assert.equal(run('initial().weightLevels.length'),4);assert.equal(run('initial().bestWeight'),0);
for(const name of ['weights-arena.png','weights-barbell.png','weights-icons-source.png'])assert.ok(fs.statSync('dist/assets/'+name).size>1000);
console.log('PASS: weightlifting order, animated barbell, success/failure, four upgrade effects, snapshot, pause and separate saved record');
run('selectBranch("archery")');assert.equal(run('state.branch'),'archery');assert.equal(element('#archery-hud').hidden,false);assert.equal(element('#weight-hud').hidden,true);
assert.equal(run('activeUpgrades().map(u=>u.title).join(",")'),'Nişan Alma,Yay Gücü,Rüzgâr Okuma,Son Atış');
assert.equal(run('upgrade(0).ok'),true);assert.equal(run('beginRace().ok'),true);assert.equal(run('race.ids.length'),6);
assert.equal(run('race.archery.levels[0]'),2);run('state.archeryLevels[0]=50');assert.equal(run('race.archery.levels[0]'),2);
run('race.archery.shots=race.ids.map((id,i)=>Array.from({length:3},()=>({points:10-i})))');let archeryNow=run('lastFrame');const phases=new Set(),arrowPositions=new Set();
for(let i=0;i<700&&run('race!==null');i++){archeryNow+=100;run(`tick(${archeryNow})`);arrowPositions.add(element('#archery-arrow').style.left);if(run('race!==null')){phases.add(run('race.archery.phase'));for(let lane=0;lane<6;lane++)if(lane!==run('race.archery.turn'))assert.equal(runners[lane].style.top,'87%');}}
assert.equal(run('race'),null);assert.equal(run('archeryCompleted.length'),6);assert.equal(run('state.bestArchery'),30);assert.match(element('#race-status').textContent,/1. sıra · 30 puan/);assert.ok(arrowPositions.size>4);
for(const phase of ['walk','aim','flight','hit','return'])assert.ok(phases.has(phase));
assert.ok(run('archeryShot(0,[21,1,1,1],1).points')>=run('archeryShot(0,[1,1,1,1],1).points'));
assert.ok(run('archeryShot(0,[1,21,1,1],1).points')>=run('archeryShot(0,[1,1,1,1],1).points'));
assert.ok(run('archeryShot(0,[1,1,21,1],1).points')>=run('archeryShot(0,[1,1,1,1],1).points'));
assert.ok(run('archeryShot(0,[1,1,1,21],1).points')>=run('archeryShot(0,[1,1,1,1],1).points'));
assert.ok(fs.statSync('dist/assets/archery-arena.png').size>1000);
console.log('PASS: archery six lanes, sequential shots, live arrow, scoring, snapshot and saved record');
run("offerMove('archery',2,'Nişanı bırak!');tickMove(1)");assert.equal(run('tapMove()'),true);assert.equal(run('moveQuality()'),1);assert.equal(run('tapMove()'),false);run('clearMove()');assert.equal(element('#skill-move').hidden,true);
run('state.tournament=null;state.tournamentCups=0;state.skillPoints=0;state.money=0');assert.equal(run('startTournament()'),true);assert.equal(run('startTournament()'),false);
run("recordTournament('archery',1);recordTournament('archery',2)");assert.equal(run('state.tournament.podiums'),2);run("recordTournament('archery',6)");assert.equal(run('state.tournament.attempts'),3);assert.equal(run('state.tournamentCups'),1);assert.equal(run('state.skillPoints'),1);assert.equal(run('state.cupChests'),1);
run("recordTournament('archery',1)");assert.equal(run('state.tournamentCups'),1);assert.equal(run('startTournament()'),true);
run('state.weightRisk="record";selectBranch("weights");beginRace()');assert.ok(run('race.weights.attempts[0].chance')<.7);assert.equal(run('specialty("weights",2)'),1.06);assert.match(run('tournamentHTML()'),/Üç yarışta en az iki kez/);
console.log('PASS: optional timing input, one-time tournament rewards, athlete specialties and weight risk');
run('race=null;state.cupChests=1;state.championChests=1;state.chests=1;state.pendingChest=null;state.equipmentParts=0;state.cosmetics=[]');
assert.equal(run("openChest('cup')"),true);assert.equal(run('state.cupChests'),0);assert.equal(run('state.pendingChest.offers.every(o=>o.kind==="bundle")'),true);
assert.equal(run("openChest('normal')"),true);assert.equal(run('state.chests'),1);assert.ok(JSON.parse(data.get('pati-champions-v1')).pendingChest);
assert.ok(run('chooseChest(0)'));assert.equal(run('state.pendingChest'),null);assert.ok(run('state.equipmentParts')>=2);assert.equal(run('chooseChest(0)'),false);
assert.equal(run("openChest('champion')"),true);assert.equal(run('state.pendingChest.offers.every(o=>o.kind==="cosmetic")'),true);assert.ok(run('chooseChest(1)'));assert.equal(run('state.cosmetics.length'),1);
run('state.equipmentParts=5;state.equipmentStars[1]=0;state.money=0');assert.equal(run('buyEquipment(1,true)'),true);assert.equal(run('state.equipmentStars[1]'),1);assert.equal(run('state.equipmentParts'),0);
run('state.trainingCards.archery=1;selectBranch("archery");beginRace()');assert.equal(run('state.trainingCards.archery'),0);assert.equal(run('beginRace().ok'),false);
console.log('PASS: persistent three-choice chests, guaranteed cup parts and champion cosmetic, fragment upgrades and one-use training card');
