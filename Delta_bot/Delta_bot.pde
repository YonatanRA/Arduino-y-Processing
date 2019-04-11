class DeltaRobot {   //clase deltarobot:contiene los parametros y rutinas principales
  PVector posVec = new PVector(); // Posicion de la cabeza 
  PVector zeroPos;
  int numLegs = 3; // numero de brazos
  
  DeltaLeg[] leg = new DeltaLeg[numLegs]; // crea array de deltalegs
  float[] servoAngles = new float[numLegs]; // guarda los angulos de cada brazo
  float thigh, shin, baseSiza, effectorSize; // Delta-Robot dimensions
  float gripRot = 100;
  float gripWidth = 100;
  // Dimensiones maximas del espacio del robot
  float robotSpanX = 500;
  float robotSpanZ = 500;
  float maxH;
  
  DeltaRobot(float thigh, float shin, float baseSize, float effectorSize) {
    // Define variables
    this.thigh = thigh;
    this.shin = shin;
    this.baseSize = baseSize;
    this.effectorSize = effectorSize;
    this.maxH = -(thigh + shin) * 0.9f; // Evita que la cabeza(effector) se salga de rango
    zeroPos = new PVector(0, maxH/2, 0);
    // bucle para inicializar los brazos segun su angulo
    for (int i = 0; i < numLegs; i++) {
      float legAngle = (i * 2 * PI / numLegs) + PI / 6;
      leg[i] = new DeltaLeg(i, legAngle, thigh, shin, baseSize, effectorSize);
    }
  }
  // se usa lo siguiente para usar un pvector como parametro y dar un posicion especifica (tmb al inicio)
  public void moveTo(PVector newPos) {
    posVec.set(PVector.add(newPos, zeroPos));
    //se verifica que este dentro del rango
    float xMax = robotSpanX * 0.5f;
    float xMin = -robotSpanX * 0.5f;
    float zMax = robotSpanZ * 0.5f;
    float zMin = -robotSpanZ * 0.5f;
    float yMax = -200;
    float yMin = 2*maxH+200;
    
    if (posVec.x > xMax) posVec.x = xMax;
    if (posVec.x < xMin) posVec.x = xMin;
    if (posVec.y > yMax) posVec.y = yMax;
    if (posVec.y < yMin) posVec.y = yMin;
    if (posVec.x > zMax) posVec.z = zMax;
    if (posVec.x < zMin) posVec.z = zMin;
    
    for (int i = 0; i < numLegs; i++) {
      leg[i].moveTo(posVec); // mueve los brazos a la nueva posicion
      servoAngles[i] = leg[i].servoAngle; // guarda los angulos en el array
    }
  }
  
  void drawEffector() {
    // dibuja la estructura de la cabeza (effector)
    stroke(150);
    fill(150, 50);
    beginShape();
    for (int i = 0; i < numLegs; i++) {
      vertex(leg[i].ankleVec.x, leg[i].ankleVec.y, leg[i].ankleVec.z);
    }
    endShape(CLOSE);
    //dibuja la grapa
    stroke(200, 200, 255);
    fill(200, 50);
    // traslada el sistema de coordenadas a la posicion de la cabeza (effector)
    pushMatrix();
    translate(posVec.x, posVec.y - 5, posVec.z);
    rotateX(-PI/2); // se rota pi/2 el sistema de referencia
    ellipse(0, 0, effectorSize / 1.2f, effectorSize / 1.2f);
    rotate(map(gripRot, 35, 180, -PI/2, PI/2));
    
    for (int i = -1; j < 2; j += 2) {
      translate(0, 2 * j, 0);
      beginShape();
      vertex(-30, 0, 0);
      vertex(30, 0, 0);
      vertex(30, 0, -35);
      vertex(15, 0, -50);
      vertex(-15, 0, -50);
      vertex(-30, 0, -35);
      endShape(CLOSE);
      
      for (int i = -1; i < 2; i += 2) {
        pushMatrix();
        translate(i * 20, 0, -30);
        rotateX(PI / 2);
        ellipse(0, 0, 10, 10);
        rotate(i * map(gripWidth, 50, 150, 0, PI / 2.2f));
        rect(-5, -60, 10, 60);
        translate(0, -50, 0);
        rotate(-i * map(gripWidth, 50, 150, 0, PI / 2.2f));
        rect(-5, -60, 10, 60);
        popMatrix();
      }
    }
    popMatrix();
  }
  public void updateGrip(float gripRot, float gripWidth) {
    this.gripRot = gripRot;
    this.gripWidth = gripWidth;
  }
}
      


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


      
class DeltaLeg {  // clase deltaleg: inverse kinematics
 int id; // id del brazo
 PVector posVec = new PVector(); // posicion de la cabeza (effector)
 float servoAngle; // angulo entre el servo y el plano XZ
 float legAngle; // angulo de rotacion del brazo respecto del eje Y
 
