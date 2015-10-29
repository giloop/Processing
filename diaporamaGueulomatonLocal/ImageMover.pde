/**
 * Image qui bouge
 */

class ImageMover {

  // Position et cible 
  PVector pos;
  PVector posCible;
  PVector vDiff;
  float d;
  float damp;
  // Image 
  String nomThumb;
  String nomImage;

  PImage img;
  int larg, haut;

  // Constructeur de la classe
  ImageMover(String nomVig, int w, int h) {
    // Start in the center
    pos = new PVector(width/2, height/2);
    posCible = new PVector(width/2, height/2);
    d= 0;
    damp = 3;
    larg = w;
    haut = h;

    // Chargement de l'image
    img = new PImage();
    nomThumb = nomVig;
    nomImage = nomVig.replaceFirst("_thumb.jpg", ".jpg");

    img = loadImage(nomThumb);
    img.resize(larg, haut);
  }


  void update() {
    // d = PVector.dist(pos,posCible);
    vDiff = PVector.sub(posCible, pos);
    if ( vDiff.mag() > 1.0) {
      // println("distance:"+vDiff.mag());
      pos.add(vDiff.div(damp));
    }
  }

  void display() {
    if (img==null) {
      rect(pos.x, pos.y, larg, haut);
    } else {
      image(img, pos.x, pos.y);
    }
  }

  void moveTo(float posX, float posY) {
    posCible.x = posX;
    posCible.y = posY;
  }
}