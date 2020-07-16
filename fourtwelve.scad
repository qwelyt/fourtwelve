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
mSize=3;


/*[ Printer settings ]*/
showPrintBox=false;
printerSize=[140,140,140];

// mX: h=mX-1, d= X*(1+((1/3)*2))
function mNutH(m) = m-1;
function mNutD(m) = m*(1+((1/3)*2));
function mNutDHole(m) = mNutD(m)+2;
function mScrewheadH(m) = m-1;
function mScrewheadD(m) = m+2; // This is most probably not correct, but works for m3

          
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

module proMicro(pins=true){
  #translate([size(2),size(keyRows-1)+2.2,moduleZ-0.6])
  if(pins){
    import("pro-micro_wpins.stl");
  } else {
    import("pro-micro.stl");
  }
}

module proMicroHolder(type="holder"){
  translate([size(2),size(keyRows-1)+2.7,moduleZ])
  if(type == "holder"){
    difference(){
      import("pro-micro-holder_base.stl");
//      translate([0,-2.25,1.5])cube([23,38.5,3],center=true);
    }
  } else if(type == "cutout"){
    union(){
      translate([0,0,0.9])cube([19,33.7,4], center=true);
      translate([-7.3,0,-1.2])cube([4.5,33.7,2], center=true);
      translate([7.3,0,-1.2])cube([4.5,33.7,2], center=true);
      translate([0,17,2])cube([8,3,3], center=true);
      translate([0,-20,-0.5])cube([23,3.3,3],center=true);
    }
  } else if(type == "lid"){
    union(){
      translate([0,-3,2.8])cube([10,32,1],center=true);
      translate([0,-18,2])cube([22,2,2.6],center=true);
    }
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

module screwHoles(ri,h,ri2,wedgeHole=false){
  ri2 = is_undef(ri2) ? ri : ri2;
  repeated(2,keyRows,2,keyCols/2-1,2,2) 
    cylinder(h=h,d1=ri2,d2=ri, center=true);
  
  if(wedgeHole){
    repeated(keyRows,keyRows, keyCols/2+1, keyCols/2+1,2,2)
      cylinder(h=h,d1=ri2,d2=ri,center=true);
  }
}

module points(wedge=false){
  repeated(keyRows/2+1,keyRows,4,keyCols/2-1,2,3) children();
  
  if(wedge){
    repeated(keyRows,keyRows, keyCols/2+1, keyCols/2+1,2,2) children();
  }
}

module topPlateNoCuts(){
  difference(){
    union(){
      cube([size((keyCols/2)-1),size(keyRows),moduleZ]);
      translate(position(1,keyRows/2+1,0))cube([size((keyCols/2)+1),size(keyRows/2),moduleZ]);
      
      translate([0,size(keyRows),0])
        cube([size((keyCols/2)+1),edgeSpace, moduleZ]);
      
      translate([0,-edgeSpace,0])
        cube([size((keyCols/2)-1),edgeSpace, moduleZ]);
      
      
      translate([-edgeSpace,-edgeSpace,0])
        cube([edgeSpace,size(keyRows)+edgeSpace*2, moduleZ]);
      
      translate(position(keyCols/2,1,0))
        translate([0,-edgeSpace,0])
          cube([2,size(2)+edgeSpace,moduleZ/2]);
    }
    
    translate(position(keyCols/2+2,3,0))
      translate([-2,0,0])
        cube([2,size(2)+edgeSpace,moduleZ/2]);
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
    
    points(true){
      cylinder(h=10,d=mSize*1.1,center=true);
      translate([0,0,moduleZ-0.5])cylinder(h=2.2, d1=mSize*1.1, d2=mNutD(mSize)*1.21,center=true);
      translate([0,0,moduleZ+1.1])cylinder(h=1.01,d=mNutD(mSize)*1.21,center=true);
    }
    
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
  module topPlate(){
    scale([1,1,1.1])topPlateNoCuts();
  }
  module latch(extra=0,extraV=0){
    translate([(size(1)+extra)/2,(1.5+extra)/2,(z/2+extra)/2])
      cube([size(1)+extra,1.5+extra,z/3+extra+extraV],center=true);
  }
  
  module rounding(){
    translate([-0.6,-0.6,0])roundCorner(z,d=5);
    
    translate([-0.6,-0.95+size(keyRows)+edgeSpace,0])
      rotate([0,0,-90])
        roundCorner(z,d=5);
    
    // side
    translate([0,size(keyRows+0.5),3.08])
      rotate([90,0,0])
        translate([-0.6,-0.6,0])
          roundCorner(size(keyRows+1),d=5);
    
    translate([0,size(keyRows+0.5),z-3.08])
      rotate([90,90,0])
        translate([-0.6,-0.6,0])
          roundCorner(size(keyRows+1),d=5);
    
    // front
    translate([-size(1),0,3.08])
      rotate([90,0,90])
        translate([-0.6,-0.6,0])
          roundCorner(size(keyCols/2+1),d=5);
    
    translate([-size(1),0,z-3.08])
      rotate([90,90,90])
        translate([-0.6,-0.6,0])
          roundCorner(size(keyCols/2+1),d=5);
    
    // back
    translate([size(keyCols/2+2),size(keyRows),3.08])
      rotate([90,0,270])
        translate([-0.6,-0.6,0])
          roundCorner(size(keyCols/2+3),d=5);
          
    translate([size(keyCols/2+2),size(keyRows),z-3.08])
      rotate([90,90,270])
        translate([-0.6,-0.6,0])
          roundCorner(size(keyCols/2+3),d=5);
  }
  
  difference(){
    union(){
      difference(){
        union(){
          cube([size((keyCols/2)-1),size(keyRows),z]);
          translate([0,size(keyRows/2),0])
            cube([size((keyCols/2)+1),size(keyRows/2),z]);
          
          translate([-edgeSpace*2,size(keyRows),0])
            cube([size((keyCols/2)+1)+edgeSpace*2,edgeSpace*2, z]);
          
          translate([-edgeSpace*2,-edgeSpace*2,0])
            cube([size((keyCols/2)-1)+edgeSpace*2,edgeSpace*2, z]);
          
          translate([-edgeSpace*2,-edgeSpace*2,0])
            cube([edgeSpace*2,size(keyRows)+edgeSpace*4, z]);
          
          translate([size(keyCols/2-1),-1.5,moduleZ])latch(0);
        }
        
        translate([0,0,moduleZ])union(){
          cube([size((keyCols/2)-1),size(keyRows),z]);
          translate([0,size(keyRows/2),0])
            cube([size((keyCols/2)+1),size(2),z]);
        }

        
        translate([0,0,z-moduleZ])topPlate();
        translate([3,0,z-moduleZ])topPlate();
        
        rounding();
        
        
        translate([size(keyCols/2)-0.49,size(keyRows),moduleZ])latch(extra=1,extraV=1);
        
        proMicroHolder("cutout");
        
        translate(position(keyCols/2+1.38,3,moduleZ/2))cube([size(0.62),size(keyRows/2),moduleZ/2]);
      }
      translate(position(keyCols/2,1,moduleZ/2))cube([size(0.6),size(keyRows/2),moduleZ/2]);
      
      translate([0,0,moduleZ])points(true)mount(z-moduleZ*1.75);
    }
    points(true)cylinder(d=mNutDHole(mSize),h=6,$fn=6);
    translate([size(0),size(3),-2])cube([40,40,20]);
  }
}

module mount(h,m=mSize){
  translate([0,0,h/4])
  difference(){
    union(){
      translate([0,0,h/4])cylinder(h=h,d=m*2,center=true);
      cylinder(h=h/2,d1=m*4,d2=m*2,center=true);
    }
    translate([0,0,h/4])cylinder(h=h+2,d=m,center=true);
  }
}


module half(h){
//  translate([0,size(keyRows),h-moduleZ])mirror([0,1,0])top();
  bottom(h);
}


translate([0,0,0]){
  half(15);
  
//  connector(15);
//  translate([40,-10,0])connector(15,1);
//  mount(h=15,m=mSize);
  
//  translate([size(keyCols),size(keyRows),0])rotate([0,0,180])half(15);
}

//echo(3);
//echo(mNutD(6));


if(showPrintBox)#cube(printerSize);
//proMicro(false);
//proMicro();
//#proMicroHolder();
//proMicroHolder("cutout");