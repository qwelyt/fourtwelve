include <settings.scad>
include <lib.scad>

showSwitch=true;
showKeyCap=true;
separation=2;


module bottom(h,t,r=3){
  s=0.1;
  difference(){
    rube([size(keyCols+1), size(keyRows+1), h],r=r,center=true);
    translate([0,0,t])cube([size(keyCols), size(keyRows), h],center=true);
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
    color([0.3,0.9,0.4])plate(h,extra);
    translate([0,0,3])
       rep()mxSwitchCut();
  }
  
  if(showSwitch){
    color([0.3,0.2,0.1])
    translate([0,0,2.4]){
      rep()cherrySwitch();
    }
  }
  if(showKeyCap){
    color([0.9,0.9,0.4])
    translate([0,0,1.3]){
      rep()cherryCap();
    }
  }
}
module top(height,lip,r=3){
  s=0.1;
  h=height*2;
  #translate([size(keyCols+1)/2, size(keyRows+1)/2,h/4])cube([1,1,height],center=true);
  difference(){
    rube([size(keyCols+lip), size(keyRows+lip), h],r=r,center=true);
    cube([size(keyCols), size(keyRows), h+r],center=true);
    translate([0,0,-(h/2)])cube([size(keyCols+lip)+1, size(keyRows+lip)+1, h],center=true);
    
    translate([0,0,-h/2+moduleZ])plate(h=moduleZ+1,extra=s);
  }
}


module full(bottom,bottomThickness,plate,top,roundness,separation=0){
  bh=plate-bottom/2-separation;
  color([0.9,0.2,0.3])translate([0,0,bh])bottom(bottom,bottomThickness,roundness);
  
  translate([0,0,0])plateWithCuts(plate);
  
  th=(-plate)+top/2+separation;
  color([0.2,0.5,0.7])translate([0,0,th])top(top,roundness);
}

module half(h){
  full(20);
}

//difference(){
//  full(15,5,3,14,15,separation);
//  translate([0,-100,-50])cube([300,330,100]);
//}

top(14,3);