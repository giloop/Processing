/**
 * Acceleration with Vectors 
 * by Daniel Shiffman.  
 * 
 * Demonstration of the basics of motion with vector.
 * A "Mover" object stores location, velocity, and acceleration as vectors
 * The motion is controlled by affecting the acceleration (in this case towards the mouse)
 */


class Mover {

  // The Mover tracks location, velocity, and acceleration 
  PVector pos;
  PVector posCible;
  PVector vDiff;
  float d;
  float damp;
  
  Mover() {
    // Start in the center
    pos = new PVector(width/2,height/2);
    posCible = new PVector(width/2,height/2);
    d= 0;
    damp = 3;
  }

  void update() {
    // d = PVector.dist(pos,posCible);
    vDiff = PVector.sub(posCible, pos);
    if ( vDiff.mag() > 1.0) {
      println("distance:"+vDiff.mag());
      pos.add(vDiff.div(damp));
    } 
  }

  void display() {
    stroke(255);
    strokeWeight(2);
    fill(127);
    ellipse(pos.x,pos.y,48,48);
  }

  void moveTo(float posX, float posY) {
    posCible.x = posX;
    posCible.y = posY;
  }
}