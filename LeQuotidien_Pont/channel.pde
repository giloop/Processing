class Channel
{
  color SILENT_COLOR = color(150);
  color SOLO_COLOR = color(255,215,0);
  color MUTE_COLOR = color(135,206,250);
  color GROUP_COLOR = color(255);
 String name;
 AudioPlayer in;
 BandGainEffect effect;
 FFT fft;
 Band[] bands;
 int posX, posY; 
 float pan, gain;
 
 int markerRadius = 13;
 int centreRadius = 9;
 color baseColor;
 boolean isMute, isSolo, isSilent; // different states
 int group = 0; // grouping
 
 Channel(String nm, AudioPlayer p, float[][] freqBands, color c)
 {
  name = nm;
  in = p;
  baseColor = c;
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
  int specSize = fft.specSize();
  
  // create the bands
  int n = freqBands.length;
  bands = new Band[n];
  float radiansInBand = TWO_PI/n;
  //color bandColor = color(red(baseColor),green(baseColor),blue(baseColor), 50);
  for (int i = 0; i < n; i++) {
    float lowBand = freqBands[i][0];
    float highBand = freqBands[i][1];
    float startRadians = i * radiansInBand + HALF_PI;
    float stopRadians = (i+1) * radiansInBand + HALF_PI;
    println("creating Band with band indices " + lowBand + ":" + highBand + " and radian range " + startRadians + ":" + stopRadians);
    color bandColor = color(red(baseColor),green(baseColor),blue(baseColor), 50 + (n-i-1) * (205 / n));
    color backColor = color(red(baseColor),green(baseColor),blue(baseColor), 50);
    bands[i] = new Band(fft, freqBands[i][0], freqBands[i][1], startRadians, stopRadians, bandColor, backColor, baseColor, this); 
  }
  FFT efft = new FFT(in.bufferSize(), in.sampleRate());
  effect = new BandGainEffect(efft, bands);
  in.addEffect(effect);
 }
 
 void move(int a, int b)
 {
   posX = a;
   posY = b; 
   pan = map(posX, 0, width, -1, 1); 
   gain = map(posY, 0, height, 6, -18);
   in.setPan(pan);
   if (!isSilent) in.setGain(gain);
 }
 
 void draw()
 {
   fft.forward(in.mix);
   //println("current position = " + posX + " : " + posY);
   // draw cross hairs
   strokeWeight (0.3);
   stroke(baseColor);
   line(posX, 0, posX, height);
   line(0, posY, width, posY);
   
   // draw bands
   pushMatrix(); 
   translate(posX, posY);
   for (int i = 0; i < bands.length; i++) {
     //println("draw band [" + i + "] for channel " + name);
     bands[i].draw(); 
   }
   
   
   // mute/solo indicator
   ellipseMode(RADIUS);
   if (isMute)
     fill(MUTE_COLOR);
   else if (isSolo)
     fill(SOLO_COLOR);
   else
     fill(baseColor);
   noStroke();
   ellipse(0,0,markerRadius,markerRadius); 
   
   // draw marker
   ellipseMode(RADIUS);
   noStroke();
   if (!isSilent)
     fill(baseColor);
   else
     fill(SILENT_COLOR);
   ellipse(0,0,centreRadius,centreRadius); 
   
   textAlign(CENTER, CENTER);
   strokeWeight (0.5);
   if (group != 0) {
     fill(GROUP_COLOR);
     text(group, 0, -2);
   }
   fill(baseColor);
   textAlign(LEFT, BASELINE);
   text(name, 10, -10);
   
   popMatrix();
 }
 
 void shutUp() {
   in.setGain(-60);
   isSilent = true;
 }
 
 void speakUp() {
   in.setGain(gain);
   isSilent = false;
 }

 boolean isOverMarker(int x, int y)
 {
   boolean over = sqrt(sq(x-posX)+sq(y-posY))<=(markerRadius  + 10);
   //println("isOver test " + posX + " : " + posY + "   " + x + " : " + y + "    " + over + "   " + rad);
   return over;
 }
 
 Band isOverBand(int x, int y)
 {
   //int col = get(x,y);
   float angle = 0f;
   float oX = x-posX;
   float oY = y-posY;
   if (oX > 0 && oY >= 0)
     angle = atan(oY/oX) + PI + HALF_PI;
   else if (oX <= 0 && oY > 0)
     angle = atan(abs(oX)/oY);
   else if (oX < 0 && oY <= 0)
     angle = atan(abs(oY)/abs(oX)) + HALF_PI;
   else if (oX >= 0 && oY < 0)
     angle = atan(oX/abs(oY)) + PI;
   else
     return null;
   angle += HALF_PI;
   for (int i = 0; i < bands.length; i++) {
      if (bands[i].isOver(x-posX, y-posY, angle)) return bands[i];
   }
   return null;
 }
}
