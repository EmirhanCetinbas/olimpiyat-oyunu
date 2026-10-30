'use strict';
// Scenery contains no athletes, barbell or kilogram sign; all three are live components.
let weightCompleted=[];
const weightBench=i=>({x:27+i*9,y:81.5});
const weightIconRects={'weight-strength':[48,1000,105,90],'weight-grip':[500,1000,110,92],'weight-balance':[48,1252,106,94],'weight-finish':[500,1252,110,94]};
function paintWeightArt(el,key){
 const r=weightIconRects[key];if(!r)return false;
 el.style.backgroundImage="url('assets/weights-icons-source.png')";
 el.style.backgroundSize=`${941/r[2]*100}% ${1672/r[3]*100}%`;
 el.style.backgroundPosition=`${r[0]/(941-r[2])*100}% ${r[1]/(1672-r[3])*100}%`;
 return true;
}

function weightAttempt(id,levels,noise=Math.random(),roll=Math.random()){
 const strength=1+(levels[0]-1)*.025+(levels[3]-1)*.01;
 const kg=Math.max(20,Math.round((70+noise*25)*strength*specialty('weights',id)*[.98,1,1.07,.94,1.02,1][id]/5)*5);
 const chance=Math.min(.98,.72+(levels[1]-1)*.008+(levels[2]-1)*.009+(levels[3]-1)*.003);
 return{kg,chance,roll,success:roll<chance};
}

function positionWeightAvatars(){
 runnerEls.forEach((el,i)=>{const p=weightBench(i);el.style.left=p.x+'%';el.style.top=p.y+'%';});
 const bar=$('#weight-bar');let barY=66,tilt=0;
 if(race?.branch==='weights'){
  const w=race.weights,i=w.turn,t=Math.max(0,Math.min(1,w.time/w.duration));
  const bench=weightBench(i),stage={x:50,y:55};let p=stage;
  if(w.phase==='walk')p={x:bench.x+(stage.x-bench.x)*t,y:bench.y+(stage.y-bench.y)*t};
  if(w.phase==='pull')barY=66-8*t;
  if(w.phase==='push'){barY=w.attempts[i].success?58-13*t:58+8*t;tilt=w.attempts[i].success?0:Math.sin(t*Math.PI)*8;}
  if(w.phase==='hold')barY=w.attempts[i].success?45:66;
  if(w.phase==='lower')barY=w.attempts[i].success?45+21*t:66;
  if(w.phase==='return')p={x:stage.x+(bench.x-stage.x)*t,y:stage.y+(bench.y-stage.y)*t};
  runnerEls[i].style.left=p.x+'%';runnerEls[i].style.top=p.y+'%';
 }
 bar.style.top=barY+'%';bar.style.transform=`translate(-50%,-50%) rotate(${tilt}deg)`;
}

function renderWeightArena(){
 $('#stadium-art').src='assets/weights-arena.png';$('#stadium-art').alt='Hayvan tribünlü halter platformu, iki yanda ağırlıklar ve altta bekleme bankı';
 $('#branch-name').textContent='HALTER';$('.branch .art').dataset.art='weight-strength';paintArt($('.branch .art'),'weight-strength');
 $('#weight-hud').hidden=false;$('#start').textContent='Kaldırışa Başla ▶';
 $('#risk-choice').hidden=false;$('#risk-choice').textContent=state.weightRisk==='record'?'Rekor denemesi':'Güvenli kilo';
 $('#race-status').textContent='Sporcular sırayla kaldırır · En yüksek başarılı kilo kazanır.';
 positionWeightAvatars();updateWeightHUD();
}

function updateWeightHUD(){
 if(state.branch!=='weights')return;
 const w=race?.branch==='weights'?race.weights:null,player=weightCompleted.find(r=>r.id===state.selected);
 $('#round').textContent=(w?w.turn+1:weightCompleted.length?6:1)+' / 6';
 $('#timer').textContent='DENEME';
 $('#weight-kg').textContent=(w?w.attempts[w.turn].kg:player?.kg||80)+' KG';
 const status=$('#weight-result');
 if(w){
  const current=weightCompleted.find(r=>r.id===race.ids[w.turn]);
  status.textContent=current?(current.success?'✓ BAŞARILI':'✕ BAŞARISIZ'):'';
 }else status.textContent=player?(player.success?'✓ '+player.kg+' KG':'✕ BAŞARISIZ'):'';
 status.classList[(w?weightCompleted.at(-1)?.success:player?.success)?'remove':'add']('failed');
}

