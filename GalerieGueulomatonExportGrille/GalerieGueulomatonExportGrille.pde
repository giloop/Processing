/** Programme pour générer une planche contact des JPEG photos du Gueulomaton
 * La forme de la grille (nbLigne, nbColonne) est calculée en fonction du nombre de photos 
 * dans la galerie. 
 * Le sketch n'est exécuté qu'une fois.  
 * Les photos sont téléchargées en local la première fois. 
 * Paramétrage: 
 * - repImg   : nom de la galerie tel que sur le site
 * - spaceMin : especement minimum des photos 
 * - setup()  : la taille du canvas fixe la résolution de l'image JPG 
 *
 * Codage : gilles.gonon@gueulomaton.org - @giloop
 */

// Constantes de l'application
String repImg   = "adp16"; // "fred44"; // "FDMTinte2015"; // "jae2015"; // 
String baseUrl  = "http://gueulomaton.org/";
int thumbWidth  = 216;
int thumbHeight = 384;
int imgWidth    = 720;
int imgHeight   = 1280;
float tRatio = float(thumbWidth)/thumbHeight;
float imgRatio;

// Variables globales
JSONObject jsoNbCris;
JSONArray  jsaListeCris;

int nbCris;
int idxCri;
boolean bRandom; // défilement dans 

// Grille des vignettes (thumbs)
int spaceMin = 4;   // espacement minimum entre les vignettes
int spaceW, spaceH;
int nbLig, nbCol;
int vigW, vigH;
boolean bImgShow;
PImage[] imgThumbs;
PImage imgClic;
String nomLocal;

void setup() {
  // Choix de la taille en pixel
  // A3: (4961, 3508)
  size(4961, 3508);
  // size(3000, 4000); 
  imgRatio = float(width)/height;
  // Appel API gueulomaton
  jsoNbCris = loadJSONObject(baseUrl+"compterCrisJSON.php?n="+repImg);
  nbCris = jsoNbCris.getInt("nbCris");
  jsaListeCris = loadJSONArray(baseUrl+"listerCrisJSON.php?n="+repImg);
  println(nbCris+" cris dans "+repImg);
  println(dataPath(repImg));
  
  // Chargement des images de la galerie (rajouter _thumbs pour les vignettes)
  int i;
  imgThumbs = new PImage[nbCris];
  bImgShow = false;
  idxCri = 0;
  bRandom = false;
  nomLocal = "";

  // Calcul de la taille des vignettes 
  calculerTailleGrille(nbCris);
  
  println("Chargement des vignettes, taille w:"+vigW+", h:"+vigH+", "+nbLig+" lignes, "+nbCol+" colonnees ...");
  println("spaceW:"+spaceW+", spaceH:"+spaceH);

  for (i=0; i<jsaListeCris.size(); i++) {
    String nomImg = jsaListeCris.getJSONObject(i).getString("nom");
    String[] nomParts = split(nomImg, '/');
    String nomLocal2 = repImg+"/"+nomParts[nomParts.length-1]+".jpg";
    try {
      imgThumbs[i] = loadImage(nomLocal2);
      // println(i+" : "+nomLocal);
    } 
    catch (Throwable e) {
      e.printStackTrace();
    }
    if (imgThumbs[i] == null) {
      imgThumbs[i] = loadImage(baseUrl+nomImg+".jpg");
      imgThumbs[i].save(dataPath(nomLocal2));
      //println(i+" : "+nomImg);
    }

    imgThumbs[i].resize(vigW, vigH);
  }
  println("imgThumb size ["+imgThumbs[0].width+","+imgThumbs[0].height+"]");
  println("OK");
  
}


void draw() {
  background(255);
  int i, l, c;
  // Recalcule l'espace possible entre les images
  for (i=0; i<nbCris; i++) {
    c = i % (nbCol);
    l = (i-c)/(nbCol);
    image(imgThumbs[i], (c+1)*spaceW+c*imgThumbs[i].width, (l+1)*spaceH+l*imgThumbs[i].height);
    // println("img["+i+"/"+nbCris+"], lig:"+l+", col:"+c);
  }
  
  saveFrame("Grille_"+repImg+".jpg");
  delay(1000);
  exit();
}

// Calcul de la taille de la grille
void calculerTailleGrille(int nbImg) {
  float tW, tH;
  nbCol = ceil(sqrt(nbImg*imgRatio/tRatio));
  nbLig = ceil(float(nbImg)/nbCol);
  tH = floor(float(height)/nbLig);
  tW = tH*tRatio;
  println("nbLig:"+nbLig+", nbCol:"+nbCol+", tH:"+tH+", tW:"+tW);

  // Ratio de la grille pour voir dans quel sens redimensionner
  float grilleRatio = nbCol/nbLig * tRatio;
  if (grilleRatio > imgRatio) {
    vigH = floor(float(height-spaceMin*(nbLig+1))/(nbLig+1));
    vigW = floor(float(vigH)*tRatio);
  } else {
    vigW = floor(float(width-spaceMin*(nbCol+1))/(nbCol+1));
    vigH = floor(float(vigW)/tRatio);
  }
  // Calcul des espaces
  spaceW = floor(float(width-(nbCol*vigW)) / (nbCol+1));
  spaceH = floor(float(height-(nbLig*vigH)) / (nbLig+1));

}