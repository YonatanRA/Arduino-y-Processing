
// Definicion de pines
const int knockSensor = 0;         // Sensor piezoelectrico en pin A0.
const int programSwitch = 2;       // Interruptor en pin D2 para programar codigo.
const int lockMotor = 3;           // Pin D3 para puerta(rele).
const int redLED = 4;              // LED rojo en pin D4.
const int greenLED = 5;            // LED verde en pin D5.
 
// Ajustando constantes.  
const int threshold = 5;           // Umbral, señal minima desde el piezo para registrar un knock.
const int rejectValue = 25;        // Si un Knock individual esta fuera de este porcentaje de un knock, la puerta no se abre.
const int averageRejectValue = 25; // Si la media temporal de los knock esta fuera de este porcentaje, no se abre.
const int knockFadeTime = 150;     // Milisegundos de un knock antes de escuchar por otro.(Debounce).
const int lockTurnTime = 1800;     // Milisegundos que permanece activado el rele(puerta).

const int maximumKnocks = 20;       // Maximo numero de knocks.
const int knockComplete = 1800;     // Mayor tiempo de espera por un knock antes de asumir que se completo el codigo.


// Variables.
int secretCode[maximumKnocks] = {100, 50, 100, 50, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};  // Codigo inicial...(1...1,2...1,2,3).
int knockReadings[maximumKnocks];   // Cuando alguien toca, este array se rellena de los delay entre knocks.
int knockSensorValue = 0;           // Ultima lectura del piezo.
int programButtonPressed = false;   // Para recordar la programacion realizada a traves del interruptor al final del ciclo.



void setup() {                      // Configuracion.
  pinMode(lockMotor, OUTPUT);       // Salida, rele (cerradura).
  pinMode(redLED, OUTPUT);          // Salida, LED rojo.
  pinMode(greenLED, OUTPUT);        // Salida, LED verde.
  pinMode(programSwitch, INPUT);    // Entrada, pulsador de programacion.
  // Los pines analogicos, como el pin del piezoelectrico, son automaticamente entradas.
  
  Serial.begin(9600);               // Empieza comunicacion serial, para debug.
  Serial.println("Program start."); // Imprime en el monitor serial:
  
  digitalWrite(greenLED, HIGH);     // LED verde encendido, el aparato va.
}

void loop() {
  
  knockSensorValue = analogRead(knockSensor);  // Escucha por cualquier knock.
  
  if (digitalRead(programSwitch)==HIGH){       // ¿Esta apretado el boton de programacion?.
    programButtonPressed = true;               // Si, se guarda el nuevo codigo.
    digitalWrite(redLED, HIGH);                // y se enciende tambien el LED rojo para saber que se esta programando. 
  } 
  else {                                       // De otra manera...
    programButtonPressed = false;              // No, no esta apretado..
    digitalWrite(redLED, LOW);                 // asi que el LED rojo permanace apagado.
  }
  
  if (knockSensorValue >=threshold){           // Si el valor esta por encima del umbral..
    listenToSecretKnock();                     // comprueba el codigo.
  }
} 


void listenToSecretKnock(){                    // Funcion para codigo.Graba el tiempo entre knocks para saber si es correcto el codigo..
  Serial.println("knock starting");            // Imprime en el monitor serial: 

  int i = 0;                                   // Definicion de entero para bucle.
  
  for (i=0;i<maximumKnocks;i++){               // Primero resetea el array de escuchas.
    knockReadings[i]=0;                        // Todas a cero.
  }
  
  int currentKnockNumber=0;                    // Incremento para el array.
  int startTime=millis();           	       // Referencia para cuando empiecen los knock.
  int now=millis();
  
  digitalWrite(greenLED, LOW);      	       // El LED verde parpadea a la vez que se toca(blink-Knock).
  if (programButtonPressed==true){             // Si se esta programando...
     digitalWrite(redLED, LOW);                // tambien el rojo parpadea.
  }
  delay(knockFadeTime);                        // Espera este tiempo antes de escuchar al siguiente.
  digitalWrite(greenLED, HIGH);                // Enciende el LED verde.
  if (programButtonPressed==true){             // Si se esta programando...
     digitalWrite(redLED, HIGH);               // tambien el rojo.
  }
  
  
  do {     // HAZ.....MIENTRAS...(do-while)...El while va despues.
  //Escucha al siguiente knock o espera hasta el final del tiempo de codigo.
    knockSensorValue = analogRead(knockSensor);          // Valor del piezo, se lee el pin A0.
    if (knockSensorValue >=threshold){                   // Si el valor sobrepasa el umbral, registra otro knock...
      Serial.println("knock.");                          // Imprime en el monitor serial: "knock."
      now=millis();                                      // Graba el tiempo de delay.
      knockReadings[currentKnockNumber] = now-startTime;
      currentKnockNumber ++;                             // Incrementa el contador.
      startTime=now;          
      // Resetea el contador de tiempo para el siguiente knock.
      digitalWrite(greenLED, LOW);                       // Apaga el LED verde..
      if (programButtonPressed==true){
        digitalWrite(redLED, LOW);                       // y el rojo tambien si se esta programando.
      }
      delay(knockFadeTime);                              // Otra vez. Se pone un delay para permitir el decaimiento del knock.
      digitalWrite(greenLED, HIGH);
      if (programButtonPressed==true){
        digitalWrite(redLED, HIGH);                         
      }
    }

    now=millis();
    
    //¿Se ha pasado el tiempo o se han pasado de knocks?
  } while ((now-startTime < knockComplete) && (currentKnockNumber < maximumKnocks));
  
  //Se tiene el nuevo codigo guardado, se ve si es valido.
  if (programButtonPressed==false){             // Solo si no se esta programando...
    if (validateKnock() == true){
      triggerDoorUnlock(); 
    } else {
      Serial.println("Secret knock failed.");
      digitalWrite(greenLED, LOW);  		// No se ha abierto. El LED rojo parpadea como feedback.
      for (i=0;i<4;i++){					
        digitalWrite(redLED, HIGH);
        delay(100);
        digitalWrite(redLED, LOW);
        delay(100);
      }
      digitalWrite(greenLED, HIGH);
    }
  } else { // Si se esta programando, se valida la cerradura, pero sin hacer nada con ella.
    validateKnock();
    // Parpadeo alternativo verde-rojo muestra programacion completa.
    Serial.println("New lock stored.");
    digitalWrite(redLED, LOW);
    digitalWrite(greenLED, HIGH);
    for (i=0;i<3;i++){
      delay(100);
      digitalWrite(redLED, HIGH);
      digitalWrite(greenLED, LOW);
      delay(100);
      digitalWrite(redLED, LOW);
      digitalWrite(greenLED, HIGH);      
    }
  }
}


