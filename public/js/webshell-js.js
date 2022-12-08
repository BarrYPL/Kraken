"use strict";
const xhr = new XMLHttpRequest();

function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

function _(el){
 return document.getElementById(el);
}

function add_line(text)
{
  const newLine = document.createElement("p");
  const recDiv = _('wrapper');
  newLine.innerHTML = text;
  recDiv.appendChild(newLine);
  recDiv.scrollTo({top: recDiv.scrollHeight, behavior: 'smooth'});
}

function update_shell(){
  let post_data = input_source.value;
  add_line(">"+post_data);
  input_source.value = "";

xhr.onreadystatechange = function() {
  if (xhr.readyState == XMLHttpRequest.DONE) {
    const answer = xhr.responseText
    add_line(">"+answer);
  }
}

xhr.addEventListener('error', (event) => {
  alert('Oops! Something went wrong.');
});
  if(!isEmpty(post_data)){
    xhr.open("POST", "/webshell", true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send("command="+post_data);
  }
}

window.addEventListener("load", function(evt){
  document.querySelector('#input_source').addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
      update_shell();
    }
  });
})
