/**
 * Grille d'image
 */


class imageGrid {
  // Paramètre de la grille
  int wGrid;
  int hGrid;
  int nbLig1 = 2;
  int nbCol1 = 3;
  float h1;
  float w1; 
  int nbCol2;
  int nbImg;
  int nbImgBig = nbLig1*nbCol1;
  int space = 2;
  // Paramètres des vignettes
  int tW = 216;
  int tH = 384;
  float tRatio;


  // liste des noms des images
  String repImages;
  ArrayList<String> nomImages;
  int currentIdx;
  ArrayList<ImageMover> pimages;

  /** Constructeur */
  imageGrid(String nomRepImages, int gridWidth, int gridHeight) {
    repImages = nomRepImages;
    nomImages = new ArrayList<String>();
    wGrid = gridWidth;
    hGrid = gridHeight;
    listerImages();
    calculerPosGrille();

    pimages = new ArrayList<ImageMover>();
    for (int i=0; i<min(nbImg, nomImages.size()); i++) {
      // println("ImageMover : "+nomImages.get(i));
      pimages.add(new ImageMover(nomImages.get(i), int(w1), int(h1)));
    }

    currentIdx = 0;
  }

  /* Recharge le diaporama et renvoie true si de nouvelles images ont été trouvées */ 
  boolean reload() {
    int nbOld = nomImages.size();

    listerImages();
    if (nbOld == nomImages.size()) { return false; }
    
    calculerPosGrille();

    pimages.clear(); // = new ArrayList<ImageMover>();
    for (int i=0; i<min(nbImg, nomImages.size()); i++) {
      // println("ImageMover : "+nomImages.get(i));
      pimages.add(new ImageMover(nomImages.get(i), int(w1), int(h1)));
    }

    currentIdx = 0;
     return true; 
  }
  
  /* Calcule les dimensions des images dans la grille */
  void calculerPosGrille() {
    // Mise a jour h, w et nbCol
    h1 = (hGrid-space*(nbLig1+1))/(nbLig1);
    tRatio = float(tH)/tW;
    w1 = h1/tRatio;

    // Calcul de l'espace restant pour des demis images 
    nbCol2 = floor((wGrid-(space+w1)*(nbCol1))/(0.5*w1+space));
    // Nombre d'images totale dans la grille en fonction de la taille de l'écran
    nbImg = nbLig1*nbCol1 + 2*nbCol2*nbLig1;
    println("La grille contient " + nbImg+" images, (nbCol2="+nbCol2+")");
  }

  /* Affiche les images */
  void display() {
    for (int i=0; i<pimages.size(); i++) {
      pimages.get(i).update();
      pimages.get(i).display();
    }
  }

  /* Mise à jour de la position des images (grille et mouvements) */
  void update() {
    int c;
    int l;
    int idx = 0;
    // Images de taille h1,w1
    for (l=1; l<=nbLig1; l++) {
      for (c=1; c<=nbCol1; c++) {
        // Positionne l'image
        pimages.get(idx++).moveTo(wGrid-(w1+space)*c, hGrid-(h1+space)*l, w1, h1);
        // Arret si plus d'images à afficher
        if (idx>=pimages.size()) { 
          return;
        }
      }
    }
    // Images de taille h1/2,w1/2
    int xOffset = wGrid-floor((w1+space)*nbCol1);
    for (l=1; l<=nbLig1*2; l++) {
      for (c=1; c<=nbCol2; c++) {
        pimages.get(idx++).moveTo(xOffset-(w1*0.5+space)*c, hGrid-(h1*0.5+space)*l, w1*0.5, h1*0.5);
        // Arret si plus d'images à afficher
        if (idx>=pimages.size()) { 
          return;
        }
      }
    }
  }

  /* Passe à l'image précédente */
  int getPrev() {
    println("imageGrid.getPrev()");
    if (currentIdx>=nomImages.size()-nbImgBig) {
      println("Premières images affichées en grand");
    } else { 
      currentIdx++;
      int idxAjout = currentIdx + pimages.size(); 
      if (idxAjout<nomImages.size()) {
        println("ajout de "+nomImages.get(idxAjout)+" a la fin de ArrayList");
        pimages.add(pimages.size(), new ImageMover(nomImages.get(idxAjout), int(w1), int(h1)));
      }
      if (pimages.size()>nbImgBig) {
        println("suppression de la première image");
        pimages.remove(0);
      }
    }
    println("getPrev() : currentIdx = "+currentIdx);
    return currentIdx;
  }

  /* Passe à l'image suivante */
  int getNext() {
    println("imageGrid.getNext()");
    if (currentIdx==0) { 
      println("Derniere image atteinte");
    } else { 
      currentIdx--;
      int idxAjout = currentIdx;
      if (idxAjout < nomImages.size()) {
        println("ajout de "+nomImages.get(idxAjout)+" au début");
        pimages.add(0, new ImageMover(nomImages.get(idxAjout), int(w1), int(h1)));
      }
      if (pimages.size()>nbImg) {
        println("suppression derniere image");
        pimages.remove(pimages.size()-1);
      }
    }
    return currentIdx;
  }

  /* rempli nomImages, liste des images du dossier */
  void listerImages() {
    nomImages.clear();

    File dir; 
    File [] files;
    dir = new File(repImages);
    files = dir.listFiles();
    if (files == null) {
      println("Le répertoire n'existe pas : "+repImages);
      return;
    }

    println("Listing des images du répertoire : "+repImages);
    for (int i=0; i <= files.length - 1; i++)
    {
      String path = files[i].getAbsolutePath();
      if (path.endsWith("_thumb.jpg"))
      {
        nomImages.add(path);
      }
    }
    Collections.sort(nomImages, Collections.reverseOrder());
    /*for (int i=0; i<nomImages.size(); i++) {
     println(i+" : "+nomImages.get(i));
     } */
    println(nomImages.size()+" images trouvées");
  }

} // End of Class ImageGrid