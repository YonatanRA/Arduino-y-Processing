
#include <avr/wdt.h>   // WatchDog

const int uno=6; // entradas de cuadro
const int dos=5;
const int tres=4;
const int cuatro=3;
const int cinco=2;

const int led=9;// led rojo

const int lock=12; //puerta

long s1=0; //variables de puerta
long s2=0;
long s3=0;
long s4=0;
long s5=0;



void setup(){
  wdt_disable();
  
  pinMode(uno,INPUT_PULLUP); //entradas cuadro
  pinMode(dos,INPUT_PULLUP);
  pinMode(tres,INPUT_PULLUP);
  pinMode(cuatro,INPUT_PULLUP);
  pinMode(cinco,INPUT_PULLUP);
  
  pinMode(led,OUTPUT); //salidas led y puerta
  pinMode(lock,OUTPUT);
  
  wdt_enable(WDTO_250MS); // WatchDog cada 250ms
}


void loop(){
  wdt_reset();
  s1=digitalRead(uno); // lectura cuadro
  s2=digitalRead(dos);
  s3=digitalRead(tres);
  s4=digitalRead(cuatro);
  s5=digitalRead(cinco);
  wdt_reset();
  if (s1==LOW && s2==HIGH& s3==LOW && s4==LOW && s5==HIGH){
    digitalWrite(led, LOW); // si combinacion correcta abre y apaga
    digitalWrite(lock, HIGH);
  }
  else{
    digitalWrite(led, HIGH); // si no cerrada y encendido
    digitalWrite(lock, LOW);
  }
  wdt_reset();
}

