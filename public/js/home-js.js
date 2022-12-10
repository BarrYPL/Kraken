"use strict";

function _(el){
 return document.getElementById(el);
}

function start_editing(e){
  let textTarget = document.querySelector('.' + e.target.id);
  let innerText;
  innerText = textTarget.innerHTML;
  if (textTarget){
    const inputText = document.createElement('input');
    inputText.innerHTML = "";
    inputText.value = innerText;
    inputText.setAttribute('class', "created-input");
    inputText.setAttribute('name', "new_name");
    textTarget.parentNode.replaceChild(inputText, textTarget);
    e.target.style.display = "none";
  }
}

window.addEventListener("load", function(evt){
  var pencilIcn = _('p-name');
  if (pencilIcn) { pencilIcn.addEventListener('click', start_editing); }
})
