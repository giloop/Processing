// Constantes de l'application
String repImg = "/home/gilou/Images/FeteRGC2015/";
int thumbWidth  = 216;
int thumbHeight = 384;
int imgWidth    = 720;
int imgHeight   = 1280;
float tRatio = float(thumbHeight)/thumbWidth;

int nbCris;
int idxCri;
boolean bRandom; // défilement dans 

// Grille des vignettes (thumbs)
int space = 2;
int nbLig, nbCol;
int vigW, vigH;
boolean bImgShow;
int timerShow = 3000;
int timerGrille = 5000; // Mise à jour de l'affichage de la grille
int timerNewImg = 10000; // Afichage d'une image 
int timeShow;
int timeGrille;

ArrayList<ImageMover> images;
PImage imgClic;

void setup() {
  size(800, 600); // fullScreen(); //  3840        2160
  ArrayList<String> listeCris = listerImages();
  nbCris = compterImages();

  // Chargement des thumbs
  images = new ArrayList<ImageMover>();
  int i;
  bImgShow = false;
  timeShow = 0;
  timeGrille = 0;
  idxCri = 0;
  bRandom = false;

  // Calcul de la taille des vignettes 
  calculerTailleGrille(nbCris);
  vigH = floor(float(height)/nbLig - space);
  vigW = floor(float(vigH)/tRatio);
  if ((vigW+space)*nbCol > width) {
    // calcul d'abord la largeur (nbLig a été maj)
    vigW = floor(float(width)/nbCol - space);
    vigH = floor(float(vigW)*tRatio);
  }

  println("Chargement des "+nbCris+" vignettes, taille w:"+vigW+", h:"+vigH+", "+nbLig+" lignes, "+nbCol+" colonnes ...");
  for (i=0; i<listeCris.size(); i++) {
    images.add(new ImageMover(listeCris.get(i), vigW, vigH));
  }
  println("OK");

  // Initialisation des timers
  timeShow = millis();
  timeGrille = millis();
}


void draw() {
  background(0);
  int i, l, c;
  for (i=0; i<nbCris; i++) {

    c = i % (nbCol);
    l = (i-c)/(nbCol);
    images.get(i).moveTo(c*(space+images.get(i).larg), l*(space+images.get(i).haut));
    images.get(i).update();
    images.get(i).display();
  }
  if (bImgShow) {
    if (imgClic.width<0) { 
      bImgShow=false;
    } else if (imgClic.width>0) { 
      float scaleFact = max(1, float(imgClic.height)/float(height));
      if (timeShow==-1) { 
        timeShow = millis();
      } // init timer
      if (millis()-timeShow < timerShow) {
        image(imgClic, (width-imgClic.width/scaleFact)/2, (height-imgClic.height/scaleFact)/2, 
          imgClic.width/scaleFact, imgClic.height/scaleFact);
      } else {
        bImgShow=false;
        timeShow = millis();
      }
    }
  } else {
    // Attend timerNewImgms avant de montrer une nouvelle image
    if (millis()-timeShow > timerNewImg) {
      if (bRandom) { 
        showRandomImg();
      } else { 
        showNextImg();
      }
    }
  }
  // Mise à jour de la grille
  if (millis()-timeGrille > timerGrille) {
    majGrille();
    timeGrille = millis();
  }
}

// Calcul de la taille de la grille
void calculerTailleGrille(int nbImg) {
  float tW, tH;
  // Vérification 
  nbLig = 0;
  nbCol = 0;
  while ( (nbLig*nbCol) < nbImg) {
    nbLig++;
    tH = float(height)/nbLig - space;
    tW = tH/tRatio;
    nbCol = floor(float(width)/(tW+space));
    println("nbLig:"+nbLig+", nbCol:"+nbCol+", tH:"+tH+", tW:"+tW);
  }
  // Mise à jour du nombre de lignes 
  nbLig = ceil(float(nbImg) / nbCol);
}

// Mise à jour de la grille
void majGrille() {
  println("Mise à jour des images");
  int nbCrisNew = compterImages();
  if (nbCrisNew==nbCris) {
    println("Pas de nouveau cri");
    return;
  } 

  /* Il y a des nouveraux cris */
  println(nbCrisNew-nbCris+" nouveaux cris");
  // Recharge la liste des cris
  ArrayList<String> arNomImg = listerImages();
  /** Ajoute les nouveaux cris */
  // Calcul de la taille des vignettes
  int nbColOld = nbCol;
  int nbLigOld = nbLig;
  calculerTailleGrille(nbCrisNew);
  vigH = floor(float(height)/nbLig - space);
  vigW = floor(float(vigH)/tRatio);
  if (vigW*nbCol > width) {
    // calcul d'abord la largeur (nbLig a été maj)
    vigW = floor(float(width)/nbCol - space);
    vigH = floor(float(vigW)*tRatio);
  }

  int i;
  for (i=0; i<nbCrisNew; i++) {
    if (estNouveau(arNomImg.get(i))) {
      images.add(new ImageMover(arNomImg.get(i), vigW, vigH));
      images.get(i).img.resize(vigW, vigH);
      images.get(i).larg = vigW;
      images.get(i).haut = vigH;
    } else if ((nbColOld != nbCol) || (nbLigOld != nbLig)) {
      // Resize si nécessaire
      images.get(i).img.resize(vigW, vigH);
      images.get(i).larg = vigW;
      images.get(i).haut = vigH;
    }
  }

  nbCris = nbCrisNew;
}

//  Show image 
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


// Affiche l'image cliquée
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

ArrayList<String> listerImages() {
  ArrayList<String> arNomImg;
  arNomImg = new ArrayList<String>();
  int i;

  File dir; 
  File [] files;
  dir = new File(repImg);
  files = dir.listFiles();
  for (i=0; i <= files.length - 1; i++)
  {
    String path = files[i].getAbsolutePath();
    if (path.endsWith("_thumb.jpg"))
    {
      arNomImg.add(path);
    }
  }

  return arNomImg;
}

int compterImages() {
  int nbImg;
  int i;
  nbImg = 0;
  File dir; 
  File [] files;
  dir = new File(repImg);
  files = dir.listFiles();
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