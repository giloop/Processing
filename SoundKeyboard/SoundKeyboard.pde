import ddf.minim.*;

Minim minim;
String soundDir = "sounds";
listeSons mesSons;

void setup()
{
  size(300, 200, P2D);
  // always start Minim before you do anything with it
  minim = new Minim(this);
  // load BD.mp3 from the data folder with a 1024 sample buffer
  // kick = Minim.loadSample("BD.mp3");
  // load BD.mp3 from the data folder, with a 512 sample buffer
  mesSons = new listeSons();
  println(soundDir);
  mesSons.loadSounds(soundDir);
}

void draw()
{
  background(255);
  stroke(0);
  text("Press a key to hear a sound", 10, 20);
}

void keyPressed()
{
  String nomKey = Integer.toString(int(key));
  println(nomKey);
  // Son aléatoire 
  // int idx = (int) random(0,mesSons.mySounds.size());
  // mesSons.mySounds.get(idx).playSound();
  mesSons.playSoundName(nomKey);
}

void stop()
{
  // always close Minim audio classes when you are done with them
  minim.stop();

  super.stop();
}