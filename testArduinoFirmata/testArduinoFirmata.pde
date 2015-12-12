import processing.serial.*;
import cc.arduino.*;
import java.lang.*; 

Arduino myArduino;
int xPos;         // horizontal position of the graph
float valLue = 0;
float valMax = 0;
float valMin = 2000;
float arVals[];
boolean bArduino;

void setup() {
  size(500, 200);

  arVals = new float[width+1];
  xPos = 0;

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
    myArduino.pinMode(0, Arduino.INPUT);
    bArduino = true;
  } 
  catch (Exception e) {
    e.printStackTrace();
    bArduino = false;
  }
}

void draw () {
  background(225);
  // Lecture arduino ou souris
  if (bArduino) {
    valLue = myArduino.analogRead(0);
  } else { 
    valLue = 1023*(  (height - mouseY) / height); // / ((float) height*1023);
  }
  valMax = max(valLue, valMax);
  valMin = min(valLue, valMin);
  arVals[xPos] = valLue/1024*height;

  // Affichage du graphe
  stroke(200);
  line(xPos, 0, xPos, height);

  stroke(127, 34, 255);
  noFill();
  beginShape();
  for (int i=0; i<=xPos; i++) {
    curveVertex(i, height-arVals[i]);
  }
  endShape();

  // Affichage debug vals min et max
  fill(0, 102, 153);
  if (bArduino) {
    text("Arduino connected Max:"+valMax+", min:"+valMin, 2, 20);
  } else {
    text("No arduino, using mouseY Max:"+valMax+", min:"+valMin, 2, 20);
  }
  // at the edge of the screen, go back to the beginning:
  if (xPos >= width) {
    xPos = 0;
  } else {
    // increment the horizontal position:
    xPos++;
  }
}