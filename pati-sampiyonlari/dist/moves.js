'use strict';
let activeMove=null;
function offerMove(kind,duration,label){
 activeMove={kind,duration,elapsed:0,tapped:false,quality:0};
 const box=$('#skill-move');box.hidden=false;$('#skill-button').textContent=label;$('#skill-meter').style.left='0%';
}
function clearMove(){activeMove=null;$('#skill-move').hidden=true;}
function moveQuality(){return activeMove?.quality||0;}
function tapMove(){
 if(!activeMove||activeMove.tapped||paused)return false;
 const t=activeMove.elapsed/activeMove.duration;
 activeMove.quality=Math.max(0,1-Math.abs(t-.5)*2);
 activeMove.tapped=true;$('#skill-button').textContent=activeMove.quality>.7?'MÜKEMMEL!':'HAMLE!';beep(720+activeMove.quality*260,.08);
 return true;
}
function tickMove(dt){
 if(!activeMove)return;
 activeMove.elapsed=Math.min(activeMove.duration,activeMove.elapsed+dt);
 $('#skill-meter').style.left=(activeMove.elapsed/activeMove.duration*100)+'%';
 if(activeMove.elapsed>=activeMove.duration){activeMove.tapped=true;$('#skill-move').hidden=true;}
}
const specialties={sprint:[1.06,1,1,1.03,1,1],hurdles:[1,1.04,1,1.03,1,1],swim:[1,1,1,1,1.05,1.04],longjump:[1,1,1,1.05,1,1.04],weights:[1,1,1.06,1,1,1],archery:[1,1.04,1,1,1,1.06]};
function specialty(branch,id){return specialties[branch]?.[id]||1;}
function specialtyLabel(id){const labels={sprint:'100 metre',hurdles:'Engelli koşu',swim:'Yüzme',longjump:'Uzun atlama',weights:'Halter',archery:'Okçuluk'};return Object.entries(specialties).filter(([,values])=>values[id]>1).map(([branch])=>labels[branch]).join(', ')||'Çok yönlü';}
function recordTournament(branch,place){
 const t=state.tournament;if(!t||t.branch!==branch||t.attempts>=3)return;
 t.attempts++;if(place<=3)t.podiums++;
 if(t.attempts===3){const won=t.podiums>=2;if(won){state.cupChests++;state.skillPoints++;state.tournamentCups++;}toast(won?'🏆 Turnuva tamamlandı · Kupa Çantası, +1 SP':'Turnuva bitti · Yeni kupa deneyebilirsin.');}
}
function startTournament(){if(race||state.tournament&&state.tournament.attempts<3)return false;state.tournament={branch:state.branch,attempts:0,podiums:0};save();return true;}
function tournamentHTML(){const t=state.tournament,branch=t?.branch||state.branch,names={sprint:'100 metre',hurdles:'Engelli koşu',swim:'Yüzme',longjump:'Uzun atlama',weights:'Halter',archery:'Okçuluk'};return `<p>${t?'Branş: '+names[branch]:'Seçili branşta üç yarışlık kupa başlat.'}</p><div class="modal-stat"><div><b>${t?.attempts||0}/3</b><small>Yarış</small></div><div><b>${t?.podiums||0}/2</b><small>Gerekli madalya</small></div><div><b>${state.tournamentCups||0}</b><small>Kupa</small></div></div><p class="muted">Üç yarışta en az iki kez ilk üçe gir: Kupa Çantası ve 1 SP kazan.</p><button class="modal-action full" id="tournament-start" ${race||t&&t.attempts<3?'disabled':''}>${t&&t.attempts>=3?'Yeni turnuva':'Turnuvayı başlat'}</button>`;}
