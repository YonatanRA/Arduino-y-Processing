

import processing.opengl.*;
import SimpleOpenNI.*;
import kinectOrbit.*;


KinectOrbit myOrbit;
SimpleOpenNI kinect;

void setup(){
  size(800,600,OPENGL);
  myOrbit = new KinectOrbit(this, 0);
  kinect = new SimpleOpenNI(this);
 kinect.enableDepth(); 
}

void draw(){
  kinect.update();
  background(0);
  
  myOrbit.pushOrbit(this);
  drawPointCloud();
  kinect.drawCamFrustum();
  
  myOrbit.popOrbit(this);
}

//index = x + y * imageWidth;

void drawPointCloud(){
  int[] depthMap = kinect.depthMap();
  int   steps = 3; //acelera el dibujo
  int   index;
  PVector realWorldPoint;
  stroke(255);
  for (int y=0;y < kinect.depthHeight();y+=steps)
  {
    for (int x=0;x < kinect.depthWidth();x+=steps)
    {
      stroke(kinect.depthImage().get(x,y));
      index = x + y * kinect.depthWidth();
      if (depthMap[index] > 0)
      {
        realWorldPoint = kinect.depthMapRealWorld()[index];
        point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
      }
    }
  }
}


