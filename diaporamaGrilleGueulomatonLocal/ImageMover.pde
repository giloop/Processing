/**
 * Image qui bouge
 */

class ImageMover {

  // Position et cible 
  PVector pos;
  PVector posCible;
  PVector size;
  PVector sizeCible;
  PVector vDiff;
  float d;
  float damp;
  // Image 
  String nomThumb;
  String nomImage;
  String dateFull;
  String dateTxt;
  
  PImage img;

  // Constructeur de la classe
  ImageMover(String nomVig, int w, int h) {
    // Start in the center
    pos = new PVector(width/2, height/2);
    posCible = new PVector(width/2, height/2);
    d= 0;
    damp = 3;
    size = new PVector(w, h);
    sizeCible = new PVector(w, h);

    // Chargement de l'image
    img = new PImage();
    nomThumb = nomVig;
    nomImage = nomVig.replaceFirst("_thumb.jpg", ".jpg");
    // Récupération de la date
    String[] nomParts = split(nomThumb, pathSep);
    dateFull = nomParts[nomParts.length-1].substring(5);
    dateTxt = dateFull.substring(11,13) + "h" + dateFull.substring(14,16) + 
    ", le "+ dateFull.substring(8,10) + "/" +dateFull.substring(5,7) + "/" + dateFull.substring(0,4);
    
    // Chargement de l'image (vignette)
    img = loadImage(nomThumb);
    img.resize(int(size.x), int(size.y));
  }


  void update() {
    // d = PVector.dist(pos,posCible);
    // Move
    vDiff = PVector.sub(posCible, pos);
    if ( vDiff.mag() > 1.0) {
      // println("distance:"+vDiff.mag());
      pos.add(vDiff.div(damp));
    }
    /* Resize
     vDiff = PVector.sub(sizeCible, size);
     if ( vDiff.mag() > 1.0) {
     // println("distance:"+vDiff.mag());
     size.add(vDiff.div(damp));
     }*/
  }

  void display() {
    if (img==null) {
      rect(pos.x, pos.y, size.x, size.y);
    } else {
      image(img, pos.x, pos.y);
      fill(255);
      text(dateTxt, pos.x, img.height+pos.y-9, size.x, 9); 
    }
  }

  void moveTo(float posX, float posY) {
    posCible.x = posX;
    posCible.y = posY;
  }

  void moveTo(float posX, float posY, float sizeX, float sizeY) {
    posCible.x = posX;
    posCible.y = posY;
    // Reload & resize if necessary (once)
    if ((size.x!=sizeX) && (size.y!=sizeY)) {
      img = loadImage(nomThumb);
      img.resize(int(sizeX), int(sizeY));
      size.x = sizeX;
      size.y = sizeY;
    }
  }
}