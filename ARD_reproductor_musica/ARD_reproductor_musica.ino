


#include <pcmConfig.h> // librerias reproductor audio
#include <pcmRF.h>
#include <TMRpcm.h>
#include <SPI.h>  // librerias tarjeta microSD
#include <SD.h>
#define SD_CS 4  // pin 4 como chip select
TMRpcm musica;
boolean debounce=true;
void setup(){
   musica.speakerPin = 3; //Audio out pin 3
  Serial.begin(9600);  
  if (!SD.begin(SD_CS)) {
    Serial.println("error SD");
    return;
   }
  
  musica.setVolume(4);    //   0 a 7.volumen
  musica.quality(1);
  musica.play((char*)"motor.wav");
}


void loop(){
  
  }


