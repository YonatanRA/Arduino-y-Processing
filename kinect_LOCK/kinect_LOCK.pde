
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

PFont font;                         // Se define una fuente de letra para el programa para la representacion por pantalla.

int mode = 0;                       // Variable para dos diferentes modos de reconocimiento de dibujo. (Canal y nada....en realidad es cambio de velocidad y espera)

boolean handsTrackFlag = true;                                // Funcion booleana para seguimiento de la mano. (Si-No).
PVector screenHandVec = new PVector();                        // Vector de la posicion de la mano proyectada en la pantalla.
PVector handVec = new PVector();                              // Vector de la posicion real de la mano.
ArrayList<PVector>  handVecList = new ArrayList<PVector>();   // Array de las posiciones anteriores de la mano.
int handVecListSize = 30;                                     // Tamaño del array.

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
 sessionManager = kinect.createSessionManager("Wave","RaiseHand");   // Se inicia la sesion con dos gestos, saludando y/o levantando la mano.
 // Configuracion NiTE para el controlador del punto manual.
 pointControl = new XnVPointControl();                               // Se enciende el controlador con la definicion del objeto NITE.
 pointControl.RegisterPointCreate(this);                             // Funcion de control de la creacion del punto.
 pointControl.RegisterPointDestroy(this);                            // Funcion de control de la destruccion del punto.
 pointControl.RegisterPointUpdate(this);                             // Funcion de control de la actualizacion del punto en la mano.
 
 sessionManager.AddListener(pointControl);                           // Se añade a la sesion el controlador del punto manual.
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
void onPointDestroy(int nID){                   // Funcion de destruccion del punto.              (Aqui se podria meter una señal a Arduino para un led).
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


void draw(){                                 // Funcion de dibujo.
  background(0);                             // Fondo negro. (0=negro en RGB=(0,0,0)).
  kinect.update();                           // Actualiza el kinect.
  kinect.update(sessionManager);             // Actualiza el reconocimiento de gestos del kinect.
  image(kinect.depthImage(),0,0);            // Pon por pantalla la camara de profundidad del kinect.
  
  switch(mode){                              // El modo switch permite dividir los loops en diferentes caminos, en este caso 2.
    case 0:                                  // Primer caso (modo espera):
    checkSpeed();                            // Comprueba la velocidad de la mano (en el eje x).
    if (handsTrackFlag) { drawHand();}       // Si se esta siguiendo la mano, dibuja la mano (el punto y su cola). 
    break;                                   // Para.
    case 1:                                  // Segundo caso (modo cambio de canal):
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
      mode = 1;                                                             // ...segundo modo de dibujo (modo cambio de canal)...
      changeChannel = 1;                                                    // ...y cambio de canal +1.
    }
    else if (vel.x < -50) {                                                 // Si la velocidad en x es negativa (hacia la izquierda) y menor que cierto valor...
      mode = 1;                                                             // ...y segundo modo de dibujo.
      changeChannel = 2;                                                   // ...cambio de cana -1... 
    }
    else if (vel.y > 50) {
      mode=1;
      changeChannel = 3;
    }
    else if (vel.y < -50) {
      mode=1;
      changeChannel = 4;
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
  else if (sign==2){                                          // Si el cambio de canal es -1...
    stroke(0, 255, 0);                           // Dibuja lineas verdes.
    fill(0, 255, 0);                             // Relleno de lineas color verde.
    if (channelTime == 0)myPort.write('2');      // Si es el primer loop (y es -1), envia al puerto serial para Arduino el valor 2.
    textAlign(RIGHT);                            // LLeva el texto a la izquierda de la pantalla.
    channelChange = "CanAL AbaJo";               // Texto impreso a la izquierda de la pantalla junto con la flecha.
  }
  else if (sign==3){
    stroke(0, 0, 255);
    fill(0, 0, 255);
    if (channelTime == 0)myPort.write('3');
    textAlign(CENTER);
    channelChange = "Flecha arriba";
  }
  else if (sign==4){
    stroke(0, 255, 255);
    fill(0, 255, 255);
    if (channelTime == 0)myPort.write('4');
    textAlign(CENTER);
    channelChange = "Flecha abajo";
  }
  // Ahora dibuja la flecha en la pantalla.
  strokeWeight(10);                              // Linea de 10 pixeles.
  pushMatrix();                                  // Guarda el sistema de coordenadas (fija la matriz).
  translate(width/2,height/2);                   // Se translada a la mitad de la pantalla.
  line(0,0,sign*200,0);                          // La linea de la flecha (line(x1,y1,x2,y2), dos puntos). Cambia de sentido segun cambio de canal.
  triangle(sign*200,20,sign*200,-20,sign*250,0); // El triangulo de la flecha.(triangle(x1,y1,x2,y2,x3,y3)).
  textFont(font,20);                             // Fuente de texto y tamaño.
  //text(channelChange,0,40);                      // Texto y coordenadas del texto (o start-stop).
  popMatrix();                                   // Restaura el sistema de coordenadas.
  popStyle();                                    // Restaura el estilo.
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
  while (itr.hasNext()){                                            // Mientras siga la iteracion...
    PVector p = (PVector) itr.next();                               // ... se crean dos vectores..
    PVector sp = new PVector();                                     // ...
    kinect.convertRealWorldToProjective(p, sp);                     // ...para representar por pantalla.
    vertex(sp.x, sp.y);                                             // Especifica una posicion en 2D.
  }
  endShape();                                                       // Finaliza el punto.
}
  
    

