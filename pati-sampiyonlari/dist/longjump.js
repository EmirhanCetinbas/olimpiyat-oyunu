'use strict';
// Coordinates follow the empty 1536×1024 arena asset, never the viewport.
const jumpGeometry={startX:10.3,takeoffX:60.6,trackY:64,pitX:65.5,pitWidth:30,benchY:85.5};
const jumpColors=['#ffbe13','#27bdf6','#ef6955','#bf70ef','#18b87b','#ff8b27'];
let jumpCompleted=[];
const jumpMetres=n=>Number(n).toFixed(2).replace('.',',')+' m';
const jumpBench=i=>({x:24+i*7,y:jumpGeometry.benchY});
const jumpLanding=(metres,i)=>({x:jumpGeometry.pitX+metres/10*jumpGeometry.pitWidth,y:52+i*5});

function renderJumpFlags(){
 $('#jump-flags').innerHTML=jumpCompleted.map((r,i)=>{const p=jumpLanding(r.metres,i),a=animals[r.id];return `<button class="landing-flag" style="left:${p.x}%;top:${p.y}%;--flag-color:${jumpColors[i]}" data-jump-result="${i}" aria-label="${a.name}: ${jumpMetres(r.metres)}" title="${a.name}: ${jumpMetres(r.metres)}"><span aria-hidden="true">⚑</span><b>${i+1}</b><small>${a.name} · ${jumpMetres(r.metres)}</small></button>`;}).join('');
}

function placeJumpAvatar(i,p,airborne=false){
 const el=runnerEls[i];if(!el)return;
 el.style.left=p.x+'%';el.style.top=p.y+'%';el.style.zIndex=airborne?'5':'2';
 el.classList[airborne?'add':'remove']('airborne');
}

function positionJumpAvatars(){
 runnerEls.forEach((_,i)=>placeJumpAvatar(i,jumpBench(i)));
 if(!race||race.branch!=='longjump')return;
 const j=race.jump,i=j.turn;if(i>=race.ids.length)return;
 const bench=jumpBench(i),start={x:jumpGeometry.startX,y:jumpGeometry.trackY};
 const land=jumpLanding(j.distances[i],i),t=Math.max(0,Math.min(1,j.time/j.duration));
 let p=bench;
 if(j.phase==='ready')p={x:bench.x+(start.x-bench.x)*t,y:bench.y+(start.y-bench.y)*t};
 if(j.phase==='runup')p={x:start.x+(jumpGeometry.takeoffX-start.x)*t,y:start.y};
 if(j.phase==='flight')p={x:jumpGeometry.takeoffX+(land.x-jumpGeometry.takeoffX)*t,y:start.y+(land.y-start.y)*t-Math.sin(t*Math.PI)*12};
 if(j.phase==='landed')p=land;
 if(j.phase==='return')p={x:land.x+(bench.x-land.x)*t,y:land.y+(bench.y-land.y)*t};
 placeJumpAvatar(i,p,j.phase==='flight');
}

function longJumpDistance(id,levels,noise=Math.random()){
 // Every upgrade affects measured distance; the whole contest uses a start snapshot.
 const bonus=(levels[0]-1)*.007+(levels[1]-1)*.009+(levels[2]-1)*.016+(levels[3]-1)*.011;
 return Math.round(Math.min(9.65,(4.7+noise*1.3)*animals[id].speed*specialty('longjump',id)*(1+bonus))*100)/100;
}

function beginLongJump(){
 if(race||paused)return{ok:false,reason:'Yarış zaten sürüyor'};
 resultDelay=0;jumpCompleted=[];renderJumpFlags();
 const ids=lineup(),levels=[...state.longJumpLevels],campus=[0,1,2].map(i=>campusRank('jump',i)),trainingCard=consumeTrainingCard('longjump');
 race={branch:'longjump',phase:'jumping',ids,playerLane:ids.indexOf(state.selected),elapsed:0,
  jump:{turn:0,phase:'ready',time:0,duration:.7,levels,campus,results:[],
   distances:ids.map(id=>Math.min(9.95,longJumpDistance(id,id===state.selected?levels:[1,1,1,1])*(id===state.selected?1+campus.reduce((n,v)=>n+v,0)*.01+(trainingCard?.03:0):1)))}};
 runners();$('.stadium').classList.remove('idle');$('#race-call').hidden=true;$('#live-tag').hidden=false;
 $('#race-status').textContent=animals[ids[0]].name+' başlangıç çizgisine geliyor.';beep(500);update();
 return{ok:true};
}

