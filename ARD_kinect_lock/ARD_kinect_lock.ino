// ARDkinect_LOCK

// Por un lado la entrada es serial.
// Pongamos 4 movimientos ==>  6 salidas
// Definicion de pines y constantes.

const int ledUno=2;        // Led paso 1.
const int ledDos=3;        // Led paso 2.
const int ledTres=4;       // Led paso 3.
const int ledCuatro=5;     // Led paso 4.
const int ledPuerta=6;     // Led de la puerta(para reconocimiento de mano).
const int puerta=7;        // Rele.

const int digitosCodigo=4;                 // Numero de digitos del codigo.
const int codigo[digitosCodigo]={1,2,3,4}; // Codigo.

int lecturas[digitosCodigo];    // Lecturas.

int indiceNumero=0;   // Indice numerico.
//int previo;           // Numero previo.
int actual;           // Numero actual.



void setup(){                       // Funcion de configuracion.
  pinMode(ledUno, OUTPUT);          // Se define el pin 2 como salida.
  pinMode(ledDos, OUTPUT);          // Pin 3 como salida.
  pinMode(ledTres, OUTPUT);         // Pin 4 como salida.
  pinMode(ledCuatro, OUTPUT);       // Pin 5 como salida.
  pinMode(ledPuerta, OUTPUT);       // Pin 6 salida.
  pinMode(puerta, OUTPUT);          // Pin 7 salida(rele).
  Serial.begin(9600);               // Empieza comunicacion serial a 9600 bps.

  //previo=Serial.read();
}


void loop(){ 
  digitalWrite(ledUno,LOW);
  digitalWrite(ledDos,LOW);
  digitalWrite(ledTres,LOW); 
  digitalWrite(ledCuatro,LOW);
  digitalWrite(ledPuerta,LOW);
  digitalWrite(puerta,LOW);  
  if (Serial.available()){ 
    actual=Serial.read();
    lecturas[indiceNumero]=actual;   
    for(int i=0;i<digitosCodigo;i++){                         // Bucle para comparacion de lecturas y codigo.
       if(codigo[i]==lecturas[i]){ 
         digitalWrite(puerta, HIGH);
       }
       else{
         digitalWrite(puerta,LOW);
       }
    }
    indiceNumero++;
  }
}

