import controlP5.*;
import java.util.Collections;
import processing.serial.*;
import java.lang.*; 

Serial serialArduino;
boolean bArduino;
boolean firstContact = false;

// Constantes de l'application
String repImg = "/home/gilou/Images/fred44/"; // FeteRGC2015/";
// String repImg = "M:\\Processing 3 - Sketchbook\\diaporamaGrilleGueulomatonLocal\\data\\FDMTinte2015";
// String repImg = "F:\\Sketchbook-3.0\\diaporamaGrilleGueulomatonLocal\\data\\FDMTinte2015";
char pathSep;

imageGrid diaporama;
int sliderValue = 0;
int compteur = 0;
int idxImg;
PFont f;
boolean bRun;
int majDiaporama = 5000; // Mise à jour du diaporama, ms 
int timeMaj;
int tlHeight = 30;

void setup() {
  println("System : "+System.getProperty("os.name"));
  if (new String("Linux").equals(new String(System.getProperty("os.name")))) {
    pathSep = '/'; // Linux
  } else {
    pathSep = '\\';  //Windows
  }

  size(1200, 700); // fullScreen(); 
  
  f = createFont("Calibri", 10);
  textFont(f);
  bRun = false;

  diaporama = new imageGrid(repImg, width, height-tlHeight);
  idxImg = 0;

  // List all the available serial ports:
  // printArray(Serial.list());
  String[] arPorts = Serial.list();
  if (arPorts.length>0) {
    // serialArduino = new Serial(this, "/dev/ttyUSB5", 9600);
    serialArduino = new Serial(this, Serial.list()[0], 9600);
    serialArduino.bufferUntil('\n'); 
    bArduino = true;
  } else {
    bArduino = false;
  }

  // Initialisation des timers
  timeMaj = millis();

  bRun = true;
}


void draw() {
  background(0);
  updateSlider();
  diaporama.update();
  diaporama.display();
  drawTimeline();
  // Mise à jour de la grille
  if (millis()-timeMaj > majDiaporama) {
    majGrille();
    timeMaj = millis();
  }
  
}

// 
void drawTimeline() {
  float m = map(idxImg, 0, diaporama.nbImg, 0, width);
  stroke(255,0,0);
  strokeWeight(2);
  line(m, height-tlHeight, m, height);
  
}

// Fonction appelée à chaque étape 
void updateSlider() {
  //println("idxImg:"+idxImg+", sliderValue:"+sliderValue);
  if (idxImg>sliderValue) {
    idxImg = diaporama.getNext();
    timeMaj = millis();
  } else if (idxImg<sliderValue) {
    idxImg = diaporama.getPrev();
    timeMaj = millis();
  }
}

void majGrille() {
  boolean bMaj = diaporama.reload();
  if (bMaj) {
    // majTimeline
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      updateCompteur(7);
    } else if (keyCode == RIGHT) {
      updateCompteur(-7);
    }
  }
}

// Un message est reçu depuis l'Arduino
void serialEvent(Serial portLu) {
  String message = portLu.readStringUntil('\n'); // On lit le message reçu, jusqu'au saut de ligne
  if (message != null)
  {
    message = trim(message);
    // println(message);

    if (message.charAt(0)=='A') {
      // Premier contact : recherche de la lettre A
      portLu.clear();
      portLu.write("A");
      println("Premier contact");
    } else { 
      // Le premier contact à été établi
      // println("Message:"+message);
      // On découpe le message à chaque virgule, on le stocke dans un tableau
      String [] numbers = message.split(",");
      int[] values = int(numbers);
      if (values.length==2) {
        updateCompteur(values[0]);
        // Play sound
        if (values[1] == 4) {
          // playSound();
        }
        println("Encoder:"+values[0]+" Bouton:"+values[1]);
      }
    }
  } 
  // else {
  // println("Message Null");
  // }
}

void updateCompteur(int value) {
  compteur += value;
  int increment = compteur / 7;
  if (abs(increment)>0) {
    sliderValue += increment;
    compteur = 0;
  }
}

void mousePressed() {
  if (mouseY>height-tlHeight) {
    sliderValue = int(map(mouseX, 0, width, 0, diaporama.nbImg-1)); 
  }
}