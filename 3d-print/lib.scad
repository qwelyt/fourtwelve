include <settings.scad>

function size(q) = (keySpace*q)
                        +cherrySize
                        *(q-1)
                        +cherrySize;
function Qsize(q) = (edgeSpace+edgeSpaceAddition)
              +(keySpace*q)
              +cherrySize
              *(q-1)
              +cherrySize;
          




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

module roundedCube(size=[1,1,1],r=0.5){
  tMin = r;
  txMax = size[0] - r;
  tyMax = size[1] - r;
  tzMax = size[2] - r;
  
  hull(){
    translate([tMin,tMin,tMin])sphere(r=r);
    translate([tMin,tMin,tzMax])sphere(r=r);
    
    
    
    translate([txMax,tMin,tMin])sphere(r=r);
    translate([txMax,tMin,tzMax])sphere(r=r);
    
    
    translate([tMin,tyMax,tMin])sphere(r=r);
    translate([tMin,tyMax,tzMax])sphere(r=r);
    
    translate([txMax,tyMax,tMin])sphere(r=r);
    translate([txMax,tyMax,tzMax])sphere(r=r);

  }
}

module rube(size=[1,1,1],center=false,r=0.2,type="s"){
  module s(){sphere(r=r);}
  module c(){cylinder(r=r,h=r*2,center=true);}
  module m(){
    if(type == "c"){
      c();
    } else {
      s();
    }
  }
  
  tx=size[0] - r;
  ty=size[1] - r;
  tz=size[2] - r;


  cntr = center ? [-(tx/2+r/2),-(ty/2+r/2), -(tz/2+r/2)] : [0,0,0];
  
  translate(cntr)hull(){
    //bottom
    translate([r,r,r])m();
    translate([tx,r,r])m();
    translate([r,ty,r])m();
    translate([tx,ty,r])m();
    
    //top
    translate([r,r,tz])m();
    translate([tx,r,tz])m();
    translate([r,ty,tz])m();
    translate([tx,ty,tz])m();
  }
}