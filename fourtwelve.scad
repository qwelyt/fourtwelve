showSwitchCut=true;
showSwitch=true;
showKeyCap=false;
showSpaceBox=false;
fullboard=false;
space=19.04;

/*[Cherry MX settings]*/
cherryCutOutSize=13.9954;
cherrySize=14.58;

/*[Keeb]*/
keyCols = 12;
keyRows = 4;
keySpace = space-cherrySize;
edgeSpaceAddition = 3;
edgeSpace = (edgeSpaceAddition*2)-keySpace;
keyZ = -1;

function size(q) = (keySpace*q)
                        +cherrySize
                        *(q-1)
                        +cherrySize;
function Qsize(q) = (edgeSpace+edgeSpaceAddition)
              +(keySpace*q)
              +cherrySize
              *(q-1)
              +cherrySize;
          
moduleX = size(keyCols);
moduleY = size(keyRows);
moduleZ = 3;

$fn=30;


/*[ Printer settings ]*/
showPrintBox=false;
printerSize=[140,140,140];

// mX: h=mX-1, d= X*(1+((1/3)*2))
function mNutH(m) = m-1;
function mNutD(m) = m*(1+((1/3)*2));
          
function position(x,y,z) = [space*(x-1), space*(y-1), z];



///////////////////////////////
//  Lib modules
//////////////////////////////

// ---- Key related "libs" ----
module cherrySwitch(){
	// Awesome Cherry MX model created by gcb
	// Lib: Cherry MX switch - reference
	// Download here: https://www.thingiverse.com/thing:421524
	//  p=cherrySize/2+0.53;
	#translate([cherryCutOutSize/1.5,cherryCutOutSize/1.5,13.32])
		import("switch_mx.stl");
}
module cherryCap(x=cherryCutOutSize/1.36,y=cherryCutOutSize/1.36,z=4, capSize=1, homing=false,rotateCap=false){
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
module mxSwitchCut(x=cherryCutOutSize/1.5,y=cherryCutOutSize/1.5,z=0,rotateCap=false){
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



module repeated (yStart, yEnd, xStart, xEnd, yStep=1, xStep=1){
  union(){
    for(y = [yStart:yStep:yEnd]){
      for(x = [xStart:xStep:xEnd]){
        translate(position(x,y,keyZ)) children();
      }
    }
  }
}

///////////////////////////////
//  This
//////////////////////////////

module roundCorner(h=10,d=10){
  union(){
    rotate([0,0,180])difference(){
      translate([0,0,-0.5])cube([d,d,h+1]);
      translate([0,0,-1])cylinder(d=d,h=h+2);
    }
  }
}

module topPlateNoCuts(){
  union(){
    cube([size((keyCols/2)-1),size(keyRows),moduleZ]);
    cube([size((keyCols/2)+1),size(2),moduleZ]);
    
    translate([-edgeSpace,size(keyRows),0])
      cube([size((keyCols/2)-1)+edgeSpace,edgeSpace, moduleZ]);
    
    translate([-edgeSpace,-edgeSpace,0])
      cube([size((keyCols/2)+1)+edgeSpace,edgeSpace, moduleZ]);
    
    translate([-edgeSpace,-edgeSpace,0])
      cube([edgeSpace,size(keyRows)+edgeSpace*2, moduleZ]);
  }
}

module top(){
  difference(){
    topPlateNoCuts();
     
    if(showSwitchCut){
      translate([0,0,3.5]){
        repeated(1,keyRows,1,keyCols) mxSwitchCut();
      }
    }
    $fn=30;
    
    repeated(2,keyRows,2,7,2,5) cylinder(h=10,d=mNutD(ri),center=true);
    repeated(2,keyRows,4,7,2,5) cylinder(h=10,d=mNutD(ri),center=true);
  }
  
  if(showSwitch){
    translate([0,0,3.5]){
      repeated(1,keyRows/2,1,keyCols/2+1) cherrySwitch();
      repeated(keyRows/2,keyRows,1,keyCols/2-1) cherrySwitch();
    }
  }
  if(showKeyCap){
    translate([0,0,3.5]){
      repeated(1,keyRows/2,1,keyCols/2+1) cherryCap();
      repeated(keyRows/2,keyRows,1,keyCols/2-1) cherryCap();
    }
  }
}

module bottom(z=15){
  difference(){
    union(){
      cube([size((keyCols/2)-1),size(keyRows),z]);
      cube([size((keyCols/2)+1),size(2),z]);
      
      translate([-edgeSpace*2,size(keyRows),0])
        cube([size((keyCols/2)-1)+edgeSpace*2,edgeSpace*2, z]);
      
      translate([-edgeSpace*2,-edgeSpace*2,0])
        cube([size((keyCols/2)+1)+edgeSpace*2,edgeSpace*2, z]);
      
      translate([-edgeSpace*2,-edgeSpace*2,0])
        cube([edgeSpace*2,size(keyRows)+edgeSpace*4, z]);
    }
    
    translate([0,0,moduleZ])union(){
      cube([size((keyCols/2)-1),size(keyRows),z]);
      cube([size((keyCols/2)+1),size(2),z]);
    }
    translate([1,0,moduleZ])union(){
      cube([size((keyCols/2)-1),size(keyRows),z]);
      cube([size((keyCols/2)+1),size(2),z]);
      translate([0,1,0])cube([size((keyCols/2)+1),size(2),z]);
    }
    
    translate([0,0,z-moduleZ])scale([1,1,1.1])topPlateNoCuts();
    translate([1,0,z-moduleZ])scale([1,1,1.1])topPlateNoCuts();
    
    translate([-0.6,-0.6,0])roundCorner(z,d=5);
    translate([-0.6,-0.95+size(keyRows)+edgeSpace,0])rotate([0,0,-90])roundCorner(z,d=5);
  }
}

module half(){
  h=11;
//  translate([0,0,h-moduleZ])top();
  bottom(h);
}

ri=3;
translate([0,0,0]){
  half();
  
//#  translate([size(keyCols),size(keyRows),0])rotate([0,0,180])half();
}



if(showPrintBox)#cube(printerSize);