function advanceLongJump(dt){
 const j=race.jump;race.elapsed+=dt;j.time+=dt;
 if(j.time>=j.duration){
  j.time=0;
  if(j.phase==='ready'){
   j.phase='runup';j.duration=3/(1+(j.levels[0]-1)*.015+(j.levels[1]-1)*.01);
   if(race.ids[j.turn]!==state.selected)j.duration=3;else offerMove('longjump',j.duration,'Sıçra!');
   $('#race-status').textContent=animals[race.ids[j.turn]].name+' yaklaşıyor · '+(j.turn+1)+'/6';
  }else if(j.phase==='runup'){if(race.ids[j.turn]===state.selected){j.distances[j.turn]=Math.min(9.95,j.distances[j.turn]*(1+moveQuality()*.035));clearMove();}j.phase='flight';j.duration=1.1;beep(750,.06);}
  else if(j.phase==='flight'){
   j.phase='landed';j.duration=.85;
   const result={id:race.ids[j.turn],metres:Math.round(Math.min(9.95,j.distances[j.turn])*100)/100};j.results.push(result);
   jumpCompleted=[...j.results];renderJumpFlags();
   $('#race-status').textContent=animals[result.id].name+' · '+jumpMetres(result.metres);beep(650,.06);
  }else if(j.phase==='landed'){j.phase='return';j.duration=.7;}
  else if(j.phase==='return'){
   j.turn++;
   if(j.turn===race.ids.length){finishLongJump();return;}
   j.phase='ready';j.duration=.7;
   $('#race-status').textContent=animals[race.ids[j.turn]].name+' sıradaki sporcu.';
  }
 }
 positionJumpAvatars();updateLongJumpHUD();
}

function updateLongJumpHUD(){
 if(state.branch!=='longjump')return;
 $('#round').textContent=(race?.branch==='longjump'?Math.min(6,race.jump.turn+1):jumpCompleted.length?6:1)+' / 6';
 const last=jumpCompleted.at(-1);
 $('#timer').textContent=race?'DENEME':last?'EN İYİ '+jumpMetres(Math.max(...jumpCompleted.map(r=>r.metres))):'DENEME';
}

function finishLongJump(){
 const results=[...race.jump.results],player=results.find(r=>r.id===state.selected);
 const sorted=[...results].sort((a,b)=>b.metres-a.metres),place=sorted.findIndex(r=>r.id===state.selected)+1;
 state.races++;state.xp+=place===1?30:15;if(place===1)state.wins++;if(place<=3)state.medals++;
 if(state.races%5===0){state.chests++;state.skillPoints++;}
 state.bestJump=Math.max(Number(state.bestJump)||0,player.metres);recordTournament('longjump',place);
 const reward=Math.round((place===1?1250:place===2?850:place===3?650:400)*(1+campusRank('stadium',2)*.03));
 state.money+=reward;race=null;positionJumpAvatars();$('.stadium').classList.add('idle');$('#live-tag').hidden=true;
 $('#race-status').textContent=place+'. sıra · '+jumpMetres(player.metres)+' · +₺'+fmt(reward);
 $('#race-call').hidden=false;$('#race-call>span').textContent=place+'. sıra · '+jumpMetres(player.metres);
 $('#start').textContent='Tekrar Atla ▶';resultDelay=state.auto?6:0;
 toast(place+'. sıra · '+jumpMetres(player.metres)+' · +₺'+fmt(reward));save();update();
}

document.addEventListener('click',e=>{
 const marker=e.target.closest('[data-jump-result]');if(!marker)return;
 const result=jumpCompleted[Number(marker.dataset.jumpResult)];
 if(result)toast(animals[result.id].name+' · '+jumpMetres(result.metres));
});
