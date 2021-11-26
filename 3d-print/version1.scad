module roundCorner(h=10,d=10){
  union(){
    rotate([0,0,180])difference(){
      translate([0,0,-0.5])cube([d,d,h+1]);
      translate([0,0,-1])cylinder(d=d,h=h+2);
    }
  }
}

module roundEdge(d=5){
  difference(){
    translate([0,0,-d])sphere(d);
    sphere(d*1.5);
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
    translate([(size(1)+extra)/2
              , (1.5+extra)/2
              , ((z/2+extra)/2)-extra/2
              ])
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
          roundedCube([size((keyCols/2)-1),size(keyRows),z]);
          translate([0,size(keyRows/2),0])
            cube([size((keyCols/2)+1),size(keyRows/2),z]);
          
          translate([-edgeSpace*2,size(keyRows),0])
            cube([size((keyCols/2)+1)+edgeSpace*2,edgeSpace*2, z]);
          
          translate([-edgeSpace*2,-edgeSpace*2,0])
            cube([size((keyCols/2)-1)+edgeSpace*2,edgeSpace*2, z]);
          
          translate([-edgeSpace*2,-edgeSpace*2,0])
            cube([edgeSpace*2,size(keyRows)+edgeSpace*4, z]);
          
          translate([size(keyCols/2-1)-0.1,-1.5,moduleZ])latch();
        }
        
        translate([0,0,moduleZ])union(){
          cube([size((keyCols/2)-1),size(keyRows),z]);
          translate([0,size(keyRows/2),0])
            cube([size((keyCols/2)+1),size(2),z]);
        }

        
        translate([0,0,z-moduleZ])topPlate();
        translate([3,0,z-moduleZ])topPlate();
        
        rounding();
        
        
        translate([size(keyCols/2)-0.49,size(keyRows),moduleZ])latch(extra=1,extraV=0);
        
        proMicroHolder("cutout");
        
        translate(position(keyCols/2+1.38,3,moduleZ/2))cube([size(0.62),size(keyRows/2),moduleZ/2]);
      }
      translate(position((keyCols/2)-0.001,1,moduleZ/2))cube([size(0.6),size(keyRows/2),moduleZ/2]);
      
      translate([0,0,moduleZ])points(true)mount(z-moduleZ*1.75);
    }
    points(true)cylinder(d=mNutDHole(mSize),h=6,$fn=6);
//    translate([size(0),size(3),-2])cube([40,40,20]);
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


module half(h=15){
  translate([0,size(keyRows),h-moduleZ])mirror([0,1,0])top();
  bottom(h);
}