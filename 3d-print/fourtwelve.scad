use <lib.scad>
include <settings.scad>

//include <version1.scad>
include <version2.scad>
  

showSwitchCut=true;
showSwitch=true;
showKeyCap=true;
showSpaceBox=false;
fullboard=true;

/*[ Printer settings ]*/
showPrintBox=false;
printerSize=[140,140,140];



translate([0,0,0]){
  difference(){
    half();
    cube(printerSize);
  }
}

if(showPrintBox)#cube(printerSize);
