"use strict";

function _(el){
 return document.getElementById(el);
}

function block_bsod(e){
  var confirmation = confirm("Na pewno chcesz to zrobić? Będize mu przykro...");
  if(confirmation == false){
    e.preventDefault();
  }
}

window.addEventListener("load", function(evt){
  var bsodBtn = _('bsod-button');
  if (bsodBtn) { bsodBtn.addEventListener('click', block_bsod); }
})
