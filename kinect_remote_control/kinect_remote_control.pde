
// Importa las librerias necesarias.

import SimpleOpenNI.*;            // Importa SimpleOpenNI.      
import processing.opengl.*;       // Importa OpenGL.
import processing.serial.*;       // Importa comunicacion serial.
import java.util.Iterator;        // Importa java iterator.

SimpleOpenNI kinect;              // Se define el objeto kinect para SimpleOpenNI.
Serial myPort;                    // Se define el objeto myPort para comunicacion serial.

// La clase XnV se refiere a los objetos de NITE.
XnVSessionManager sessionManager;   // Objeto NITE para reconocimiento de gestos.
XnVPointControl pointControl;       // Objeto NITE para seguimiento de la mano (puntos).
XnVCircleDetector circleDetector;   // Objeto NITE para reconomiento de circulos dibujados con la mano.

PFont font;                         // Se define una fuente de letra para el programa para la representacion por pantalla.

int mode = 0;                       // Variable para tres diferentes modos de reconocimiento de dibujo. (Canal, volumen y nada....en realidad es cambio de velocidad, circulo y no-circulo)

boolean handsTrackFlag = true;                                // Funcion booleana para seguimiento de la mano. (Si-No).
PVector screenHandVec = new PVector();                        // Vector de la posicion de la mano proyectada en la pantalla.
PVector handVec = new PVector();                              // Vector de la posicion real de la mano.
ArrayList<PVector>  handVecList = new ArrayList<PVector>();   // Array de las posiciones anteriores de la mano.
int handVecListSize = 30;                                     // Tamaño del array.

float rot;                                 // Flotante rotacion actual, para volumen, control rotatorio.
float prevRot;                             // Flotante rotacion previa.
float rad;                                 // Flotante radio del circulo.
float angle;                               // Flotante angulo de rotacion. 
PVector centerVec = new PVector();         // Vector posicion real del centro del circulo, coordenadas absolutas.
PVector screenCenterVec = new PVector();   // Vector posicion en pantalla del centro del circulo, coordenadas relativas.
int changeChannel;                         // Entero que define la direccion del cambio de canal.
int channelTime;                           // Entero que temporiza el seguimiento del canal.


void setup(){                              // Funcion de configuracion de programa.
// Configuracion de objetos.
 kinect = new SimpleOpenNI(this);          // Se enciende SimpleOpenNI a traves de la definicion del objeto kinect.
 kinect.setMirror(true);                   // Se activa la funcion de espejo 
 kinect.enableDepth();                     // Se enciende la camara de profundidad. 
 kinect.enableGesture();                   // Se enciende el reconocimiento de gestos.
 kinect.enableHands();                     // Se enciende el reconocimiento de manos.
 
 // Configuracion de NiTE.
 sessionManager = kinect.createSessionManager("Wave", "RaiseHand");  // Se inicia la sesion con dos gestos, saludando y/o levantando la mano.
 // Configuracion NiTE para el controlador del punto manual.
 pointControl = new XnVPointControl();                               // Se enciende el controlador con la definicion del objeto NITE.
 pointControl.RegisterPointCreate(this);                             // Funcion de control de la creacion del punto.
 pointControl.RegisterPointDestroy(this);                            // Funcion de control de la destruccion del punto.
 pointControl.RegisterPointUpdate(this);                             // Funcion de control de la actualizacion del punto en la mano.
 // Configuracion de NiTE detector de circulos.
 circleDetector = new XnVCircleDetector();                           // Se enciende el detector de circulos con la definicion del objeto.
 circleDetector.RegisterCircle(this);                                // Funcion de control de registro, hay circulo. 
 circleDetector.RegisterNoCircle(this);                              // Funcion de control de registro, no hay circulo.
 // se añaden dos de ellas a la sesion
 sessionManager.AddListener(circleDetector);                         // Se añade el detector de circulos.
 sessionManager.AddListener(pointControl);                           // Se añade el controlador del punto manual.
 size(kinect.depthWidth(), kinect.depthHeight());                    // Tamaño de sketch, lo que da el kinect.
 smooth();                                                           // Se suaviza la imagen.
 font = loadFont("CharterBT-Italic-48.vlw");                         // Se define la fuente de letra, en el IDE de Processing se escoge en Tools < Create Font...
 
 String portName = Serial.list()[32];                                // Se define el puerto serial (como cadena de carateres), con serial.list() se puede ver que puerto hay que usar, 0 seria el primero...
 myPort = new Serial(this, portName, 9600);                          // ... y se usa como objeto. 
}

