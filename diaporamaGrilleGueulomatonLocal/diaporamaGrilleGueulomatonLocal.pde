import controlP5.*;
import java.util.Collections;

// Constantes de l'application
// String repImg = "/home/gilou/Images/FeteRGC2015/";
// String repImg = "M:\\Processing 3 - Sketchbook\\diaporamaGrilleGueulomatonLocal\\data\\FDMTinte2015";
String repImg = "F:\\Sketchbook-3.0\\diaporamaGrilleGueulomatonLocal\\data\\FDMTinte2015";

imageGrid diaporama;
ControlP5 cp5;
PFont f;

void setup() {
  size(800, 600); // fullScreen(); //  3840        2160
  f = createFont("Calibri", 10);
  textFont(f);

  diaporama = new imageGrid(repImg);
  cp5 = new ControlP5(this);

  // create a new button with name 'buttonA'
  cp5.addButton("getPrev")
    .setValue(0)
    .setPosition(0,height-50)
    .setSize(50, 50)
    .setLabel("Precedent");
    ;

  // and add another button
  cp5.addBang("getNext")
    .setValue(0)
    .setPosition(0,height-150)
    .setSize(50, 50)
    .setLabel("Suivant");
    ;

}


void draw() {
  background(0);
  diaporama.update();
  diaporama.display();
}

public void getPrev(int val) {
  //println("### getPrev(" + val + ")");
  diaporama.getPrev();
}
public void getNext(int val) {
  //println("### getNext(" + val + ")");
  diaporama.getNext();
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
 
 void keyReleased() {
 if (key == 'r') {
 bRandom = !bRandom;
 } else if (key == 's') {
 save("gueulomaton_"+repImg+".jpg");
 }
 }
 */
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