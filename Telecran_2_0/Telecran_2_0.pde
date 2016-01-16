/** Télécran version 2.0 - Giloop
 * Potentiomètres connectés à une arduino pour dessiner comme un télécran
 * Ajout de fonctionnalités pour choisir la couleur, 
 */
import processing.serial.*;
import cc.arduino.*;
import java.lang.*; 
import java.io.*;

Arduino myArduino;
static int NB_INPUTS = 4;
ArrayList<Data3D> arDonnees; // Valeurs lues en entrée analogiques
Data3D newPt, prevPt;

void setup() {
  size(780, 640);
  colorMode(HSB, 256, 256, 256);  
  
  arDonnees = new ArrayList<Data3D>();

  // Prints out the available serial ports.
  //println(Arduino.list());

  try {
    myArduino = new Arduino(this, Arduino.list()[0], 57600);
    //myArduino = new Arduino(this, "/dev/ttyACM0", 57600);

    // Set the Arduino digital pins as inputs.
    for (int i=0;i<NB_INPUTS; i++) {
      myArduino.pinMode(i, Arduino.INPUT); 
    }
  } 
  catch (Exception e) {
    e.printStackTrace();
    println("Ce sketch nécessite une carte arduino avec Firmata");
    exit();
  }
  println("Arduino connecte");

  // Initialisation des points
  newPt = new Data3D(0, myArduino.analogRead(0), myArduino.analogRead(1), myArduino.analogRead(3));
  prevPt = new Data3D(0, myArduino.analogRead(0), myArduino.analogRead(1), myArduino.analogRead(3));

}

void draw () {
  // Lecture arduino   
  newPt.t = millis();
  newPt.x = myArduino.analogRead(0);
  newPt.y = myArduino.analogRead(1);
  newPt.c = myArduino.analogRead(3);
  
  if (prevPt == newPt) { return; }

  arDonnees.add(newPt);
  
  stroke(2*floor(newPt.c/4), 128*(int(newPt.c>512)+1), 256);
  
  //point(newPt.x/1024*width,newPt.y/1024*height);
  line(prevPt.x, prevPt.y, newPt.x, newPt.y);
  
  /*for (i=0;i<NB_INPUTS; i++) {
     // Affichage debug vals min et max
     fill(arColors[i]);
     
     // Courbes des valeurs lues
     stroke(arColors[i]);
     noFill();
     beginShape();
     for (j=0; j<=xPos; j++) {
       curveVertex(j, height-arVals[j][i]);
     }
     endShape();
  }*/

  prevPt.t = newPt.t;
  prevPt.x = newPt.x;
  prevPt.y = newPt.y;
  prevPt.c = newPt.c;
}

void keyReleased() 
{
  if (key== ' ') {
    // Efface le fond
    background(225);
  } else if (key== 's') {
    // Sauve un fichier .txt
    try {
      writeToFile();
    } catch (IOException e) {
     // handle it, etc.
    }
  } 
}

public void writeToFile() throws IOException {
    FileWriter file;
    Data3D pt;
    //bool tells to append
    file = new FileWriter(String.format("etch%04d-%02d_%02d-%02dh%02dm%02ds.txt", year(), month(), day(), hour(), minute(), second()), true); 
    for (int i=0; i<arDonnees.size(); i++) {
      pt = arDonnees.get(i);
      file.write("\n"+String.format("%d\t%d\t%d\t%d\n", pt.t, pt.x, pt.y, pt.c));
    }
  file.close();
  println("file updated");
}