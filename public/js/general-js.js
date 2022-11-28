"use strict";

function _(el){
 return document.getElementById(el);
}

function showMenu(){
  const menuButton = $('#menu-icon');
  _('menu-div').style.transform = 'translateX(-105vw)';
}

function hideMenu(){
  const menuButton = $('#menu-icon');
  _('menu-div').style.transform = 'translateX(0px)';
}
