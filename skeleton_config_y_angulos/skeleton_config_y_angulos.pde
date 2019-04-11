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
    updateAngles();
    println(angles);
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




// calculo de angulos

//Vectores brazo izquierdo
PVector lHand=new PVector();
PVector lElbow=new PVector();
PVector lShoulder=new PVector();
//Vectores pierna izquierda
PVector lFoot=new PVector();
PVector lKnee=new PVector();
PVector lHip=new PVector();
//Vectores brazo derecho
PVector rHand=new PVector();
PVector rElbow=new PVector();
PVector rShoulder=new PVector();
//Vectores pierna derecha
PVector rFoot=new PVector();
PVector rKnee=new PVector();
PVector rHip=new PVector();

//ahora se necesita tener en cuenta 9 vectores:
// 0 = rotacion del cuerpo
// 1 = codo izq
// 2 = hombro izq
// 3 = rodilla izq
// 4 = cadera izq
// 5 = codo dcho
// 6 = hombro dcho
// 7 = rodilla dcha
// 8 = cadera dcha
float[] angles = new float[9];

//calcula el angulo
float angle (PVector a, PVector b, PVector c){
  float angle01 = atan2(a.y-b.y, a.x-b.x);
  float angle02 = atan2(b.y-c.y, b.x-c.x);
  float ang = angle02-angle01;
  return ang;
}

void updateAngles(){
  //brazo izq
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_LEFT_HAND, lHand);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_LEFT_ELBOW, lElbow);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_LEFT_SHOULDER, lShoulder);
  //pierna izq
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_LEFT_FOOT, lFoot);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_LEFT_KNEE, lKnee);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_LEFT_HIP, lHip);
  //brazo dcho
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_RIGHT_HAND, rHand);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_RIGHT_ELBOW, rElbow);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rShoulder);
  //pierna dcha
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_RIGHT_FOOT, rFoot);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_RIGHT_KNEE, rKnee);
  kinect.getJointPositionSkeleton(1, SimpleOpenNI.SKEL_RIGHT_HIP, rHip);
  
  // se proyecta a 2d (el muñeco es plano)
  angles[0] = atan2(PVector.sub(rShoulder, lShoulder).z, PVector.sub(rShoulder, lShoulder).x);
  kinect.convertRealWorldToProjective(rFoot, rFoot);
  kinect.convertRealWorldToProjective(rKnee, rKnee);
  kinect.convertRealWorldToProjective(rHip, rHip);
  kinect.convertRealWorldToProjective(lFoot, lFoot);
  kinect.convertRealWorldToProjective(lKnee, lKnee);
  kinect.convertRealWorldToProjective(lHip, lHip);
  kinect.convertRealWorldToProjective(lHand, lHand);
  kinect.convertRealWorldToProjective(lElbow, lElbow);
  kinect.convertRealWorldToProjective(lShoulder, lShoulder);
  kinect.convertRealWorldToProjective(rHand, rHand);
  kinect.convertRealWorldToProjective(rElbow, rElbow);
  kinect.convertRealWorldToProjective(rShoulder, rShoulder);
  
  //implementacion de angulos
  // angulos lado izq
  angles[1] = angle(lShoulder, lElbow, lHand);
  angles[2] = angle(rShoulder, lShoulder, lElbow);
  angles[3] = angle(lHip, lKnee, lFoot);
  angles[4] = angle(new PVector(lHip.x, 0), lHip, lKnee);
  //angulos lado dcho
  angles[5] = angle(rHand, rElbow, rShoulder);
  angles[6] = angle(rElbow, rShoulder, lShoulder);
  angles[7] = angle(rFoot, rKnee, rHip);
  angles[8] = angle(rKnee, rHip, new PVector(rHip.x, 0));
}
  
  
  
    
  



