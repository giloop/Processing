import controlP5.*;
import java.util.Collections;
import processing.serial.*;
import cc.arduino.*;
import java.lang.*; 

Arduino myArduino;
boolean bArduino;
// Constantes de l'application
String repImg = "/home/gilou/Images/fred44/"; // FeteRGC2015/";
// String repImg = "M:\\Processing 3 - Sketchbook\\diaporamaGrilleGueulomatonLocal\\data\\FDMTinte2015";
// String repImg = "F:\\Sketchbook-3.0\\diaporamaGrilleGueulomatonLocal\\data\\FDMTinte2015";
char pathSep;

imageGrid diaporama;
ControlP5 cp5;
int sliderValue = 0;
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

  size(820, 600); // fullScreen(); //  3840        2160
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
  cp5.addSlider("slider")
    .setPosition(104, height-20)
    .setSize(width-106, 20)
    .setRange(0, max(0,diaporama.nomImages.size()-diaporama.nbImgBig))
    ;
    
    
  try {
    myArduino = new Arduino(this, Arduino.list()[0], 57600);
    // Set the Arduino digital pins as inputs.
    myArduino.pinMode(0, Arduino.INPUT);
    bArduino = true;
  } 
  catch (Exception e) {
    e.printStackTrace();
    bArduino = false;
  }
   
  // Initialisation des timers
  timeMaj = millis();

  bRun = true;
}


void draw() {
  background(0);
  if (bArduino) {
    sliderValue = int( myArduino.analogRead(0) * diaporama.nomImages.size() / 1023.0) ;
    cp5.getController("slider").setValue(sliderValue);
  } 
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
    cp5.getController("slider").setMax(max(0,diaporama.nomImages.size()-diaporama.nbImgBig));
  } 
}

public void getPrev() {
  if (bRun) { 
      cp5.getController("slider").setValue(sliderValue+1);
  }
}

public void getNext() {
  if (bRun) { 
    //println("### getNext(" + val + ")");
    cp5.getController("slider").setValue(sliderValue-1);
  }
}

void slider(int value) {
  if (bRun) { sliderValue = value; }
}

/* Show image 
 void showRandomImg() {
 int iImg = floor(random(0, nbCris+1));
 showImg(iImg);
 }
 void showNextImg() {
 showImg(idxCri++);
 if (idxCri>=nbCris) { 
 idxCri =0;
 }
 }
 
 void showImg(int idx) {
 println(idx+": récupération de "+images.get(idx).nomImage);
 imgClic = loadImage(images.get(idx).nomImage);
 
 bImgShow = true;
 timeShow = -1;
 }
 */

/* Affiche l'image cliquée
 void mouseReleased() {
 if (bImgShow) { 
 return;
 }
 
 // Récupération de l'indice de la photo cliquée
 int c = floor(mouseX/(vigW+space));
 int l = floor(mouseY/(vigH+space));
 println("Clic ligne "+l+", colonne "+c);
 int i = c+l*nbCol;
 if (i<nbCris) {
 showImg(i);
 } else {
 println(i+": indice hors tableau !!!");
 }
 }
 */

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      cp5.getController("slider").setValue(sliderValue+1);

    } else if (keyCode == RIGHT) {
      cp5.getController("slider").setValue(sliderValue-1);
    }
  } else if (key == 's') {
    save("gueulomaton_"+repImg+".jpg");
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