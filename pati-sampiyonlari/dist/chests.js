'use strict';
const chestNames={normal:'Spor Çantası',cup:'Kupa Çantası',champion:'Şampiyon Çantası'};
const cosmeticNames=['Altın Çerçeve','Mavi Şimşek Çerçeve','Yıldız Çerçeve','Pati Çerçeve'];
function chestReward(type){
 const pool=[{kind:'money',amount:type==='normal'?3500:6500,label:'₺'+(type==='normal'?'3.500':'6.500'),icon:'💵'},
 {kind:'parts',amount:type==='normal'?2:4,label:(type==='normal'?2:4)+' ekipman parçası',icon:'⚙️'},
 {kind:'card',amount:1,branch:state.branch,label:branchLabel(state.branch)+' antrenman kartı',icon:'🎫'},
 {kind:'boost',amount:1,label:'2x gelir kuponu',icon:'⚡'},
 {kind:'gems',amount:type==='normal'?2:4,label:(type==='normal'?2:4)+' elmas',icon:'💎'}];
 if(type!=='normal')pool.push({kind:'cosmetic',index:Math.floor(Math.random()*cosmeticNames.length),icon:'✨'});
 const reward=pool[Math.floor(Math.random()*pool.length)];
 if(reward.kind==='cosmetic')reward.label=cosmeticNames[reward.index];
 return reward;
}
function branchLabel(id){return {sprint:'100 metre',hurdles:'Engelli koşu',swim:'Yüzme',longjump:'Uzun atlama',weights:'Halter',archery:'Okçuluk'}[id]||'Yarış';}
function openChest(type='normal'){
 if(state.pendingChest)return true;
 const key={normal:'chests',cup:'cupChests',champion:'championChests'}[type];if(!key||state[key]<1)return false;
 state[key]--;
 const offers=[chestReward(type),chestReward(type),chestReward(type)];
 if(type==='cup')for(let i=0;i<3;i++){const extra=chestReward('normal');offers[i]={kind:'bundle',amount:2,extra,label:'2 ekipman parçası + '+extra.label,icon:'🏆'};}
 if(type==='champion'){const missing=cosmeticNames.map((_,i)=>i).filter(i=>!state.cosmetics.includes(i));for(let i=0;i<3;i++){const index=missing[i%missing.length];offers[i]=missing.length?{kind:'cosmetic',index,label:cosmeticNames[index],icon:'✨'}:{kind:'parts',amount:6,label:'6 ekipman parçası',icon:'⚙️'};}}
 state.pendingChest={type,offers};save();return true;
}
function grantChestReward(item){if(item.kind==='bundle'){state.equipmentParts+=item.amount;grantChestReward(item.extra);return;}
 if(item.kind==='money')state.money+=item.amount;
 if(item.kind==='gems')state.gems+=item.amount;
 if(item.kind==='parts')state.equipmentParts+=item.amount;
 if(item.kind==='boost')state.boostTokens+=item.amount;
 if(item.kind==='card')state.trainingCards[item.branch]=(state.trainingCards[item.branch]||0)+item.amount;
 if(item.kind==='cosmetic'){if(state.cosmetics.includes(item.index)){state.equipmentParts+=4;item.label='Tekrar: +4 ekipman parçası';}else{state.cosmetics.push(item.index);state.selectedCosmetic=item.index;}}
}
function chooseChest(index){const pending=state.pendingChest;if(!pending||!Number.isInteger(index)||index<0||index>2)return false;
 const item=pending.offers[index];grantChestReward(item);
 state.pendingChest=null;save();update();toast(item.icon+' '+item.label+' kazandın!');return item;
}
function chestHTML(){const p=state.pendingChest;return `<p>${p?chestNames[p.type]+' · Bir çanta seç.':'Çantaların envanterde. Her 5 yarışta yeni bir Spor Çantası kazanırsın.'}</p>${p?`<div class="chest-choices">${p.offers.map((_,i)=>`<button data-chest-choice="${i}" aria-label="${i+1}. çantayı aç"><span>🎁</span><b>${i+1}. Çanta</b></button>`).join('')}</div><p class="muted">Seçimin kaydedilir; menüden çıksan da çanta burada kalır.</p>`:`<div class="row"><span>Spor Çantası ×${state.chests}</span><button data-chest-open="normal" ${state.chests<1?'disabled':''}>Aç</button></div><div class="row"><span>Kupa Çantası ×${state.cupChests}</span><button data-chest-open="cup" ${state.cupChests<1?'disabled':''}>Aç</button></div><div class="row"><span>Şampiyon Çantası ×${state.championChests}</span><button data-chest-open="champion" ${state.championChests<1?'disabled':''}>Aç</button></div>`}`;}
function consumeTrainingCard(branch){if(!state.trainingCards[branch])return false;state.trainingCards[branch]--;save();toast('🎫 '+branchLabel(branch)+' antrenman kartı kullanıldı!');return true;}
