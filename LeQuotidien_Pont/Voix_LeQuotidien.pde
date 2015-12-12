/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/56341*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */


import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;

/* freq bands
LF= 0-150
LM=150-1k
HM=1k-7k
HF=7k-20k
*/
float[][] FREQUENCY_BANDS = { {0,150},{150,500},{500,2000},{2000,7000},{7000,20000}};
//float[][] FREQUENCY_BANDS = { {0,1000},{1000,4000},{4000,20000}};
int BUFFER_SIZE = 2048;
String[] TRACK_FILENAMES = {  "voix 1", "batterie", "guitare", "voix 2"};

Channels channels;

// variables for zooming and dragging
Band dragBand;
Channel dragChannel;
int offsetX, offsetY;
int zoomScale = 1;
int zoomMx, zoomMy;
int shiftX, shiftY, baseX, baseY;

color bgColor = color(251,251,251);
color fromColor = color(204, 102, 0);
color toColor = color(0, 102, 153);

void setup()
{
  size(900, 400);
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
  }}); 
  smooth();
  initSound();
}

void initSound()
{
  channels = new Channels(FREQUENCY_BANDS, BUFFER_SIZE, TRACK_FILENAMES, this);
  channels.togglePlay();
}


void draw()
{
  translate(zoomMx, zoomMy);
  scale(zoomScale); 
  translate(-zoomMx, -zoomMy);
  background(bgColor);
  channels.draw();
}

void stop()
{
  channels.stopPlaying();
  super.stop();
}

void mousePressed() {
  if (zoomScale != 1) return;
  //println("mouse pressed: " + mouseX + "," + mouseY);
  Channel clickedChannel = channels.getChannel(mouseX, mouseY);
  Band clickedBand = null;
  if (clickedChannel == null)
    clickedBand = channels.getBand(mouseX, mouseY);
  
  if (mouseButton == LEFT) {
    if (clickedChannel != null) {
      boolean cancelDrag = true;
      if (keyPressed)
      {
        println("clicked on channel: " + clickedChannel.name);
        if (key == 'm' || key == 'M') {
          println("toggle channel mute: " + clickedChannel.name);
          channels.toggleMute(clickedChannel);
        } else if (key == 's' || key == 'S') {
          println("toggle channel solo: " + clickedChannel.name);
          channels.toggleSolo(clickedChannel);
        } else if (key == 'b' || key == 'B') {
          println("toggle channel bypass: " + clickedChannel.name);
          channels.toggleBypass(clickedChannel);
        } else if ("1234567890".indexOf(key) != -1) {
          println("toggle channel " + clickedChannel.name + " in group " + key);
          channels.toggleGroup(clickedChannel, int(str(key)));
        } else
         cancelDrag = false;
      } else
        cancelDrag = false;
      if (!cancelDrag) {  // dragging
        //println("clicked on channel: " + clickedChannel.name);
        offsetX = clickedChannel.posX-mouseX;
        offsetY = clickedChannel.posY-mouseY;
        dragChannel = clickedChannel;
      }
    }
    else
    {
      dragBand = clickedBand;
    }
  } else if (mouseButton == RIGHT) { // right click means reset eq band(s)
    if (clickedChannel != null) {
      println("reset channel  ");
      for (int i = 0; i < clickedChannel.bands.length; i++) {
        clickedChannel.bands[i].resetGainRadius();
      }
    } else {
      if (clickedBand != null) 
      {
        println("reset band  " + clickedBand.getGain());
        clickedBand.resetGainRadius();
      } else {
       
      }
    }
  } else {

  }
} 

// use space-bar to pause and restart
void keyPressed() {
  if (key == ' ') channels.togglePlay();
}

void mouseReleased() {
  dragChannel = null;
  dragBand = null;
}

void mouseDragged() 
{
  if (dragChannel != null) {
    int x = max(0, min(mouseX+offsetX, width));
    int y = max(0, min(mouseY+offsetY, height));
    boolean ignore_group = keyPressed && (key == CODED) && (keyCode == CONTROL);
    channels.move(dragChannel, x, y, ignore_group);
  }
  if (dragBand != null)
  {
    //println("Band radius: " + dragBand.gainRadius + "  channel centre position: " + dragBand.parentChannel.posX + ":" + dragBand.parentChannel.posY);
    dragBand.setGainRadius(dist(dragBand.parentChannel.posX, dragBand.parentChannel.posY, mouseX, mouseY));
  }
}

void mouseWheel(int delta) {
  zoomMx = mouseX;
  zoomMy = mouseY;
  zoomScale -= delta;
  if (zoomScale < 1) zoomScale = 1;
  else if (zoomScale > 8) zoomScale = 8;
  println("zoom: " + zoomScale + ", " + delta + ", " + zoomMx + ", " + zoomMy);
}