// Funcion para abrir la puerta.
void triggerDoorUnlock(){
  Serial.println("Door unlocked!");
  int i=0;
  
  
  digitalWrite(lockMotor, HIGH);           // Enciende el rele.(Abre la cerradura).
  
  for (i=0; i < 5; i++){                   //Parpadeo de LED verde como confirmacion apertura.
      digitalWrite(greenLED, LOW);
      delay(100);
      digitalWrite(greenLED, HIGH);
      delay(100);
  } 
  delay (lockTurnTime);                    // Espera el tiempo de apertura.
  
  digitalWrite(lockMotor, LOW);            // Apaga el rele.(Cierra la cerradura).
}


// La siguiente funcion comprueba si se acierta el codigo de knocks.
// Devuelve true si esta bien, y false si esta mal.
boolean validateKnock(){
  int i=0;
 
  // Se comprueba si se han dado el numero correcto de knocks.
  int currentKnockCount = 0;
  int secretKnockCount = 0;
  int maxKnockInterval = 0;          			// Esto se usa para normalizar el tiempo.
  
  for (i=0;i<maximumKnocks;i++){
    if (knockReadings[i] > 0){
      currentKnockCount++;
    }
    if (secretCode[i] > 0){  					
      secretKnockCount++;
    }
    
    if (knockReadings[i] > maxKnockInterval){ 	// Se recogen los datos normalizados mientras se esta en el loop.
      maxKnockInterval = knockReadings[i];
    }
  }
  
  // Si se esta programando un nuevo codigo, se guarda aqui.
  if (programButtonPressed==true){
      for (i=0;i<maximumKnocks;i++){ // Normaliza los tiempos.
        secretCode[i]= map(knockReadings[i],0, maxKnockInterval, 0, 100); 
      }
      // Y repite el patron guardado con parpadeos de los LEDs.
      digitalWrite(greenLED, LOW);
      digitalWrite(redLED, LOW);
      delay(1000);
      digitalWrite(greenLED, HIGH);
      digitalWrite(redLED, HIGH);
      delay(50);
      for (i = 0; i < maximumKnocks ; i++){
        digitalWrite(greenLED, LOW);
        digitalWrite(redLED, LOW);  
        // Solo se enciende si hay un delay.
        if (secretCode[i] > 0){                                   
          delay( map(secretCode[i],0, 100, 0, maxKnockInterval)); //Expande hacia atras el tiempo a lo que era.Aprox, para que coincida.
          digitalWrite(greenLED, HIGH);
          digitalWrite(redLED, HIGH);
        }
        delay(50);
      }
	  return false; 	// No se abre la cerradura cuando se programa un nuevo codigo.
  }
  
  if (currentKnockCount != secretKnockCount){
    return false; 
  }
  
  
  /*  Ahora se comparan los intervalos relativos de los knocks, no el tiempo absoluto entre ellos.
      Es decir, si se hace el patron mas rapido o mas lento se reconocera igualmente y se abrira la puerta.
  */
  int totaltimeDifferences=0;
  int timeDiff=0;
  for (i=0;i<maximumKnocks;i++){ // Normaliza los tiempos.
    knockReadings[i]= map(knockReadings[i],0, maxKnockInterval, 0, 100);      
    timeDiff = abs(knockReadings[i]-secretCode[i]);
    if (timeDiff > rejectValue){ // Valor individual muy lejos, en el tiempo, y se rechaza.
      return false;
    }
    totaltimeDifferences += timeDiff;
  }
  // Tambien puede fallar si todo es muy impreciso.
  if (totaltimeDifferences/secretKnockCount>averageRejectValue){
    return false; 
  }
  
  return true;
  
}
