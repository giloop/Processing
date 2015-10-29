

// Constantes de l'application
String repImg   = "qdb2015"; // "gmr2015"; // "jae2015"; // 
String baseUrl  = "http://gueulomaton.org/";
int thumbWidth  = 216;
int thumbHeight = 384;
int imgWidth    = 720;
int imgHeight   = 1280;
float tRatio = float(thumbHeight)/thumbWidth;

// Variables globales
JSONObject jsoNbCris;
JSONArray  jsaListeCris;

int nbCris;
int idxCri;
boolean bRandom; // défilement dans 

// Grille des vignettes (thumbs)
int space = 2;
int nbLig, nbCol;
int vigW, vigH;
boolean bImgShow;
int timerShow = 3000;
int timerGrille = 120000; // Mise à jour de l'affichage de la grille
int timerNewImg = 10000; // Afichage d'une image 
int timeShow;
int timeGrille;
ArrayList<ImageMover> images;
PImage imgClic;
String nomLocal;

void setup() {
  size(1920, 1092); // fullScreen(); //  3840        2160
  jsoNbCris = loadJSONObject(baseUrl+"compterCrisJSON.php?n="+repImg);
  
  nbCris = jsoNbCris.getInt("nbCris");
  jsaListeCris = loadJSONArray(baseUrl+"listerCrisJSON.php?n="+repImg);
  println(nbCris+" cris dans "+repImg);
  println(dataPath(repImg));
  // Chargement des thumbs
  images = new ArrayList<ImageMover>();
  int i;
  bImgShow = false;
  timeShow = 0;
  timeGrille = 0;
  idxCri = 0;
  bRandom = false;
  nomLocal = "";

  // Calcul de la taille des vignettes 
  calculerTailleGrille(nbCris);
  vigH = floor(float(height)/nbLig - space);
  vigW = floor(float(vigH)/tRatio);
  if (vigW*nbCol > width) {
    // calcul d'abord la largeur (nbLig a été maj)
    vigW = floor(float(width)/nbCol - space);
    vigH = floor(float(vigW)*tRatio);
  }

  println("Chargement des vignettes, taille w:"+vigW+", h:"+vigH+", "+nbLig+" lignes, "+nbCol+" colonnees ...");
  for (i=0; i<jsaListeCris.size(); i++) {
    String nomImg = jsaListeCris.getJSONObject(i).getString("nom");
    images.add(new ImageMover(nomImg, vigW, vigH));
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
        // Sauvegarde en local
        if (nomLocal.length()>0) {
          println(" Sauvegarde dans : "+dataPath(nomLocal));
          imgClic.save(dataPath(nomLocal));
          nomLocal = "";
        }
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
  jsoNbCris = loadJSONObject(baseUrl+"compterCrisJSON.php?n="+repImg);
  int nbCrisNew = jsoNbCris.getInt("nbCris");
  if (nbCrisNew==nbCris) {
    println("Pas de nouveau cri");
    return;
  } 
  
  println(nbCrisNew-nbCris+" nouveaux cris");
  // Recharge la liste des cris
  jsaListeCris = loadJSONArray(baseUrl+"listerCrisJSON.php?n="+repImg);
  println(nbCris+" cris dans "+repImg);
  // Ajoute les nouveaux cris
  // Calcul de la taille des vignettes 
  calculerTailleGrille(nbCrisNew);
  vigH = floor(float(height)/nbLig - space);
  vigW = floor(float(vigH)/tRatio);
  if (vigW*nbCol > width) {
    // calcul d'abord la largeur (nbLig a été maj)
    vigW = floor(float(width)/nbCol - space);
    vigH = floor(float(vigW)*tRatio);
  }

  int i;
  for (i=0; i<nbCrisNew-nbCris; i++) {
    String nomImg = jsaListeCris.getJSONObject(i).getString("nom");
    images.add(new ImageMover(nomImg, vigW, vigH));
  }
  for (i=nbCrisNew-nbCris; i<nbCris; i++) {
    images.get(i).img.resize(vigW, vigH);
    images.get(i).larg = vigW;
    images.get(i).haut = vigH;
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
  String nomImg = jsaListeCris.getJSONObject(idx).getString("nom");
  println(idx+": récupération de "+nomImg);
  String[] nomParts = split(nomImg, '/');
  nomLocal = repImg+"/"+nomParts[nomParts.length-1]+".jpg";
  imgClic = loadImage(dataPath(nomLocal));
  if (imgClic == null) {
    imgClic = requestImage(baseUrl+nomImg+".jpg");
  } else {
    nomLocal = ""; // Pour ne pas resauver l'image affichée en local
  }
  println(idx+", nom local :"+ nomLocal);

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