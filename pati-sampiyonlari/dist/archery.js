'use strict';
// The arena image is scenery; arrows, portraits and scores remain live UI.
let archeryCompleted=[];
const archeryBench=i=>({x:30+i*10,y:87});
const archeryRow=i=>31.4+i*9.1;
function paintArcheryArt(el,key){const icons={'archery-aim':'🎯','archery-bow':'🏹','archery-wind':'🍃','archery-last':'➶'};if(!icons[key])return false;el.style.backgroundImage='none';el.textContent=icons[key];return true;}
function archeryShot(id,levels,noise=Math.random(),campus=[0,0,0],arrow=0){
 const accuracy=.47+(levels[0]-1)*.014+(levels[2]-1)*.009+(levels[3]-1)*.006+(specialty('archery',id)-1)*2;
 const power=(levels[1]-1)*.008;
 const offset=Math.abs(noise-.5)*2;
 const points=Math.max(1,Math.min(10,Math.round(10-offset*8+accuracy*2+power*4+campus[0]*.32+campus[1]*.3+(arrow===2?campus[2]*.42:0))));
 return{points};
}
function positionArcheryAvatars(){
 runnerEls.forEach((el,i)=>{const p=archeryBench(i);el.style.left=p.x+'%';el.style.top=p.y+'%';});
 const a=race?.branch==='archery'?race.archery:null;
 if(!a)return;
 const i=a.turn,t=Math.min(1,a.time/a.duration),bench=archeryBench(i),stage={x:22,y:archeryRow(i)};
 let pos=stage;
 if(a.phase==='walk')pos={x:bench.x+(stage.x-bench.x)*t,y:bench.y+(stage.y-bench.y)*t};
 if(a.phase==='return')pos={x:stage.x+(bench.x-stage.x)*t,y:stage.y+(bench.y-stage.y)*t};
 runnerEls[i].style.left=pos.x+'%';runnerEls[i].style.top=pos.y+'%';
 const arrow=$('#archery-arrow');arrow.style.top=archeryRow(i)+'%';arrow.style.left=(a.phase==='flight'?26+56*t:a.phase==='hit'?82:26)+'%';arrow.hidden=!['flight','hit'].includes(a.phase);
}
function renderArcheryArena(){
 $('#stadium-art').src='assets/archery-arena.png';$('#stadium-art').alt='Hayvan seyircili altı kulvarlı okçuluk alanı, sağda hedefler ve altta bekleme bankı';
 $('#branch-name').textContent='OKÇULUK';$('.branch .art').dataset.art='archery-bow';paintArt($('.branch .art'),'archery-bow');
 $('#archery-hud').hidden=false;$('#timer').textContent='ATIŞ';$('#start').textContent='Atışa Başla ▶';
 $('#race-status').textContent='Sporcular sırayla atış yapar · En yüksek puan kazanır.';
 updateArcheryHUD();
}
function updateArcheryHUD(){if(state.branch!=='archery')return;const a=race?.branch==='archery'?race.archery:null;$('#round').textContent=(a?a.turn+1:archeryCompleted.length?6:1)+' / 6';$('#timer').textContent=a?'OK '+Math.min(3,a.arrow+1)+'/3':'ATIŞ';const score=$('#archery-score');score.textContent=a&&a.scores[a.turn].length?a.scores[a.turn].reduce((n,v)=>n+v,0)+' / 30':archeryCompleted.length?archeryCompleted.at(-1).points+' / 30':'';}
function beginArchery(){
 if(race||paused)return{ok:false,reason:'Yarış zaten sürüyor'};resultDelay=0;archeryCompleted=[];
 const ids=lineup(),levels=[...state.archeryLevels],campus=[0,1,2].map(i=>campusRank('archery',i)),trainingCard=consumeTrainingCard('archery');race={branch:'archery',phase:'shooting',ids,playerLane:0,elapsed:0,archery:{turn:0,arrow:0,phase:'walk',time:0,duration:.8,levels,campus,results:[],scores:ids.map(()=>[]),shots:ids.map(id=>Array.from({length:3},(_,arrow)=>{const shot=archeryShot(id,id===state.selected?levels:[1,1,1,1],Math.random(),id===state.selected?campus:[0,0,0],arrow);if(id===state.selected&&trainingCard)shot.points=Math.min(10,shot.points+1);return shot;}))}};
 runners();$('.stadium').classList.remove('idle');$('#race-call').hidden=true;$('#live-tag').hidden=false;$('#race-status').textContent=animals[ids[0]].name+' atış çizgisine geliyor.';update();return{ok:true};
}
function advanceArchery(dt){
 const a=race.archery;race.elapsed+=dt;a.time+=dt;
 if(a.time>=a.duration){a.time=0;const id=race.ids[a.turn],name=animals[id].name;
  if(a.phase==='walk'){a.phase='aim';a.duration=1.5;$('#race-status').textContent=name+' · '+(a.arrow+1)+'. ok · nişan alıyor.';if(id===state.selected)offerMove('archery',a.duration,'Nişanı bırak!');}
  else if(a.phase==='aim'){const shot=a.shots[a.turn][a.arrow];if(id===state.selected){shot.points=Math.min(10,shot.points+Math.round(moveQuality()*2));clearMove();}a.phase='flight';a.duration=.85;beep(620,.05);}
  else if(a.phase==='flight'){a.phase='hit';a.duration=.55;const shot=a.shots[a.turn][a.arrow];a.scores[a.turn].push(shot.points);$('#race-status').textContent=name+' · '+shot.points+' puan · toplam '+a.scores[a.turn].reduce((n,v)=>n+v,0);beep(870,.1);}
  else if(a.phase==='hit'){a.arrow++;if(a.arrow<3){a.phase='aim';a.duration=1.5;if(id===state.selected)offerMove('archery',a.duration,'Nişanı bırak!');}else{a.results.push({id,points:a.scores[a.turn].reduce((n,v)=>n+v,0)});archeryCompleted=[...a.results];a.phase='return';a.duration=.7;}}
  else if(a.phase==='return'){a.turn++;if(a.turn===race.ids.length){finishArchery();return;}a.phase='walk';a.duration=.8;$('#race-status').textContent=animals[race.ids[a.turn]].name+' sıradaki sporcu.';}
  if(a.phase==='walk')a.arrow=0;
 }
 positionArcheryAvatars();updateArcheryHUD();
}
function finishArchery(){
 const results=race.archery.results,player=results.find(r=>r.id===state.selected),place=1+results.filter(r=>r.points>player.points).length;
 state.races++;state.xp+=place===1?30:15;if(place===1)state.wins++;if(place<=3)state.medals++;if(state.races%5===0){state.chests++;state.skillPoints++;}state.bestArchery=Math.max(state.bestArchery,player.points);recordTournament('archery',place);
 const reward=Math.round((place===1?1250:place===2?850:place===3?650:400)*(1+campusRank('stadium',2)*.03));state.money+=reward;
 race=null;positionArcheryAvatars();$('#archery-arrow').hidden=true;$('.stadium').classList.add('idle');$('#live-tag').hidden=true;
 const summary=place+'. sıra · '+player.points+' puan';$('#race-status').textContent=summary+' · +₺'+fmt(reward);$('#race-call').hidden=false;$('#race-call>span').textContent=summary;$('#start').textContent='Tekrar Atış ▶';resultDelay=state.auto?6:0;toast(summary+' · +₺'+fmt(reward));save();update();
}
