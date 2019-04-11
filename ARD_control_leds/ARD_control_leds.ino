int val, xVal, yVal;
void setup(){
  Serial.begin(9600);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
}
void loop(){
  //chequea si se han enviado suficientes datos desde el pc
  if (Serial.available()>2){
    //lee el primer valor.esto indica el comienzo de la comunicacion
    val=Serial.read();
    //si el valor es el evento 'S'
    if(val == 'S'){
      //lee el byte mas reciente, el cual es x (x-value)
      xVal=Serial.read();
      //luego lee y (y-value)
      yVal=Serial.read();
    }
  }
  analogWrite(10, xVal);
  analogWrite(11, yVal);
}

