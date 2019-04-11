int timer;

void setup(){
  // la siguiente funcion configura el tamaño del sketch
  size(800,600);
  /*
  comentario multilinea
  */
}

void draw(){
  background(255);
  ellipse(timer, height/2,30,30);
  timer=timer+1;
}
