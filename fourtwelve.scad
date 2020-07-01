showSwitchCut=true;
showSwitch=true;
showKeyCap=false;
showSpaceBox=false;
space=19.04;

/*[Cherry MX settings]*/
cherryCutOutSize=13.9954;
cherrySize=14.58;

/*[Keeb]*/
keyCols = 12;
keyRows = 4;
keySpace = space-cherrySize;
edgeSpaceAddition = 4;
edgeSpace = (edgeSpaceAddition*2)-keySpace;
keyZ = -1;

moduleX = (edgeSpace+edgeSpaceAddition)
              +(keySpace*keyCols)
              +cherrySize
              *(keyCols-1)
              +cherrySize;
              
moduleY = (edgeSpace+edgeSpaceAddition)
              +(keySpace*keyRows)
              +cherrySize
              *(keyRows-1)
              +cherrySize;
moduleZ = 3;




/*[ Printer settings ]*/
showPrintBox=false;
printerSize=[140,140,140];

// mX: h=mX-1, d= X*(1+((1/3)*2))
function mNutH(m) = m-1;
function mNutD(m) = m*(1+((1/3)*2));

function position(x,y,z) = [
          edgeSpace+keySpace*x+cherrySize*(x-1)-(edgeSpaceAddition/2)
          , edgeSpace-keySpace+(keySpace)*y+cherrySize*(y-1)-(edgeSpaceAddition/2)
          , z];
          
function position2(x,y,z) = [
                              space*(x-1)
                              , space*(y-1)
                              , z
                            ];



///////////////////////////////
//  Lib modules
//////////////////////////////

// ---- Key related "libs" ----
module cherrySwitch(){
	// Awesome Cherry MX model created by gcb
	// Lib: Cherry MX switch - reference
	// Download here: https://www.thingiverse.com/thing:421524
	//  p=cherrySize/2+0.53;
	translate([0,0,13.32])
		import("switch_mx.stl");
}
module cherryCap(x=0,y=0,z=0, capSize=1, homing=false,rotateCap=false){
	// Awesome caps created by rsheldiii
	// Lib: KeyV2: Parametric Mechanical Keycap Library
	// Download here: https://www.thingiverse.com/thing:2783650

  capRotation = rotateCap ? 90 : 0;

	if(capSize == 1){
		translate([x-0.819,y-0.8,z+3.5])rotate([0,0,capRotation]){
      if(homing){
        rotate([0,0,180])import("keycap-dsa-1.0-row3-homing-cherry.stl");
      } else {
        import("keycap-dsa-1.0-row3-cherry.stl");
      }
    }
	} else if(capSize==1.25){

		translate([x-0.819,y-0.8,z+3.5])
    rotate([0,0,capRotation])
			import("keycap-dsa-1.25-row3-cherry.stl");
	}
}

// ---- Keyboard basics ----
module mxSwitchCut(x=0,y=0,z=0,rotateCap=false){
  capRotation = rotateCap ? 90 : 0;
  d=14.05;
  p=14.58/2+0.3;
  translate([x,y,z]){
    translate([0,0,-3.7])
    rotate([0,0,capRotation]){
      difference(){
        cube([d,d,10], center=true);
        translate([d*0.5,0,0])cube([1,4,12],center=true);
        translate([-d*0.5,0,0])cube([1,4,12],center=true);
      }


      translate([0,-(p-0.6),1.8]) rotate([-10,0,0]) cube([cherryCutOutSize/2,1,1.6],center=true);
      translate([0,-(p-0.469),-1.95]) cube([cherryCutOutSize/2,1,6.099],center=true);

      translate([0,(p-0.6),1.8]) rotate([10,0,0]) cube([cherryCutOutSize/2,1,1.6],center=true);
      translate([0,(p-0.469),-1.95]) cube([cherryCutOutSize/2,1,6.099],center=true);
    }
  }
}

//module repeted (yStart, yEnd, xStart, xEnd){
//  for(y = [yStart:yEnd]){
//    for(x = [xStart:xEnd]){
//      translate(position2(x,y,keyZ)) children();
//    }
//  }
//}

module repeted (yStart, yEnd, xStart, xEnd, yStep=1, xStep=1){
  for(y = [yStart:yStep:yEnd]){
    for(x = [xStart:xStep:xEnd]){
      translate(position2(x,y,keyZ)) children();
    }
  }
}

///////////////////////////////
//  This
//////////////////////////////
yS=1;
yE=4;
xS=1;
xE=12;
ri=3;
translate([15,15,0]){
  difference(){
    translate([-space/1.35,-space/1.35,0])
      cube([moduleX,moduleY,moduleZ]);
    
    if(showSwitchCut){
      translate([0,0,3.5])repeted(yS,yE,xS,xE) mxSwitchCut();
    }
    
    $fn=30;
    
    repeted(yS+0.5,yE-0.5,xS+0.5,xE-0.5,2,5)
    cylinder(h=10,d=mNutD(ri),center=true);
  }
  if(showSwitch){
    translate([0,0,3.5])repeted(yS,yE,xS,xE) cherrySwitch();
  }
  if(showKeyCap){
    translate([0,0,3.5])repeted(yS,yE,xS,xE) cherryCap();
  }
}

if(showPrintBox)#cube(printerSize);
