import SimpleOpenNI.*;
import processing.serial.*;
// no reconoce la mano
SimpleOpenNI kinect;
Serial myPort;

PVector handVec = new PVector();
PVector mapHandVec = new PVector();
color handPointCol = color(255,0,0);

void setup(){
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableGesture();
  kinect.enableHands();
  kinect.addGesture("Wave");//gesto para inicializar la captura
  //kinect.addGesture("RaiseHand");
  size(kinect.depthWidth(),kinect.depthHeight());
  String portName = Serial.list()[32]; // puerto serial...buscar en lista si no es este
  myPort = new Serial(this, portName, 9600);
}

//trackeo de gestos
void onRecognizeGestures(String strGesture, PVector idPosition, PVector endPosition){
  kinect.removeGesture(strGesture);
  kinect.startTrackingHands(endPosition);
}
// creacion de la mano
void onCreateHands(int handId, PVector pos, float time){
  handVec = pos;
  handPointCol = color(0,255,0);
}
//actualizacion de la posicion de la mano
void onUpdateHands(int handId, PVector pos, float time){
  handVec = pos;
}


// dibujo
void draw(){
  kinect.update();
  kinect.convertRealWorldToProjective(handVec,mapHandVec); //posicion de la mano escala real 3d convertida a coordenadas 2d
  image(kinect.depthImage(), 0, 0); //saca por pantalla la imagen de la camara de profundidad
  strokeWeight(10);
  stroke(handPointCol);
  point(mapHandVec.x, mapHandVec.y);
  // se envia la info por el puerto serial
  myPort.write('S');
  myPort.write(int(255*mapHandVec.x/width)); // posicion x 0-255
  myPort.write(int(255*mapHandVec.y/height)); // posicion y 0-255
}