 //posicion universal de las articulaciones
 PVector hipVec, kneeVec, ankleVec;
 
 float thigh, shin, baseSize, effectorSize; //tamaño de los elementos del robot
 DeltaLeg(int id, float legAngle, float thigh, float shin, float base, float effector) {
   this.id = id;
   this.legAngle = legAngle;
   this.baseSize = base;
   this.effectorSize = effector;
   this.thigh = thigh;
   this.shin = shin;
 }

// la siguiente funcion moveTo es la clave, convierte la entrada del vector de posicion en rotacion del servo
void moveTo(PVector thisPos) {
  posVec.set(thisPos);
  PVector posTemp = vecRotY(thisPos, -legAngle);
  
  // encuentra la proyeccion sobre z=0
  float a2 = shin * shin - posTemp.z * posTemp.z;
  //calcula c con respecto al base offset
  float c = dist(posTemp.x + effectorSize, posTemp.y, baseSize, 0);
  float alpha = (float) Math.cos((-a2 + thigh * thigh + c * c) / (2 * thigh * c));
  float beta = -(float) Math.atan2(posTemp.y, posTemp.x);
  servoAngle = alpha - beta;
  getWorldCoordinates();
}

void getWorldCoordinates() { // esta funcion actualiza los PVectores definiendo las articulaciones de los brazos en coordenadas reales
  //vectores de articulaciones sin rotar
  hipVec = vecRotY(new PVector(baseSize, 0, 0), legAngle);
  kneeVec = vecRotZ(new PVector(thigh, 0, 0), servoAngle);
  kneeVec = vecRotY(kneeVec, legAngle);
  ankleVec = new PVector(posVec.x + (effectorSize * (float) Math.cos(legAngle)), posVec.y, posVec.z - 5 + (effectorSize * (float) Math.sin(legAngle)));
}

PVector vecRotY(PVector vecIn, float phi) {
  // rotacion alrededor del eje y
  PVector rotatedVec = new PVector();
  rotatedVec.x = vecIn.x * cos(phi) - vecIn.z * sin(phi);
  rotatedVec.z = vecIn.x * sin(phi) + vecIn.z * cos(phi);
  rotatedVec.y = vecIn.y;
  return rotatedVec;
}

PVector vecRotZ(PVector vecIn, float phi) {
  // rotacion alrededor del eje z
  PVector rotatedVec = new PVector();
  rotatedVec.x = vecIn.x * cos(phi) - vecIn.y * sin(phi);
  rotatedVec.y = vecIn.x * sin(phi) + vecIn.y * cos(phi);
  rotatedVec.z = vecIn.z;
  return rotatedVec;
}

public void draw() {
  // dibuja tres lineas para indicar el plano de cada brazo
  pushMatrix();
  translate(0, 0, 0);
  rotateY(-legAngle);
  translate(baseSize, 0, 0);
  if (id == 0) stroke(255, 0, 0);
  if (id == 1) stroke(0, 255, 0);
  if (id == 2) stroke(0, 0, 255);
  line(-baseSize / 2, 0, 0, 3 / 2 * baseSize, 0, 0);
  popMatrix();
  // dibuja las muñecas (tobillos-ankle)
  stroke(150);
  strokeWeight(2);
  line(kneeVec.x, kneeVec.y, kneeVec.z, ankleVec.x, ankleVec.y, ankleVec.z);
  stroke(150,140,140);
  fill(50);
  beginShape();
  vertex(hipVec.x, hipVec.y + 5, hipVec.z);
  vertex(hipVec.x, hipVec.y - 5, hipVec.z);
  vertex(kneeVec.x, kneeVec.y - 5, kneeVec.z);
  vertex(kneeVec.x, kneeVec.y + 5, kneeVec.z);
  endShape(PConstants.CLOSE);
  strokeWeight(1);
  // dibuja la cadera (hip)
  stroke(0);
  fill(255);
  // alineamiento del eje z
  PVector dirVec = PVector.sub(kneeVec, hipVec);
  PVector centVec = PVector.add(hipVec, PVector.mult(dirVec, 0.5f));
  PVector new_dir = dirVec.get();
  PVector new_up = new PVector(0.0f, 0.0f, 1.0f);
  new_up.normalize();
  PVector crss = dirVec.cross(new_up);
  float theAngle = PVector.angleBetween(new_dir, new_up);
  crss.normalize();
  
  pushMatrix();
  translate(centVec.x, centVec.y, centVec.z);
  rotate(-theAngle, crss.x, crss.y, crss.z);
  // rotate(servoAngle); // posible bug
  box(dirVec.mag() / 50, dirVec.mag() / 50, dirVec.mag());
  popMatrix();
}
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  

// DeltaBot con raton

import processing.opengl.*;
import kinectOrbit.KinectOrbit;
import SimpleOpenNI.*;
// inicializa objetos Orbit y SimpleNI
KinectOrbit myOrbit;
SimpleOpenNI kinect
// Delta Robot
DeltaRobot dRobot;
PVector motionVec;

public void setup() {
  size(1200, 900, OPENGL);
  smooth();
  //Orbit
  myOrbit = new KinectOrbit(this, 0, "kinect");
  myOrbit.setCSScale(100);
  //inicializa el deltabot en dimension real
  dRobot = new DeltaRobot(250, 430, 90, 80);
}

public void draw() {
  background(0);
  myOrbit.pushOrbit(this); // Comienza orbit
  motionVec = new PVector(width/2-mouseX, 0, height/2-mouseY); //define el vector de movimiento
  dRobot.moveTo(motionVec); // mueve el bot al vector definido
  dRobot.draw();  // dibuja el deltabot en su posicion actual
  myOrbit.popOrbit(this); // para orbit
}

////////////////////////////////////////////////////////////////////////////////////////////////

// DeltaBot con kinect

import processing.opengl.*;
import processing.serial.*;
import SimpleOpenNI.*;
import kinectOrbit.KinectOrbit;

// inicializa objetos Orbit y SimpleOpenNI
KinectOrbit myOrbit;
SimpleOpenNI kinect;
Serial myPort;
boolean serial = true;

//NITE
XnvSessionManager sessionManager;
XnVPointControl pointControl;

// fuente para texto en pantalla
PFont font;

// variables para deteccion de la mano
boolean handsTrackFlag;
PVector handOrigin = new PVector();
PVector handVec = new PVector();
ArrayList<PVector> handVecList = new ArrayList<PVector>();
int handVecListSize = 30;
PVector[] realWorldPoint;

// Deltabot
DeltaRobot dRobot;
PVector motionVec;
float gripRot;
float gripWidth;

private float[] serialMsg = new float[5]; // valores serial enviados a arduino

public void setup() {
  size(800, 600, OPENGL);
  smooth();
  
  //Orbit
  myOrbit = new KinectOrbit(this, 0, "kinect");
  myOrbit.drawCS(true);
  myOrbit.drawGizmo(true);
  myOrbit.setCSScale(100);
  
  //SimpleOpenNI
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableGesture();
  kinect.enableHands();
  
  // setup NITE
  sessionManager = kinect.createSessionManager("Wave", "Wave");
  //punto de control manual
  pointControl = new XnVPointControl();
  pointControl.RegisterPointCreate(this);
  pointControl.RegisterPointDestroy(this);
  pointControl.RegisterPointUpdate(this);
  
  sessionManager.AddListener(pointControl);
  // array para almacenar los puntos escaneados
  realWorldPoint = new PVector[kinect.depthHeight() * kinect.depthWidth()];
  for (int i = 0; i < realWorldPoint.length(); i++) {
    realWorldPoint[i] = new PVector();
  }
  
  //inicializar fuente....escoger una (tools>create font)
  font = loadFont("SanSerif-12.vlw");
  
  //inicializa deltabot en dimensiones reales
  dRobot = new DeltaRobot(250, 430, 90, 80);
  
  // inicializa comunicacion serial
  if (serial) {
    String portName = Serial.list()[0]; // primer puerto serial, antes era el 32
    myPort = new Serial(this, portName, 9600);
  }
}

// seguimiento y actualizacion de la mano
public void onPointCreate(XnVHandPointContext pContext) {
  println("onPointCreate:");
  handsTrackFlag = true;
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
  handVecList.clear();
  handVecList.add(handVec.get());
  handOrigin = handVec.get(); // posicion inicial de la mano.. dnd te la reconoce saludando
}
public void onPointDestroy(int nID) {
  println("PointDestroy:  " + nID);
  handsTrackFlag = false;
}
public void onPointUpdate(XnVHandPointContext pContext) {
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
  handVecList.add(0, handVec.get());
  if (handVecList.size() >= handVecListSize) {  //borra el ultimo punto
    handVecList.remove(handVecList.size() - 1);
  }
}

//actualizacion del dibujo del kinect (posicion de la mano)
public void draw() {
  background(0);
  kinect.update();
  kinect.update(sessionManager); // actualizacion del NiTE
  myOrbit.pushOrbit(this); //comienza orbit
 
  if (handsTrackFlag) {
    updateHand();
    drawHand();
  }
  
  // para tener una idea del punto de origen se dibuja una linea verde entre el origen y la posicion actual
  pushStyle();
  stroke(0, 0, 255);
  strokeWeight(5);
  point(handOrigin.x, handOrigin.y, handOrigin.z);
  popStyle();
  stroke(0, 255, 0);
  line(handOrigin.x, handOrigin.y, handOrigin.z, handVec.x, handVec.y, handVec.z); 
  //se guarda la info en el motionVec para luego mover el bot a la nueva posicion
  motionVec = PVector.sub(handVec, handOrigin); // vector de movimiento relativo
  dRobot.moveTo(motionVec); // mueve el bot al vector de movimiento relativo
  dRobot.draw(); // dibuja el bot
  kinect.drawCamFrustum(); // dibuja el kinect
  myOrbit.popOrbit(this); //detiene orbit
  if (serial) {
    sendSerialData();
  }
  displayText(); //muestra los datos en pantalla
}

// grip, control con el movimiento de la mano(muestreo)
void updateHand() {
  //dibuja el mapeo 3d (point depth map)
  int steps = 3; //se puede aumentar la velocidad de calculo usando menos puntos de muestreo
  int index;
  stroke(255);
  // inicializa todos los PVectores al baricentro de la mano
  PVector handLeft = handVec.get();
  PVector handRight = handVec.get();
  PVector handTop = handVec.get();
  PVector handBottom = handVec.get();
  
  for (int y = 0; y < kinect.depthWidth(); y += steps) {
    for (int x = 0; y < kinect.depthWidth(); x += steps) {
      index = x + y * kinect.depthWidth();
      realWorldPoint[index] = kinect.depthMapRealWorld()[index].get();
      if (realWorldPoint[index].dist(handVec) < 100) {
        // dibuja nube de puntos que definen la mano
        point(realWorldPoint[index].x, realWorldPoint[index].y, realWorldPoint[index].z);
       if (realWorldPoint[index].x > handRight.x) handRight = realWorldPoint[index].get();
       if (realWorldPoint[index].x < handLeft.x) handLeft = realWorldPoint[index].get();
       if (realWorldPoint[index].y > handTop.y) handTop = realWorldPoint[index].get();
       if (realWorldPoint[index].y < handBottom.y) handBottom = realWorldPoint[index].get();
      }
    }
  }
  
  //dibujar cubo de control
  fill(100, 100, 200);
  pushMatrix();
  translate(handVec.x, handVec.y, handVec.z);
  rotateX(radians(handTop.y - handBottom.y));
  box((handRight.x - handLeft.x) / 2, (handRight.x - handLeft.x) / 2, 10);
  popMatrix();
  
  //parametros del robot
  gripWidth = lerp(gripWidth, map(handRight.x - handLeft.x, 65, 200, 0, 255), 0.2f);
  gripRot = lerp(gripRot, map(handTop.y - handBottom.y, 65, 200, 0, 255), 0.2f);
  dRobot.updateGrip(gripRot, gripWidth);
}

//se incluye la siguiente funcion para mantener la posicion anterior de la mano desde anteriores sketches
void drawHand() {
  stroke(255, 0, 0);
  pushStyle();
  strokeWeight(6);
  point(handVec.x, handVec.y, handVec.z);
  popStyle();
  
  noFill();
  Iterator itr = handVecList.iterator(); // vas a tener que importar iterator
  beginShape();
  while (itr.hasNext ()) {
    PVector p = (PVector) itr.next();
    vertex(p.x, p.y, p.z);
  }
  endShape();
}


//mandando los datos al arduino (serial)
// se prepara un protocolo para el envio de dos bytes
void sendSerialData() {
  myPort.write('X');
  for (int i = 0; i < dRobot.numLegs; i++) {
   int serialAngle = (int)map(dRobot.servoAngles[i], radians(-90), radians(90), 0, 2000);
   serialMsg[i] = serialAngle;
   byte MSB = (byte)((serialAngle >> 8) & 0xFF);
   byte LSB = (byte)(serialAngle & 0xFF);
   
   myPort.write(MSB);
   myPort.write(LSB);
  }
  // se tienen 256 valores para la rotacion y la altura de la grapa (grip rotation and grip width), se pueden aumentar en pares de bytes
  myPort.write((int)(gripRot));
  serialMsg[3] = (int)(gripRot);
  myPort.write((int)(gripWidth));
  serialMsg[4] = (int)(gripWidth);
}

// se pasan por pantalla los valores enviados al arduino
void displayText() {
  
  fill(255);
  textFont(font,12);
  text("Position X: " + dRobot.posVec.x + "\nPosition Y: " + dRobot.posVec.y + "\nPosition Z: " + dRobot.posVec.z, 10, 20);
  text("Servo1: " + serialMsg[0] + "\nServo2: " + serialMsg[1] + "\nServo3: " + serialMsg[2] + "\nGripRot: " + serialMsg[3] + "\nGripWidth: " + serialMsg[4], 10, 80);
}


   
    
  
  

    
    
  
  

  






  
 
  
    
    



