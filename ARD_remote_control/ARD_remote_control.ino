int ChannelPlusPin = 5;
int ChannelLessPin = 6;
int VolumePlusPin = 7;
int VolumeLessPin = 8;
int pulse = 250; //tiempo mantenido el boton

void setup(){
  pinMode(ChannelPlusPin, OUTPUT);
  pinMode(ChannelLessPin, OUTPUT);
  pinMode(VolumePlusPin, OUTPUT);
  pinMode(VolumeLessPin, OUTPUT);
  Serial.begin(9600); // empieza comunicacion serial a 9600 bps
}

void updatePin (int pin, int pulse){
Serial.println("RECEIVED");
Serial.println(pin);
digitalWrite(pin,HIGH);
delayMicroseconds(pulse);
digitalWrite(pin,LOW);
Serial.println("OFF");
}

void loop(){
  if (Serial.available()){
    char val=Serial.read();
    if(val == '1') {
      updatePin(ChannelPlusPin, pulse);
    } else if(val == '2') {
      updatePin(ChannelLessPin, pulse);
    } else if(val == '3') {
      updatePin(VolumePlusPin, pulse); 
    } else if(val == '4') {
      updatePin(VolumeLessPin, pulse);  
    }
  }
}

      
