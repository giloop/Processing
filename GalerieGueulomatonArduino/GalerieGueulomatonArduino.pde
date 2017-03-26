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
ControlP5 cp5;
int sliderValue = 0;
int compteur = 0;
int idxImg;
PFont f;
boolean bRun;
int majDiaporama = 5000; // Mise à jour du diaporama, ms 
int timeMaj;

void setup() {
  if (new String("Linux").equals(new String(System.getProperty("os.name")))) {
    pathSep = '/'; // Linux
  } else {
    pathSep = '\\';  //Windows
  }

  size(1200, 700); // fullScreen(); //  3840        2160
  println("System : "+System.getProperty("os.name"));

  f = createFont("Calibri", 10);
  textFont(f);
  bRun = false;

  diaporama = new imageGrid(repImg, width, height-22);
  idxImg = 0;

  cp5 = new ControlP5(this);

  // create a new button with name 'buttonA'
  cp5.addButton("getPrev")
    .setValue(0)
    .setPosition(0, height-20)
    .setSize(50, 20)
    .setLabel("Precedent");
  ;

  // and add another button
  cp5.addButton("getNext")
    .setValue(0)
    .setPosition(52, height-20)
    .setSize(50, 20)
    .setLabel("Suivant");
  ;

  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'slider' 
  cp5.addSlider("sliderValue")
    .setPosition(104, height-20)
    .setSize(width-106, 20)
    .setRange(0, max(0, diaporama.nomImages.size()-diaporama.nbImgBig))
    ;


  // List all the available serial ports:
  printArray(Serial.list());
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
  // Mise à jour de la grille
  if (millis()-timeMaj > majDiaporama) {
    majGrille();
    timeMaj = millis();
  }
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
    cp5.getController("sliderValue").setMax(max(0, diaporama.nomImages.size()-diaporama.nbImgBig));
  }
}

public void getPrev() {
  if (bRun) { 
    cp5.getController("sliderValue").setValue(sliderValue+1);
  }
}

public void getNext() {
  if (bRun) { 
    //println("### getNext(" + val + ")");
    cp5.getController("sliderValue").setValue(sliderValue-1);
  }
}

void slider(int value) {
  if (bRun) { 
    sliderValue = value;
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      cp5.getController("slider").setValue(sliderValue+1);
    } else if (keyCode == RIGHT) {
      cp5.getController("slider").setValue(sliderValue-1);
    }
    sliderValue = int(cp5.getController("slider").getValue());
  } else if (key == 's') {
    save("gueulomaton_"+repImg+".jpg");
  }
}

// Un message est reçu depuis l'Arduino
void serialEvent(Serial portLu) {
  String message = portLu.readStringUntil('\n'); // On lit le message reçu, jusqu'au saut de ligne
  if (message != null)
  {
    message = trim(message);
    // println(message);

    //look for our 'A' string to start the handshake
    //if it's there, clear the buffer, and send a request for data
    if (message.charAt(0)=='A') {
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
    println("updateCompteur :"+(sliderValue+increment));
    compteur = 0;
    sliderValue += increment;
    cp5.getController("slider").setValue(sliderValue);

  }
}
/*
int compterImages() {
 int nbImg;
 int i;
 nbImg = 0;
 File dir; 
 File [] files;
 dir = new File(repImg);
 files = dir.listFiles();
 if (files == null) {
 println("Le répertoire n'existe pas : "+repImg);
 return 0;
 }
 for (i=0; i <files.length; i++) {
 if (files[i].getAbsolutePath().endsWith("_thumb.jpg")) {
 nbImg++;
 }
 }
 
 return nbImg;
 }
 
 boolean estNouveau(String nomImg) {
 // Teste si l'image est déjà existante ou pas 
 for (int i=0; i<images.size(); i++) {
 if (nomImg.equals(images.get(i).nomThumb)) {
 return false;
 }
 }
 return true;
 }
 
 */