function beginWeights(){
 if(race||paused)return{ok:false,reason:'Yarış zaten sürüyor'};
 resultDelay=0;weightCompleted=[];
 const ids=lineup(),levels=[...state.weightLevels],campus=[0,1,2].map(i=>campusRank('weights',i)),trainingCard=consumeTrainingCard('weights');
 race={branch:'weights',phase:'lifting',ids,playerLane:ids.indexOf(state.selected),elapsed:0,
  weights:{turn:0,phase:'walk',time:0,duration:.8,levels,campus,results:[],attempts:ids.map(id=>{const attempt=weightAttempt(id,id===state.selected?levels:[1,1,1,1]);if(id===state.selected){const risk=state.weightRisk==='record';attempt.kg=Math.round(attempt.kg*(1+campus[0]*.01+campus[2]*.006+(trainingCard?.03:0))*(risk?1.15:1)/5)*5;attempt.chance=Math.min(.98,Math.max(.12,attempt.chance+(campus[1]*.009)-(risk?.18:0)));attempt.success=attempt.roll<attempt.chance;}return attempt;})}};
 runners();$('.stadium').classList.remove('idle');$('#race-call').hidden=true;$('#live-tag').hidden=false;
 $('#race-status').textContent=animals[ids[0]].name+' platforma geliyor.';update();return{ok:true};
}

function advanceWeights(dt){
 const w=race.weights;race.elapsed+=dt;w.time+=dt;
 if(w.time>=w.duration){
  w.time=0;
  const id=race.ids[w.turn],a=animals[id],attempt=w.attempts[w.turn];
  if(w.phase==='walk'){w.phase='ready';w.duration=.5;$('#race-status').textContent=a.name+' · '+attempt.kg+' KG hazırlanıyor.';}
  else if(w.phase==='ready'){w.phase='pull';w.duration=1.2;beep(500,.05);}
  else if(w.phase==='pull'){w.phase='push';w.duration=1;if(id===state.selected)offerMove('weights',1,'Kaldır!');}
  else if(w.phase==='push'){
   if(id===state.selected){attempt.success=attempt.success||moveQuality()>.7;clearMove();}
   w.phase='hold';w.duration=.85;w.results.push({id,...attempt});weightCompleted=[...w.results];
   $('#race-status').textContent=a.name+' · '+attempt.kg+' KG · '+(attempt.success?'Başarılı!':'Kaldıramadı');beep(attempt.success?850:300,.1);
  }else if(w.phase==='hold'){w.phase='lower';w.duration=.6;}
  else if(w.phase==='lower'){w.phase='return';w.duration=.7;}
  else if(w.phase==='return'){
   w.turn++;if(w.turn===race.ids.length){finishWeights();return;}
   w.phase='walk';w.duration=.8;$('#race-status').textContent=animals[race.ids[w.turn]].name+' sıradaki sporcu.';
  }
 }
 positionWeightAvatars();updateWeightHUD();
}

function finishWeights(){
 const results=[...race.weights.results],player=results.find(r=>r.id===state.selected);
 const place=player.success?1+results.filter(r=>r.success&&r.kg>player.kg).length:results.length;
 state.races++;state.xp+=place===1?30:15;if(player.success&&place===1)state.wins++;if(player.success&&place<=3)state.medals++;
 if(state.races%5===0){state.chests++;state.skillPoints++;}
 if(player.success)state.bestWeight=Math.max(state.bestWeight,player.kg);recordTournament('weights',place);
 const reward=Math.round((place===1?1250:place===2?850:place===3?650:400)*(1+campusRank('stadium',2)*.03));state.money+=reward;
 race=null;positionWeightAvatars();$('.stadium').classList.add('idle');$('#live-tag').hidden=true;
 const summary=player.success?place+'. sıra · '+player.kg+' KG':'Kaldırış başarısız';
 $('#race-status').textContent=summary+' · +₺'+fmt(reward);$('#race-call').hidden=false;$('#race-call>span').textContent=summary;
 $('#start').textContent='Tekrar Kaldır ▶';resultDelay=state.auto?6:0;toast(summary+' · +₺'+fmt(reward));save();update();
}