// LLamada a las funciones de NiTE.
void onPointCreate(XnVHandPointContext pContext){                                                                  // Funcion de creacion del punto.
  println("onPointCreate:");                                                                                       // Imprime por el monitor:"onPointCreate:"
  handsTrackFlag = true;                                                                                           // Seguimiento de la mano verdadero.
  handVec.set(pContext.getPtPosition().getX(),pContext.getPtPosition().getY(),pContext.getPtPosition().getZ());    // Se define el vector de posicion real de la mano.
  handVecList.clear();                                                                                             // Se pone a cero el array de posiciones anteriores.
  handVecList.add(handVec.get());                                                                                  // Y se añaden al array las posiciones del vector de posicion.
}
void onPointDestroy(int nID){                   // Funcion de destruccion del punto.
  println("PointDestroy: " + nID);              // Imprime por el monitor:"PointCreate:".
  handsTrackFlag = false;                       // Seguimiento de la mano falso.
}
void onPointUpdate(XnVHandPointContext pContext){                                                                  // Funcion de actualizacion de la posicion del punto.
  handVec.set(pContext.getPtPosition().getX(),pContext.getPtPosition().getY(),pContext.getPtPosition().getZ());    // Se define de nuevo el vector de posicion de la mano.
  handVecList.add(0, handVec.get());                                                                               // Se añade el nuevo punto a la lista en la primera posicion.

  if (handVecList.size() >= handVecListSize)  {                                                                    // Si la lista sobrepasa el tamaño asignado al array...
    handVecList.remove(handVecList.size()-1);                                                                      // ...se borra el ultimo valor, la ultima posicion, el mas alejado en el tiempo.
  }
}
void onCircle(float fTimes, boolean bConfident, XnVCircle circle){                         // Funcion detector de circulos (hay circulo).
  println("onCircle: " + fTimes + " , bConfident=" + bConfident);                          // Imprime por el monitor.
  rot = fTimes;                                                                            // Numero de rotaciones ==> 90º ==> fTimes=0.25
  angle = (fTimes % 1.0f) * 2 * PI - PI/2;                                                 // Angulo en funcion del numero de rotaciones.
  centerVec.set(circle.getPtCenter().getX(), circle.getPtCenter().getY(), handVec.z);      // Se calcula el centro del circulo, con la coordenada z dada por la posicion de la mano. 
  kinect.convertRealWorldToProjective(centerVec, screenCenterVec);                         // Proyecta el centro del circulo a la pantalla.
  rad = circle.getFRadius();                                                               // Se calcula el radio del circulo.
  mode = 1;                                                                                // Segundo modo de dibujo, hay circulo (modo control de volumen).
}
void onNoCircle(float fTimes, int reason){                            // Funcion detector de circulos (no hay circulo).
  println("onNoCircle: " + fTimes + " , reason= " + reason);          // Imprime por el monitor.
  mode=0;                                                             // Primer modo de dibujo, no hay circulo (nada, modo de espera).
}



void draw(){                                 // Funcion de dibujo.
  background(0);                             // Fondo negro. (0=negro en RGB=(0,0,0)).
  kinect.update();                           // Actualiza el kinect.
  kinect.update(sessionManager);             // Actualiza el reconocimiento de gestos del kinect.
  image(kinect.depthImage(), 0, 0);          // Pon por pantalla la camara de profundidad del kinect.
  
  switch(mode){                              // El modo switch permite dividir los loops en diferentes caminos, en este caso 3.
    case 0:                                  // Primer caso (modo espera):
    checkSpeed();                            // Comprueba la velocidad de la mano (en el eje x).
    if (handsTrackFlag) { drawHand();}       // Si se esta siguiendo la mano, dibuja la mano (el punto y su cola). (Aqui se podria meter una señal a Arduino para un led).
    break;                                   // Para.
    case 1:                                  // Segundo caso (modo control de volumen):
    volumeControl();                         // Dibuja el gizmo (circulo gris de control) y envia a Arduino la señal de volumen.
    break;                                   // Para.
    case 2:                                  // Tercer caso (modo cambio de canal):
    channelChange(changeChannel);            // Envia la señal de cambio de canal a Arduino, dibuja el gizmo (flecha) y evita que cualquier otra señal sea atendida por un numero de frames.
    channelTime++;                           // Temporizador que avanza de uno en uno.
    if (channelTime > 10){                   // Si el tiempo sobrepasa lo establecido...
      channelTime = 0;                       // ...resetea el temporizador...
      mode = 0;                              // ...y ponte en modo de espera.
    }
    break;                                   // Para.
  }
}

void checkSpeed() {                                                         // Funcion para comprobar la velocidad de la mano.
  if (handVecList.size() > 1) {                                             // Si la lista de posiciones tiene dos elementos o mas....
    PVector vel = PVector.sub(handVecList.get(0), handVecList.get(1));      // ...define un vector cuya primera componente sea la ultima posicion y la segunda componente la posicion anterior.
    if (vel.x > 50) {                                                       // Si la velocidad en el eje x es positiva (hacia la derecha) y mayor que cierto valor (50mm entre frames, ajustar segun CPU)...
      mode = 2;                                                             // ...tercer modo de dibujo (modo cambio de canal)...
      changeChannel = 1;                                                    // ...y cambio de canal +1.
    }
    else if (vel.x < -50) {                                                 // Si la velocidad en x es negativa (hacia la izquierda) y menor que cierto valor...
      changeChannel = -1;                                                   // ...cambio de cana -1...
      mode = 2;                                                             // ...y tercer modo de dibujo.
    }
  }
}



