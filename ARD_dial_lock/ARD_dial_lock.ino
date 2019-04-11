/*
LED en el pin D13.
Dial entre el pin D2 y GND (NC).
Esta hecho para NC y 1pulso para el cero (y no 10).
Cambiar magicNumberSize y magicNumber para cambiar el codigo.
*/


// Tiempos.
const unsigned long dialingSessionTimeOut=10000UL;       // 10 segundos de NO actividad.
const unsigned long singleDigitDialTimeOut=1000UL;       // 2 segundos de NO actividad (para un solo digito).
const unsigned long contactDebounce=50UL;                // Es el decaimimento de cada pulso, tiempo que se da para otro mas.
const unsigned long successPhaseDuration=10000UL;         // Tiempo de apertura (si se acierta) (TimeOn).

// Codigo.
const int magicNumberSize=7;                             // Numero de digitos del codigo.
const int magicNumber[magicNumberSize]={1,2,3,4,5,6,7};  // Codigo.


// Definicion pines.
const byte ledPin=13;                                    // Pin de salida, led (lock).
const byte dialPin=12;                                    // Pin de entrada, dial.


// Funciones booleanas.
boolean inDialingSession=false;                             // ¿Se esta usando el dial?.
boolean inSingleDigitDial=false;                            // ¿Un numero?.
boolean inSuccessPhase=false;                               // ¿Se acerto el codigo?.


// Tiempos de feedback.(No constantes).
unsigned long pulseReceivedAtMs=0;                       // Pulso recibido hace cero milisegundos.
unsigned long successPhaseStartedAtMs=0;                 // Se acerto hace hace cero milisegundos.

// Enteros y booleanos no constantes.
int numberOfPulsesReceivedForCurrentDigit=0;
int currentDigitIndex=0;
boolean dialPinLast;
boolean dialPinCurrent;
int collectedDialedDigit[magicNumberSize];               // Array de resultados.


void setup(){  // Configuracion.
Serial.begin(9600);     
pinMode(ledPin,OUTPUT);
pinMode(dialPin,INPUT_PULLUP);   // pullup por ser NC=PULL_UP y NO=PULL_DOWN (esto se hace en analogico).
dialPinLast=digitalRead(dialPin);
Serial.println("Dialer Game Starting...");
}



void loop(){                  // Bucle AKA programa.
if(inSuccessPhase){           // Si codigo correcto...
if(millis()-successPhaseStartedAtMs<successPhaseDuration){  //Mientras tiempo limite...
digitalWrite(ledPin,HIGH);   // Enciende LED (abre lock).
}
else{
  digitalWrite(ledPin,LOW);
  inSuccessPhase=false;
  Serial.println("End of success period");
}
}
if(inDialingSession)digitalWrite(ledPin,digitalRead(dialPin));  // LED  flashea con el dial
if(inDialingSession&&millis()-pulseReceivedAtMs>dialingSessionTimeOut){   // Se abandona la sesion, se resetea..
inDialingSession=false;
inSingleDigitDial=false;
numberOfPulsesReceivedForCurrentDigit=0;
Serial.println("Dialing Session TimeOut reached");
}
if(inSingleDigitDial&&millis()-pulseReceivedAtMs>singleDigitDialTimeOut){  // Se acabo tiempo entre pulsos.

/*

Aqui hay dos casos:

Caso 1:
El cero es un pulso, entonces se sustrae uno a todos:

numberOfPulsesReceivedForCurrentDigit--;


Caso2:
El cero son 10 pulsos, tan solo se cambia ese valor:

if(numberOfPulsesReceivedForCurrentDigit==10){
  numberOfPulsesReceivedForCurrentDigit=0;
}

*/


// En este caso se hacia para cero=1pulso:

numberOfPulsesReceivedForCurrentDigit--;

Serial.println();
Serial.print("Digit");
Serial.print(currentDigitIndex);
Serial.print(";pulses received= ");
Serial.println(numberOfPulsesReceivedForCurrentDigit);

collectedDialedDigit[currentDigitIndex]=numberOfPulsesReceivedForCurrentDigit;

if(currentDigitIndex+1==magicNumberSize){  // Se cuenta de 0 a 6 y se acaba la sesion.
Serial.println("Terminating Current Dialing Session");

inDialingSession=false;
bool success=true;

for(int i=0;i<magicNumberSize;i++){
  if(magicNumber[i]==collectedDialedDigit[i]){
    Serial.print("digit:");
    Serial.print(i+1);
    Serial.println("matched magic number");
  }
  else{
    Serial.print("digit:");
    Serial.print(i+1);
    Serial.println("did NOT match magic number");
    success=false;
  }
}
if(success){
  Serial.println("SUCCESS");
  inSuccessPhase=true;
  successPhaseStartedAtMs=millis();
}
else{
  Serial.println("FAILURE");
}
Serial.println();
Serial.println();
Serial.println();
// aqui chequea si es correcto
}
inSingleDigitDial=false;
currentDigitIndex++;
}
dialPinCurrent=digitalRead(dialPin);

if(dialPinCurrent!=dialPinLast&&dialPinCurrent==HIGH&&millis()-pulseReceivedAtMs>contactDebounce){
  if(!inDialingSession){
    Serial.println();
    Serial.println();
    Serial.println("Start now dialing session.");
    inDialingSession=true;
    //startOfDialingSessionMs=millis();
    currentDigitIndex=0;
    inSingleDigitDial=false;  //se fuerza el reseteo
  }
  if(!inSingleDigitDial){
    Serial.println();
    Serial.println("Start new single digit.");
    inSingleDigitDial=true;
    numberOfPulsesReceivedForCurrentDigit=0;
  }
  Serial.println("dial pulse received");
  pulseReceivedAtMs=millis();
  numberOfPulsesReceivedForCurrentDigit++;
}
dialPinLast=dialPinCurrent;
}











  






