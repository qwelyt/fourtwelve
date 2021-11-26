include <settings.scad>
include <lib.scad>

showSwitch=true;
showKeyCap=true;


module bottom(h){
  r=3;
  s=0.1;
  difference(){
    rube([size(keyCols+1), size(keyRows+1), h],r=r,center=true);
    translate([0,0,moduleZ])cube([size(keyCols), size(keyRows), h],center=true);
    translate([0,0,h-r])cube([size(keyCols+1), size(keyRows+1), h],center=true);
    
    translate([0,0,h/2-moduleZ])plate(h=moduleZ+1,extra=s);
  }
}

module plate(h=moduleZ,extra=0){
  cube([size(keyCols+0.25+extra), size(keyRows+0.25+extra), h],center=true);
}

module plateWithCuts(h=moduleZ,extra=0){
  module rep(){
    repeated(-keyRows/2+1,keyRows/2,-keyCols/2+1,keyCols/2) children();
  }
  difference(){
    plate(h,extra);
    translate([0,0,3])
       rep()mxSwitchCut();
  }
  
  if(showSwitch){
    translate([0,0,3.5]){
      rep()cherrySwitch();
    }
  }
  if(showKeyCap){
    translate([0,0,3.5]){
      rep()cherryCap();
    }
  }
}
module top(h){
  r=3;
  s=0.1;
  difference(){
    rube([size(keyCols+1), size(keyRows+1), h],r=r,center=true);
    cube([size(keyCols), size(keyRows), h],center=true);
    translate([0,0,-h+r])cube([size(keyCols+1), size(keyRows+1), h],center=true);
    
    translate([0,0,-h/2+moduleZ])plate(h=moduleZ+1,extra=s);
  }
}


module full(h){
  bottom(h);
  translate([0,0,h/2-2])plateWithCuts();
  translate([0,0,h-9])top(h/1.4);
}

module half(h){
  full(20);
}

full(20);