void channelChange(int sign) {                   // Funcion para cambio de canal, envia señal solo en el primer loop (channelTime==0) para evitar repetir la señal enviada.
  String channelChange;                          // Cadena de caracteres cambio de canal para representacion por pantalla (junto a la flecha).
  pushStyle();                                   // Funcion que guarda un nuevo estilo.
  if (sign==1){                                  // Si el cambio de canal es +1....
    stroke(255, 0, 0);                           // Dibuja lineas rojas.
    fill(255, 0, 0);                             // Relleno de lineas color rojo.
    if (channelTime == 0)myPort.write('1');      // Si es el primer loop (y es +1), envia al puerto serial para Arduino el valor 1.
    textAlign(LEFT);                             // LLeva el texto a la derecha de la pantalla.
    channelChange = "¡CAnal ArriBa!";            // Texto impreso a la derecha de la pantalla junto con la flecha.
  }
  else{                                          // Si el cambio de canal es -1...
    stroke(0, 255, 0);                           // Dibuja lineas verdes.
    fill(0, 255, 0);                             // Relleno de lineas color verde.
    if (channelTime == 0)myPort.write('2');      // Si es el primer loop (y es -1), envia al puerto serial para Arduino el valor 2.
    textAlign(RIGHT);                            // LLeva el texto a la izquierda de la pantalla.
    channelChange = "CanAL AbaJo";               // Texto impreso a la izquierda de la pantalla junto con la flecha.
  }
  // Ahora dibuja la flecha en la pantalla.
  strokeWeight(10);                              // Linea de 10 pixeles.
  pushMatrix();                                  // Guarda el sistema de coordenadas (fija la matriz).
  translate(width/2,height/2);                   // Se translada a la mitad de la pantalla.
  line(0,0,sign*200,0);                          // La linea de la flecha (line(x1,y1,x2,y2), dos puntos). Cambia de sentido segun cambio de canal.
  triangle(sign*200,20,sign*200,-20,sign*250,0); // El triangulo de la flecha.(triangle(x1,y1,x2,y2,x3,y3)).
  textFont(font,20);                             // Fuente de texto y tamaño.
  text(channelChange,0,40);                      // Texto y coordenadas del texto (o start-stop).
  popMatrix();                                   // Restaura el sistema de coordenadas.
  popStyle();                                    // Restaura el estilo.
}




void volumeControl(){                                                                                              // Funcion para el control de volumen.
  String volumeText = "";                                                                                          // Texto del volumen.
  fill(150);                                                                                                       // Relleno de color
  ellipse(screenCenterVec.x, screenCenterVec.y, 2*rad, 2*rad);                                                     // Dibuja un circulo.
  fill(255);                                                                                                       // Rellno de color
  if (rot>prevRot) {                                                                                               // Si la rotacion actual es mayor que la anterior...
    fill(0, 0, 255);                                                                                               // ..rellena de color azul...
    volumeText = "VolumenArrIba";                                                                                  // ...el texto de volumen arriba...
    myPort.write('3');                                                                                             // ...y envia al puerto serial para Arduino el valor 3.
  } 
  else{                                                                                                            // Si la rotacion actual es menor que la anterior...
    fill(0, 255, 0);                                                                                               // ...rellena de color verde...
    volumeText = "VolumenAbajO";                                                                                   // ... el texto de volumen abajo...
    myPort.write('4');                                                                                             // ...y envia al puerto serial para Arduino el valor 4.
  }
  prevRot = rot;                                                                                                   // Caso de ser iguales, no moverse...
  text(volumeText, screenCenterVec.x, screenCenterVec.y);                                                          // ...sin texto en la pantalla (texto vacio en el centro)...
  line(screenCenterVec.x, screenCenterVec.y, screenCenterVec.x+rad*cos(angle), screenCenterVec.y+rad*sin(angle));  // ...sin dibujo.
}




void drawHand(){                                                    // Funcion para el dibujo del punto en la mano.
  stroke(255, 0, 0);                                                // Color rojo.
  pushStyle();                                                      // Guarda estilo.
  strokeWeight(6);                                                  // Linea de 6 pixeles.
  kinect.convertRealWorldToProjective(handVec, screenHandVec);      // Mapeo 3D (handVec, vector de posiciones reales de la mano) para proyeccion en 2D (pantalla).
  point(screenHandVec.x, screenHandVec.y);                          // Dibuja el punto que sigue a la mano en la pantalla.
  popStyle();                                                       // Restaura el estilo.
  noFill();                                                         // Sin relleno de color.
  Iterator itr = handVecList.iterator();                            // Se itera en la lista de posiciones.
  beginShape();                                                     // Comienza el punto (guarda los vertices para una forma).
  while ( itr.hasNext ()){                                          // Mientras siga la iteracion...
    PVector p = (PVector) itr.next();                               // ... se crean dos vectores..
    PVector sp = new PVector();                                     // ...
    kinect.convertRealWorldToProjective(p, sp);                     // ...para representar por pantalla.
    vertex(sp.x, sp.y);                                             // Especifica una posicion en 2D.
  }
  endShape();                                                       // Finaliza el punto.
}
  
    

