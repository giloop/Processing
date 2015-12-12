import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;

class Channels
{
  AudioPlayer[] in;
  Minim[] minim;
  Channel[] channels;
  
  Channels(float[][] frequency_bands, int buffer_size, String[] track_filenames, PApplet papplet)
  {
    int n = track_filenames.length;
    minim = new Minim[n];
    in = new AudioPlayer[n];
    channels = new Channel[n];
  
    for (int i = 0; i < n; i++) {
      minim[i] = new Minim(papplet);
      println("Loading channel [" + i + "] with file: " + track_filenames[i]);
      in[i] = minim[i].loadFile(track_filenames[i] + ".mp3", BUFFER_SIZE);
    
      //float[][] freqBands = calcFrequencyBands(n, in[i].sampleRate());
  
      color channelColor;
      if (n <= 1)
        channelColor = fromColor;
      else
        channelColor = lerpColor(fromColor, toColor, i * 1.0 / (n - 1));
        
      channels[i] = new Channel(track_filenames[i], in[i], frequency_bands, channelColor);
      channels[i].move((i+1)*width/(n+1), height/2);
    }
  }
  
  void togglePlay() {
    if (in[0].isPlaying())
      pauseAll();
    else
      playAll();
  }
  
  void playAll() {
    for (int i = 0; i < in.length; i++) {
      in[i].play();
      in[i].loop();
    }  
  }

  void pauseAll() {
    for (int i = 0; i < in.length; i++) {
      in[i].pause();
    }  
  }
  
  void stopPlaying()
  {
    for (int i = 0; i < channels.length; i++) {
      in[i].close();
      minim[i].stop();
    }
  }
  
  float[][] calcFrequencyBands(int n, float sampleRate)
  {
    println("calcing freq bands: " + n + " : " + sampleRate);
    float[][] result = new float[n][2];
    for (int i = 0; i < n; i++)
    {
      float lowFreq;
      if ( i == 0 )
        lowFreq = 0;
      else
        lowFreq = (sampleRate/2) / (float)Math.pow(2, n - i);
      float highFreq = (sampleRate/2) / (float)Math.pow(2, n - 1 - i);
      result[i][0] = lowFreq;
      result[i][1] = highFreq;
    } 
    return result;
  }
  
  Channel getChannel(int x, int y) {
    for (int i = 0; i < channels.length; i++) {
      if(channels[i].isOverMarker(x, y)) return channels[i];
    }
    return null;
  }
  
  Band getBand(int x, int y) {
    Band r;
    for (int i = 0; i < channels.length; i++) {
      r = channels[i].isOverBand(x, y);
      if (r != null) return r;
    }
    return null;
  }
  
  void toggleSolo(Channel c) {
    if (c.isSolo) {
      desolo(c);
    } else {
      solo(c);
    }
  }
  
  void solo(Channel c) {
    println("soloing channel: " + c.name);
    if (c.isMute) demute(c); // a channel that has been solo-ed cannot also be mute
    for (int i = 0; i < channels.length; i++) {
      //println(channels[i].name + ":" + c.name + " = " + channels[i].equals(c));
      channels[i].isSolo = channels[i].equals(c);
      if (channels[i].isSolo)
        channels[i].speakUp();
      else
        channels[i].shutUp();
    }
  }
  
  void desolo(Channel c) {
    println("desoloing channel: " + c.name);
    c.isSolo = false;
    for (int i = 0; i < channels.length; i++) {
      if (!channels[i].isMute)
        channels[i].speakUp();
      else
        channels[i].shutUp();
    }
  }
  
  void toggleMute(Channel c) {
    if (c.isMute) {
      demute(c);
    } else {
      mute(c);
    }
  }
  
  void mute(Channel c) {
    println("muting channel: " + c.name);
    if (c.isSolo) desolo(c); // a channel that has been muted cannot also be solo
    c.shutUp();
    c.isMute = true;
  }
  
  void demute(Channel c) {
    println("demuting channel: " + c.name);
    c.speakUp();
    c.isMute = false;
  }
  
  void toggleBypass(Channel c) {
     if (c.effect.isBypass) {
      debypass(c);
    } else {
      bypass(c);
    }
  }
  
  void bypass(Channel c) {
    println("bypassing effect for channel: " + c.name);
    c.effect.isBypass = true;
    for (int i = 0; i < c.bands.length; i++) {
      c.bands[i].isBypass = true;
    }
  }
  
  void debypass(Channel c) {
    println("debypassing effect for channel: " + c.name);
    c.effect.isBypass = false;
    for (int i = 0; i < c.bands.length; i++) {
      c.bands[i].isBypass = false;
    }
  }
  
  void toggleGroup(Channel c, int g) {
     int cg = c.group;
     if (g == 0) { // clear entire group
       for (int i = 0; i < channels.length; i++) {
         Channel ci = channels[i];
         if (ci.group == cg) ci.group = 0;
       } 
     } else if (cg == g) { // deselect
       c.group = 0;
     } else if (cg != g) { // select
       c.group = g;
     }
  }
  
  void draw() {
    for (int i = 0; i < channels.length; i++) {
      channels[i].draw();
    } 
  }
  
  void move(Channel c, int x, int y, boolean ignore_group) {
    println("moving channel: " + c.name + " to " + x + "," + y);
    int shiftX = x-c.posX;
    int shiftY = y-c.posY;
    if (!ignore_group) {
      if (c.group != 0) {
        // move rest of the group 
        for (int i = 0; i < channels.length; i++) {
          Channel ci = channels[i];
          if(ci.group == c.group) {
            ci.move(ci.posX + shiftX, ci.posY + shiftY);
          }
        }
      } else {
        c.move(x,y); 
      }
    } else {
      c.move(x,y); 
    }
  }
}
