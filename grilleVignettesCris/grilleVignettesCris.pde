

// Constantes de l'application
String repImg   = "FDMTinte2015"; // "jae2015"; // 
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
int timerNewImg = 1000; // Afichage d'une image 
int timeShow;
int timeGrille;
PImage[] imgThumbs;
PImage imgClic;
String nomLocal;

void setup() {
  size(1200, 800);
  jsoNbCris = loadJSONObject(baseUrl+"compterCrisJSON.php?n="+repImg);
  nbCris = jsoNbCris.getInt("nbCris");
  jsaListeCris = loadJSONArray(baseUrl+"listerCrisJSON.php?n="+repImg);
  println(nbCris+" cris dans "+repImg);
  println(dataPath(repImg));
  // Chargement des thumbs
  int i;
  imgThumbs = new PImage[nbCris];
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

  println("Chargement des vignettes, taille w:"+vigW+", h:"+vigH+", "+nbLig+" lignes, "+nbCol+" colonnees ...");
  for (i=0; i<jsaListeCris.size(); i++) {
    String nomImg = jsaListeCris.getJSONObject(i).getString("nom");
    String[] nomParts = split(nomImg, '/');
    String nomLocal2 = repImg+"/"+nomParts[nomParts.length-1]+"_thumb.jpg";
    try {
      imgThumbs[i] = loadImage(nomLocal2);
      // println(i+" : "+nomLocal);
    } 
    catch (Throwable e) {
      e.printStackTrace();
    }
    if (imgThumbs[i] == null) {
      imgThumbs[i] = loadImage(baseUrl+nomImg+"_thumb.jpg");
      imgThumbs[i].save(dataPath(nomLocal2));
      //println(i+" : "+nomImg);
    }

    imgThumbs[i].resize(vigW, vigH);
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
    c = i % (nbCol-1);
    l = (i-c)/(nbCol-1);
    image(imgThumbs[i], c*(space+imgThumbs[i].width), l*(space+imgThumbs[i].height));
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
  }
}

// Calcul de la taille de la grille
void calculerTailleGrille(int nbImg) {
  float tW, tH;
  // Vérification 
  nbLig = 0;
  nbCol = 0;
  while (nbLig * nbCol < nbImg) {
    nbLig++;
    tH = float(height)/nbLig - space;
    tW = tH/tRatio;
    nbCol = floor(float(width)/(tW+space));
    println("nbLig:"+nbLig+", nbCol:"+nbCol+", tH:"+tH+", tW:"+tW);
  }
}

// Mise à jour de la grille
void majGrille() {
  
}

//  Show image 
void showRandomImg() {
  int iImg = floor(random(0, nbCris+1));
  showImg(iImg);
}
void showNextImg() {
  showImg(idxCri++);
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
  }
}