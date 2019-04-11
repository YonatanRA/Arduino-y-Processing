/*

ARDGondolaDialRotatorio...

LED Verde en el pin D9.
LED Rojo en el pin D10.

Rele en el pin D8

Dial entre el pin D2 y GND directamente (NC, PULL UP).

*/

#include <avr/wdt.h>   // WatchDog

// Tiempos.
const unsigned long tiempoMarcado=10000UL;                // Milisegundos de NO actividad. (UL=Unsigned Long). 
const unsigned long tiempoPorNumero=1000UL;               // Milisegundos de NO actividad (para un solo digito).
const unsigned long dialDecay=50UL;                       // Es el decaimimento de cada pulso, tiempo que se da para otro mas.(Debounce).
const unsigned long tiempoApertura=1000000UL;             // Tiempo de apertura (si se acierta). Puesto 16 minutos aprox.

// Codigo.
const int digitosCodigo=4;                                // Numero de digitos del codigo.
const int codigo[digitosCodigo]={6,4,0,3};  //codigo              // Codigo.


// Definicion pines.
const byte rele=7;                                        // Pin de salida, rele.
const byte ledVerde=10;                                   // Pin de salida, led.
const byte ledRojo=12;                                    // Pin de salida, led.
const byte dial=3;                                        // Pin de entrada, dial.


// Funciones booleanas.
boolean marcando=false;                                   // ¿Se esta usando el dial?.
boolean numeroMarcado=false;                              // ¿Un numero?.
boolean faseAcierto=false;                                // ¿Se acerto el codigo?.


// Tiempos de feedback.(No constantes).
unsigned long pulsoRecibidoMs=0;                          // Pulso recibido hace cero milisegundos.
unsigned long aciertoEmpezoMs=0;                          // Se acerto hace cero milisegundos.

// Enteros y booleanos no constantes.
int numeroPulsosDigitoActual=0;                           // Numero de pulsos recibidos del presente digito.
int indiceDigitoActual=0;                                 // Indice del digito, que lugar ocupa en la secuencia.
boolean dialPrevio;                                       // ¿Numero anterior?.
boolean dialActual;                                       // ¿Numero nuevo?.
int lecturas[digitosCodigo];                              // Array de lecturas, resultados.


void setup(){                                             // Configuracion.
wdt_disable();
Serial.begin(9600);                                       // Comienza comunicacion serial(debug).   

pinMode(ledVerde,OUTPUT);                                 // Pin salida, LED Verde.
pinMode(ledRojo,OUTPUT);                                  // Pin salida, LED Rojo.
pinMode(rele,OUTPUT);                                     // Pin salida, rele.
pinMode(dial,INPUT_PULLUP);                               // Pin entrada, Dial.Pullup por ser NC=PULL_UP y NO=PULL_DOWN (esto se hace en analogico).

dialPrevio=digitalRead(dial);                             // Lectura del dial se convierte en el numero anterior.

Serial.println("Empieza...");                             // Imprime por el monitor serial:"Empieza...".
wdt_enable(WDTO_250MS); // WatchDog cada 250ms
}



