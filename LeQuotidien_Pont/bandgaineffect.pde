class BandGainEffect implements AudioEffect
{
  FFT fft;
  Band[] bands;
  float dontChangeRange = 0.1f;
  boolean isBypass = false;
  
  BandGainEffect(FFT f, Band[] b) {
    fft = f;
    bands = b;
  }
  
  void process(float[] samp)
  {
    if (isBypass) return;
    //if (false && gain != 1f){  // remove the "false" to trigger the scaling
    boolean con = false;
    for (int j = 0; j < bands.length; j++) {
      //println (abs(bands[j].getGain() - 1.0) + " ====== " + dontChangeRange);
       con = abs(bands[j].getGain() - 1.0) > dontChangeRange;
       if (con) break;
    }
    if (!con) return;
    
    fft.forward(samp);
    
    for (int j = 0; j < bands.length; j++) {
      int lowBand = bands[j].lowBand;
      int highBand = bands[j].highBand;
      float midBand = 0.5 * (lowBand + highBand);
      float gain = bands[j].getGain();
      if (abs(gain - 1.0) < dontChangeRange) continue; // don't bother with this band as the gain is minimal
     // println("scaling with a gain of: " + gain);
      for (int i = lowBand; i < highBand; i++)
      {
        int window = 3; // change this value to control the windowing function
        float g = gain;
        if (window == 1) {
          //
        } else if (window == 2) { // edge-softening
          boolean lastBand = j == bands.length - 1;
          boolean firstBand = j == 0;
          boolean lastFftBand = i == highBand - 1;
          boolean firstFftBand = i == lowBand;
          boolean secondFftBand = i == lowBand + 1;
          if (lastFftBand && !lastBand)
            g = 0.25* (3*gain + bands[j+1].getGain());
          else if (firstFftBand && !firstBand)
            g = 0.5* (gain + bands[j-1].getGain());
          else if (secondFftBand && !firstBand)
            g = 0.25* (3*gain + bands[j-1].getGain());
        } else if (window == 3) { // this is a bad attempt at a triangular "window"
          boolean firstBand = j == 0;
          boolean lastBand = j == bands.length - 1;
          if (i <= midBand) {
            if (firstBand)
              g = gain;
            else
              g = bands[j-1].getGain() + (gain - bands[j-1].getGain()) * (i-lowBand)/(midBand-lowBand);
          } else {
            if (lastBand)
              g = gain;
            else {
              g = gain + (bands[j+1].getGain() - gain) * (i-midBand)/(highBand-midBand);
              //println("scaling with a gain of " + i + " bucket: " + g + " (bucket counts are: " + lowBand + " " + midBand + " " + highBand + ")" + " (gains are: " + gain + " " + bands[j+1].getGain() + ")");
            }
          }
        }
        
        fft.scaleBand(i, gain);
      }
    }
    float[] buffer = new float[samp.length];
    //fft.window(FFT.HAMMING);
    fft.inverse(buffer);
    
    arraycopy(buffer, samp);
  }
 
  void process(float[] left, float[] right)
  {
    process(left);
    process(right);
  }
  
}
