import ddf.minim.analysis.*;
import ddf.minim.*;
import java.awt.*;
import g4p_controls.*;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

private Minim minim;  
private FFT fftLin, fftLog;
private AudioInput in;

final float spectrumScale = 4;
final int startPos = 20;
private PFont font;

void setup()
{
  
  size(700, 480, P2D);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO);
  fftLin = new FFT( 1024, 44100 );

  fftLin.linAverages( 50 );

  fftLog = new FFT( 1024, 44100 );

  fftLog.logAverages( 12, 4 );
  
  rectMode(CORNERS);
  font = loadFont("ArialMT-12.vlw");
  
  createGUI();
}

void draw()
{
  background(0);
  
  textFont(font);
  textSize( 18 );
 
  float centerFrequency = 0;
  
  fftLin.forward( in.mix );
  fftLog.forward( in.mix );
  int r = ThreadLocalRandom.current().nextInt(0, 255);
  drawVertAxis();
  switch(typeCbx.getSelectedIndex()){

    case 0:
    noFill();
    for(int i = startPos; i < fftLin.specSize() + startPos; i++)
    {
      if ( i == mouseX ){
        centerFrequency = fftLin.indexToFreq(i);
        stroke(255, 0, 0);
      }
      else{
          stroke(0, 230, 255);
      }
      
      if(sinePlotChckbx.isSelected()){
        drawHorAxis();
        drawLine(i,  height - 25, i, height - 25 - (float)(fftLin.getBand(i)) * slider1.getValueF());
        
      }else{
        double sin = (double) (75 * Math.sin((i / 100.0) * 2 * Math.PI));
        drawLine(i,  height, i, height - (float)(fftLin.getBand(i) * sin ) * slider1.getValueF());
      }
      
    }
    if(sinePlotChckbx.isSelected()){
      drawLinLeft();
      drawLinRight();
    }
    
    text("Spectrum Center Frequency: " + centerFrequency, startPos, 25);
    break;
  
    case 1:
     noStroke();
    int w = int( width/fftLin.avgSize());
    for(int i = startPos; i < fftLin.avgSize() + startPos; i++){
      int t = i - startPos;

      if ( mouseX >= t*w && mouseX < t*w + w ){
        centerFrequency = fftLin.getAverageCenterFrequency(t);
        
        fill(255, 128);
        text("Linear Average Center Frequency: " + centerFrequency, startPos,  25);
        
        fill(255, 0, 0);
      }
      else{
          fill(r/(t+1), r, r  % 255);
      }
      
      rect(t*w, height, t*w + w, height - fftLin.getAvg(t)*spectrumScale * slider1.getValueF());
      
    }
    break;
  
    case 2:
    int wi = int(width/fftLog.avgSize());
    for(int i = startPos; i < fftLog.avgSize() + startPos; i++)
    {
      centerFrequency    = fftLog.getAverageCenterFrequency(i - startPos);
      float averageWidth = fftLog.getAverageBandWidth(i - startPos);   

      float lowFreq  = centerFrequency - averageWidth/2;
      float highFreq = centerFrequency + averageWidth/2;

      int xl = (int)fftLog.freqToIndex(lowFreq);
      int xr = (int)fftLog.freqToIndex(highFreq);

      if ( mouseX >= i*wi && mouseX < i*wi + wi )
      {
        centerFrequency = fftLin.getAverageCenterFrequency(i);
        
        fill(255, 128);
        text("Logarithmical Average Center Frequency: " + centerFrequency, 5, 25);
        
        fill(255, 0, 0);
      }
      else
      {
          fill(r/(i+1), r, r  % 255);
      }
      
      rect( xl, height, xr, height - fftLog.getAvg(i - startPos) * spectrumScale * slider1.getValueF());
    }
    break;
  }
}

public void drawLinLeft(){
  text("Left channel spectrum", startPos, height % 150 * 5 + 25);
  fftLin.forward(in.left);
  
  for(int i = startPos; i < fftLin.specSize() + startPos; i++){
      drawLine(i, height % 150 * 5, i, height % 150 * 5 - (fftLin.getBand(i) * slider1.getValueF()));
  }
}

public void drawLinRight(){
  text("Right channel spectrum", startPos, 325);
  fftLin.forward(in.right);
  
  for(int i = startPos; i < fftLin.specSize() + startPos; i++){
      drawLine(i, 300 , i, (300 - fftLin.getBand(i) * slider1.getValueF()));
  }
}

private void drawLine(float x1, float y1, float x2, float y2){
  line(x1,y1,x2,y2);
}

private void drawHorAxis(){
  drawLine(startPos, height - 12.5f, fftLin.specSize() + 5, height - 12.5f);
  for(int i = startPos; i < fftLin.specSize() + startPos; i += (fftLin.specSize()/fftLin.getBandWidth()) * 10){
      drawLine(i - startPos, height - 18.25f, i - startPos , height - 9.25f);
      textSize(11f);
      text(String.valueOf(((i - startPos) * fftLin.getBandWidth())), i - 5 , height - 5.25f);
  }
  text("[Hz]", fftLin.specSize() + 25f, height - 10.5f);
  textSize(18f);
}

private void drawVertAxis(){
  drawLine(5 , height, 5, 0);
  for(int i = (startPos + 2); i < height; i+= 10){
    drawLine(5, i, 10, i);
  }
}
