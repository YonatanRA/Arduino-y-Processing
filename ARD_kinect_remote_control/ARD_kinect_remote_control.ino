
// Definicion de pines y constantes.

int CanalArriba = 5;       // Canal arriba pin 5.
int CanalAbajo = 6;        // CAnal abajo pin 6.
int VolumenArriba = 7;     // Volumen arriba pin 7.
int VolumenAbajo = 8;      // Volumen abajo pin 8.
int pulso = 300;           // Tiempo mantenido el boton.




void setup(){                       // Funcion de configuracion.
  pinMode(CanalArriba, OUTPUT);     // Se define el pin 5 como salida.
  pinMode(CanalAbajo, OUTPUT);      // Pin 6 como salida.
  pinMode(VolumenArriba, OUTPUT);   // Pin 7 como salida.
  pinMode(VolumenAbajo, OUTPUT);    // Pin 8 como salida.
  Serial.begin(9600);               // Empieza comunicacion serial a 9600 bps.
}



void actualizaPin (int pin, int pulso){ // Funcion para actualizar el valor de los pines., variables pin y tiempo.
Serial.println("Recibido");             // Imprime por el monitor serial: "Recibido".
Serial.println(pin);                    // Imprime por el monitor serial el pin usado.
digitalWrite(pin,HIGH);                 // Se activa dicho pin.
delay(1000);                            // Se espera un segundo.
digitalWrite(pin,LOW);                  // Se desactiva el pin.
Serial.println("Fuera");                // Imprime por el monitor serial: "Fuera".(Se suelta el boton).
}



void loop(){                                // Bucle de programa. 
  if (Serial.available()){                  // Si la comunicacion serial esta disponible...
    char valor=Serial.read();               //... lee el valor que viene del serial y conviertelo en un caracter (un elemento de una cadena de caracteres).
    if(valor== '1') {                       // Si el valor es 1...
      actualizaPin(CanalArriba, pulso);     // ...activa pin 5 (canal arriba).
    } else if(valor== '2') {                // Si el valor es 2...
      actualizaPin(CanalAbajo, pulso);      //...activa pin 6 (canal abajo).
    } else if(valor== '3') {                // Si el valor es 3...
      actualizaPin(VolumenArriba, pulso);   //...activa pin 7 (volumen arriba).
    } else if(valor== '4') {                // Si el valor es 4...
      actualizaPin(VolumenAbajo, pulso);    //...activa pin 8 (volumen abajo).
    }
  }
}