void loop(){                                              // Ciclo de programa.
 wdt_reset();
digitalWrite(ledRojo,HIGH);                               // Enciende el LED Rojo, para status. La maquina va.
digitalWrite(ledVerde,LOW);                               // LED Verde Apagado.
                                   
 wdt_reset();
if(faseAcierto){                                          // Si el codigo es correcto...
  if(millis()-aciertoEmpezoMs<tiempoApertura){            // y mientras se este dentro del tiempo limite...
     wdt_reset();
    digitalWrite(ledVerde,HIGH);                          // enciende el LED Verde...
    digitalWrite(ledRojo,LOW);                            // ...apaga el LED Rojo...
    digitalWrite(rele,HIGH);                              // ..y activa el rele.
  }
  else{                                                     // De otra manera...
     wdt_reset();
    digitalWrite(ledVerde,LOW);                             // el LED Verde apagado...
    digitalWrite(ledRojo,HIGH);                             // ...el LED Rojo encendido..
    digitalWrite(rele,LOW);                                 // ...y el rele desactivado.
    faseAcierto=false;                                      // No se ha acertado.
    Serial.println("Fin del periodo de acierto.");          // Imprime por el monitor serial:"Fin del periodo de acierto".
}
}
if(marcando)digitalWrite(ledVerde,digitalRead(dial));     // Si se esta marcando, el LED parpadea a la vez que el dial.
 wdt_reset();
if(marcando&&millis()-pulsoRecibidoMs>tiempoMarcado){     // Si se superan los tiempos de marcado, se abandona la sesion, se resetea..
    wdt_reset();
   marcando=false;                                        // No se esta marcando.
   numeroMarcado=false;                                   // Ningun numero.
   numeroPulsosDigitoActual=0;                            // Ningun pulso se ha dado...(Reset).
   for (int i=0;i<10;i++){                                // Bucle para blink del LED Rojo, para saber que se ha superado el tiempo de marcado.
        wdt_reset();
       digitalWrite(ledRojo,LOW);                         // Apaga LED Rojo.
       delay(50);                                         // Delay 50 milisegundos.
       digitalWrite(ledRojo,HIGH);                        // Enciende LED Rojo.
       delay(50);                                         // Delay 50 milisegundos.
       wdt_reset();
}

Serial.println("Se ha alcanzado el tiempo limite.");      // Imprime por el monitor serial:"Se ha alcanzado el tiempo limite.".
}

if(numeroMarcado&&millis()-pulsoRecibidoMs>tiempoPorNumero){  // Si se acabo tiempo entre pulsos.
 wdt_reset();
   if(numeroPulsosDigitoActual==10){                          //El cero son 10 pulsos, tan solo se cambia ese valor.
     numeroPulsosDigitoActual=0;
 wdt_reset();
}
   if(numeroPulsosDigitoActual==11){                          // Proteccion contra error mecanico del dial...solo para el cero
     numeroPulsosDigitoActual=0;
}
 wdt_reset();
Serial.println();
Serial.print("Digito");                                   // Imprime por el monitor serial:"Digito".
Serial.print(indiceDigitoActual);                         // Imprime por el monitor serial el indice del digito actual.
Serial.print(";pulsos recibidos= ");                      // Imprime por el monitor serial:"pulsos recibidos=".
Serial.println(numeroPulsosDigitoActual);                 // Imprime por el monitor serial el numero de pulsos que es igual al numero salvo el cero(10 pulsos).

lecturas[indiceDigitoActual]=numeroPulsosDigitoActual;    // Se llena el array de lecturas con el numero de pulsos.

if(indiceDigitoActual+1==digitosCodigo){                  // Se cuenta de 0 a 6, por la sustraccion, y se acaba la sesion.
   Serial.println("Marcado terminado.");                  // Imprime por el monitor serial:"Marcado Terminado.".
    wdt_reset();
marcando=false;                                           // No se esta marcando.
boolean acierto=true;                                     // Funcion booleana acierto (=true). 
 wdt_reset();
for(int i=0;i<digitosCodigo;i++){                         // Bucle para comparacion de lecturas y codigo.
  if(codigo[i]==lecturas[i]){                             // Si el codigo es igual a la lectura...(boolean acierto no cambia). 
     wdt_reset();
    Serial.print("digito:");                              // Imprime por el monitor serial los digitos correctos del codigo.
    Serial.print(i+1);
    Serial.println("Codigo correcto.");
  }
  else{                                                   // De otra manera..
    Serial.print("digito:");                              // Imprime por el monitor serial los digitos incorrectos del codigo.
    Serial.print(i+1);                                
    Serial.println("Codigo incorrecto.");
    wdt_reset();
    acierto=false;                                        //...si cambia el valor de boolean acierto=false.(El codigo no es correcto).
  }
}
if(acierto){                                              // Si se acierta...
  Serial.println("Acierto.");                             // Imprime por el monitor serial:"Acierto.".
  faseAcierto=true;                                       // Empieza fase de acierto.(boolean).
   wdt_reset();
  aciertoEmpezoMs=millis();                               // El acierto empezo hace....milisegundos (desde el principio).
}
else{                                                     // De otra manera, si no se acierta...
  for (int i=0;i<10;i++){                                 // Bucle:El LED Rojo parpadea 10 veces como aviso de fallo en el codigo.
    digitalWrite(ledRojo,LOW);                            // Apaga el LED Rojo.
     wdt_reset();
    delay(50);                                            // Delay de 50 milisegundos.
    digitalWrite(ledRojo,HIGH);                           // Enciende el LED Rojo.
    delay(50);                                            // Delay de 50 milisegundos.
  }
    
  Serial.println("Fracaso.");                              // Imprime por el monitor serial:"Fracaso.".
}
Serial.println();
Serial.println();
Serial.println();
 wdt_reset();
}
numeroMarcado=false;                 // Aqui chequea si es correcto...
indiceDigitoActual++;                // ...uno por uno.
}
dialActual=digitalRead(dial);        // El nuevo numero es la nueva lectura.

if(dialActual!=dialPrevio&&dialActual==HIGH&&millis()-pulsoRecibidoMs>dialDecay){   // Si el nuevo no es como el anterior, y nuevo existe, y el tiempo es mayor que el decay
  if(!marcando){                                        // Si no se esta marcando....
    Serial.println();
    Serial.println();
    Serial.println("Empieza el marcado.");              // Imprime en el monitor serial:"Empieza el marcado.".
    wdt_reset();
    marcando=true;                                      // ...se esta marcando. xD.
    indiceDigitoActual=0;                               // Se vuelve al primer digito...
    numeroMarcado=false;                                // y se fuerza el reseteo.
  }
  if(!numeroMarcado){                                   // Si no hay numero nuevo....
    Serial.println();
    Serial.println("Nuevo numero.");                    // Imprime en el monitor serial:"Nuevo numero.".
     wdt_reset();
    numeroMarcado=true;                                 // ...hay numero nuevo.xD.
    numeroPulsosDigitoActual=0;                         // Se resetea el numero de pulsos.
  }
  Serial.println("Pulso del dial recibido.");           // Imprime por el monitor:"Pulso del dial recibido.".
  pulsoRecibidoMs=millis();                             // Milisegundos desde el inicio hace que se recibieron. 
  numeroPulsosDigitoActual++;                           // Incremento del numero de pulsos.
}
 wdt_reset();
dialPrevio=dialActual;                                  
}











  
