
import SimpleOpenNI.*;

SimpleOpenNI kinect;


void setup(){
  
  kinect=new SimpleOpenNI(this);
  kinect.enableDepth(); 
  kinect.enableRGB();
  kinect.setMirror(true);
  size(kinect.depthWidth()+kinect.rgbWidth(),kinect.depthHeight());
}

void draw(){
 
  kinect.update();
  image(kinect.depthImage(),0,0);
  image(kinect.rgbImage(),kinect.depthWidth(),0);
}

  

