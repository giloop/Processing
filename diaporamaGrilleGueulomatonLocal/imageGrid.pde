/**
 * Grille d'image
 */


class imageGrid {
  // Paramètre de la grille
  int nbLig1 = 2;
  int nbCol1 = 3;
  int nbSkip = nbLig1*nbCol1;
  int space = 2;
  // Paramètres des vignettes
  int tW = 216;
  int tH = 384;
  float tRatio;

  float h1;
  float w1; 
  int nbCol2;
  int nbCol3;
  int nbImg;

  // liste des noms des images
  String repImages;
  ArrayList<String> nomImages;
  int currentIdx;
  ArrayList<ImageMover> pimages;
  // Constructeur
  imageGrid(String nomRepImages) {
    repImages = nomRepImages;
    nomImages = new ArrayList<String>();
    listerImages();
    calculerPosGrille();

    pimages = new ArrayList<ImageMover>();
    for (int i=0; i<min(nbImg, nomImages.size()); i++) {
      // println("ImageMover : "+nomImages.get(i));
      pimages.add(new ImageMover(nomImages.get(i), int(w1), int(h1)));
    }

    currentIdx = pimages.size();
  }

  void calculerPosGrille() {
    // Mise a jour h, w et nbCol
    h1 = (height-space*(nbLig1+1))/(nbLig1);
    tRatio = float(tH)/tW;
    w1 = h1/tRatio;

    // Calcul de l'espace restant pour des demis images 
    nbCol2 = ceil((width-(space+w1)*(nbCol1))/(0.5*w1+space));
    // Nombre d'images totale dans la grille en fonction de la taille de l'écran
    nbImg = nbLig1*nbCol1 + 2*nbCol2*nbLig1;
    println("La grille contient " + nbImg+" images, (nbCol2="+nbCol2+")");
  }

  void display() {
    for (int i=0; i<pimages.size(); i++) {
      pimages.get(i).update();
      pimages.get(i).display();
    }
  }

  void update() {
    int c;
    int l;
    int idx = 0;
    // Images de taille h1,w1
    for (l=1; l<=nbLig1; l++) {
      for (c=1; c<=nbCol1; c++) {
        // Positionne l'image
        pimages.get(idx++).moveTo(width-(w1+space)*c, height-(h1+space)*l, w1, h1);
        // Arret si plus d'images à afficher
        if (idx>=pimages.size()) { 
          return;
        }
      }
    }
    // Images de taille h1/2,w1/2
    int xOffset = width-floor((w1+space)*nbCol1);
    for (l=1; l<=nbLig1*2; l++) {
      for (c=1; c<=nbCol2; c++) {
        pimages.get(idx++).moveTo(xOffset-(w1*0.5+space)*c, height-(h1*0.5+space)*l, w1*0.5, h1*0.5);
        // Arret si plus d'images à afficher
        if (idx>=pimages.size()) { 
          return;
        }
      }
    }
  }

  void getPrev() {
    if (currentIdx<=pimages.size()) {
      println("Premiere image atteinte");
      return;
    }
    currentIdx--;
    println("ImageMover : "+nomImages.get(currentIdx-pimages.size()));
    pimages.add(0, new ImageMover(nomImages.get(currentIdx-pimages.size()), int(w1), int(h1)));
    if (pimages.size()==nbImg) {
      pimages.remove(pimages.size()-1);
    }
  }

  void getNext() {
    if (pimages.size()>nbCol1*nbLig1) {
      pimages.remove(0);
    }
    println("ImageMover : "+nomImages.get(currentIdx));
    if (currentIdx<nomImages.size()) {
      pimages.add(pimages.size(), new ImageMover(nomImages.get(currentIdx), int(w1), int(h1)));
      currentIdx++;
    }
  }

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
    Collections.sort(nomImages);
    /*for (int i=0; i<nomImages.size(); i++) {
      println(i+" : "+nomImages.get(i));
    } */
    println(nomImages.size()+" images trouvées");
  }
}