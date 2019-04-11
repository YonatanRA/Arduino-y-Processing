import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI kinect;
float rotation=0;

int boxSize=150;
PVector boxCenter=new PVector(0,0,600);

float s=1; //para zoom

void setup(){
  size(1024, 768, OPENGL);
  kinect=new SimpleOpenNI(this);
  kinect.enableDepth(); 
}

void draw(){
  background(0);
  kinect.update();
  
  translate(width/2, height/2, -1000);
  rotateX(radians(180));
  translate(0, 0, 1400);
  rotateY(radians(map(mouseX,0,width,-180,180)));
  
  translate(0,0,s*-1000);
  scale(s); //zoom
  
  println(s);
  
  stroke(255);
  
  PVector[] depthPoints=kinect.depthMapRealWorld();
  
  int depthPointsInBox=0;
  
  for (int i=0; i<depthPoints.length; i+=10){
    PVector currentPoint=depthPoints[i];
    if (currentPoint.x>boxCenter.x-boxSize/2 && currentPoint.x<boxCenter.x+boxSize/2){
     if (currentPoint.y>boxCenter.y-boxSize/2 && currentPoint.y<boxCenter.y+boxSize/2){
      if (currentPoint.z>boxCenter.z-boxSize/2 && currentPoint.z<boxCenter.z+boxSize/2){
       depthPointsInBox++;
      }
     }
    }
   point(currentPoint.x,currentPoint.y,currentPoint.z); 
  }
  println(depthPointsInBox);
  
  //ahora el color de la caja...0 transparente 1000 opaco
  float boxAlpha=map(depthPointsInBox,0,1000,0,255);
  translate(boxCenter.x, boxCenter.y, boxCenter.z);
  fill(255,0,0,boxAlpha);
  stroke(255,0,0);
  box(boxSize);
}


//flechas para zoom
void keyPressed(){
  if(keyCode==38){
    s=s+0.01;
  }
  if(keyCode==40){
    s=s-0.01;
  }
}

void mousePressed(){
  save("touchedPoint.png");
}

  

