/** Télécran version 2.0 - Giloop
 * Potentiomètres connectés à une arduino pour dessiner comme un télécran
 * Ajout de fonctionnalités pour choisir la couleur, 
 *
 */
import processing.serial.*;
import cc.arduino.*;
import java.lang.*; 

Arduino myArduino;
int xPos;         // horizontal position of the graph
int NB_INPUTS = 4; 
float arValLues[];
float arValMax[];
float arValMin[];
float arVals[][];

color arColors[];

void setup() {
  size(780, 640);

  //arValLues = new float[NB_INPUTS];
  arValMax  = new float[NB_INPUTS];
  arValMin  = new float[NB_INPUTS];
  arVals    = new float[width+1][NB_INPUTS];
  xPos = 0;
  arColors  = new color[NB_INPUTS];
  arColors[0] = color(200,0,0);
  arColors[1] = color(0,255,50);
  arColors[2] = color(200,200,0);
  arColors[3] = color(20,20,255);

  // Prints out the available serial ports.
  //println(Arduino.list());

  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  try {
    myArduino = new Arduino(this, Arduino.list()[0], 57600);
    // Alternatively, use the name of the serial port corresponding to your
    // Arduino (in double-quotes), as in the following line.
    //myArduino = new Arduino(this, "/dev/ttyACM0", 57600);

    // Set the Arduino digital pins as inputs.
    for (int i=0;i<NB_INPUTS; i++) {
      myArduino.pinMode(i, Arduino.INPUT); 
      arValMax[i] = 0;
      arValMin[i] = 2000;
    }
  } 
  catch (Exception e) {
    e.printStackTrace();
    println("Ce sketch nécessite une carte arduino avec Firmata");
    exit();
  }
  println("Arduino connecte");
}

void draw () {
  int i,j;
  
  background(235);
  // Lecture arduino ou souris
  for (i=0;i<NB_INPUTS; i++) {
     arVals[xPos][i] = myArduino.analogRead(i);
     arValMax[i] = max(arVals[xPos][i], arValMax[i]);
     arValMin[i] = min(arVals[xPos][i], arValMin[i]);
  }
  
  // Barre de défilement du graphe
  stroke(200);
  line(xPos, 0, xPos, height);

  for (i=0;i<NB_INPUTS; i++) {
     // Affichage debug vals min et max
     fill(arColors[i]);
     text("AI["+i+"], min:"+arValMin[i]+", max:"+arValMax[i], 2, 20+15*i);
     
     // Courbes des valeurs lues
     stroke(arColors[i]);
     noFill();
     beginShape();
     for (j=0; j<=xPos; j++) {
       curveVertex(j, height-arVals[j][i]);
     }
     endShape();
  }
  
  // at the edge of the screen, go back to the beginning:
  if (xPos >= width) {
    xPos = 0;
    
  } else {
    // increment the horizontal position:
    xPos++;
  }
}

/*void keyReleased() {
    background(225);
}*/