const int rele=8; //rele digital 8
const int ball=0; // pin A0 bola plasma

void setup(){
  Serial.begin(9600);
  pinMode(rele,OUTPUT); // el pin analogico se declara
                       // como entrada automaticamente
                       
}

void loop(){
  long sum=0;
  for (int i=0;i<5;i++){
    sum=sum+analogRead(ball);
    delay(100);
  }
  float average=sum/5.0;
  float voltage=sum/1023;  //voltage=sum*0.00097751710655 es mas rapido
  Serial.println(average);
  if (average<=500){
    delay(1000);
    digitalWrite(rele, LOW);
    delay(1000);
  }
  else {
    digitalWrite(rele, HIGH);
  }
}

    

