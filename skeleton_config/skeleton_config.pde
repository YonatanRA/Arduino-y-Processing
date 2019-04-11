import SimpleOpenNI.*;

SimpleOpenNI kinect;

public void setup(){
  kinect=new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);  //activar todas las articulaciones
  size(kinect.depthWidth(), kinect.depthHeight());
}

public void draw(){
  kinect.update();
  image(kinect.depthImage(),0,0);
  if (kinect.isTrackingSkeleton(1)){
    drawSkeleton(1);
  }
}

void drawSkeleton(int userId){
  pushStyle();
  stroke(255,0,0);
  strokeWeight(3);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK); // drawLimb es class de SimpleOpenNI
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  popStyle();
}

//SimpleOpenNI

public void onNewUser(int userId){
  println("onNewUser-userId:"+userId);
  if (kinect.isTrackingSkeleton(1)) return;
  println("Start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

public void onLostUser(int userId){
  println("onLostUser-userId:"+userId);
}

public void onStartPose(String pose, int userId){
  println("onStartPose-userId:"+userId+", pose: " + pose);
  println(" Stop pose detectioc");
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

public void onEndPose(String pose, int userId){
  println("onEndPose-userId:"+userId+", pose: " + pose);
}

public void onStartCalibration(int userId){
  println("onStartCalibration-userId:"+userId);
}

public void onEndCalibration(int userId, boolean successfull){
  println("onEndCalibration-userId:"+userId+", successfull: " + successfull);
  if (successfull){
    println("User calibrated!!!");
    kinect.startTrackingSkeleton(userId);
  }
  else{
    println("Failed to calibrated user!!!");
    println("Start pose detection");
    kinect.startPoseDetection("Psi", userId);
  }
}



  
  
    
  



