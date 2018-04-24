import ddf.minim.analysis.*;
import ddf.minim.*;
import java.awt.*;
import g4p_controls.*;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import java.lang.reflect.*;
import java.util.function.*;
import java.awt.Font;

private Minim minim;  
private FFT fftLin, fftLog, fftLinr, fftLinl;
private float amplifier = 1;
private AudioInput in;

final float spectrumScale = 4;
final int startPos = 30;
private PFont font;
final String label = "Choose window type: ";
private final Font f = new Font("Arial", 2, 10);

void setup(){
  
  size(700, 480, P2D);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO);
  fftLin = new FFT( 1024, 44100 );
  fftLinr = new FFT(1024, 44100);
  fftLinl = new FFT(1024, 44100);
  
  fftLin.linAverages(50);
  fftLinl.linAverages(50);
  fftLinr.linAverages(50);

  fftLog = new FFT(1024, 44100);
  

  fftLog.logAverages( 12, 4 );
  
  rectMode(CORNERS);
  font = loadFont("ArialMT-12.vlw");
  out = minim.getLineOut();
  wave = new Oscil(1000, 0.8f, Waves.SINE);
  createGUI();
}

void draw(){
  background(0);
  textFont(font);
  textSize( 18 );
  preparePanel();
  float centerFrequency = 0;
  
  fftLin.forward(in.mix);
  fftLog.forward(in.mix);
  fftLinl.forward(in.left);
  fftLinr.forward(in.right);
  
  int r = ThreadLocalRandom.current().nextInt(0, 255);
  drawVertAxis();
  fill(255,128);
  text("Drawn signal is multiplied by "+amplifier, startPos, 50);
  
  switch(typeCbx.getSelectedIndex()){

    case 0:
    noFill();
    drawHorAxis();
    for(int i = startPos; i < fftLin.specSize() + startPos; i++)
    {
      int t = i - startPos;
      if ( i == mouseX ){
        centerFrequency = fftLin.indexToFreq(t);
        stroke(255, 0, 0);
      }else{
          stroke(0, 230, 255);
      }
      
      if(sinePlotChckbx.isSelected()){
        
        drawLine(i,  height - 25, i, height - 25 - (float)(fftLin.getBand(t)) * amplifier);
        if(sinePlotChckbx.isSelected()){
          drawLinLeft(i,t);
          drawLinRight(i,t);
        }
      }else{
        double sin = (double) (75 * Math.sin((t / 100.0) * 2 * Math.PI));
        drawLine(i,  height, i, height - (float)(fftLin.getBand(t) * sin ) * amplifier);
      }
      
    }
    
    if(sinePlotChckbx.isSelected()){
      text("Right channel spectrum", startPos, 325);
      text("Left channel spectrum", startPos, height % 150 * 5 + 25);
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
      
      rect(t*w, height, t*w + w, height - fftLin.getAvg(t)* spectrumScale * amplifier);
      
    }
    break;
  
    case 2:
    int wi = int(width/fftLog.avgSize());
    for(int i = startPos; i < fftLog.avgSize() + startPos; i++)
    {
      int t = i - startPos;
      centerFrequency    = fftLog.getAverageCenterFrequency(t);
      float averageWidth = fftLog.getAverageBandWidth(t);   

      float lowFreq  = centerFrequency - averageWidth/2;
      float highFreq = centerFrequency + averageWidth/2;

      int xl = (int)fftLog.freqToIndex(lowFreq);
      int xr = (int)fftLog.freqToIndex(highFreq);

      if ( mouseX >= t*wi && mouseX < t*wi + wi )
      {
        centerFrequency = fftLin.getAverageCenterFrequency(t);
        
        fill(255, 128);
        text("Logarithmical Average Center Frequency: " + centerFrequency, 5, 25);
        
        fill(255, 0, 0);
      }
      else
      {
          fill(r/(i+1), r, r  % 255);
      }
      
      rect( xl, height, xr, height - fftLog.getAvg(t) * spectrumScale * amplifier);
    }
    break;
  }
}

public void drawLinLeft(int i, int t){
  fill(255,128);
  drawLine(i, height % 150 * 5, i, height % 150 * 5 - (fftLinl.getBand(t) * amplifier));
}

public void drawLinRight(int i, int t){
  fill(255,128);
  drawLine(i, 300 , i, (300 - fftLinr.getBand(t) * amplifier));
}

private void drawLine(float x1, float y1, float x2, float y2){
  line(x1,y1,x2,y2);
}

private void drawHorAxis(){
  drawLine(startPos, height - 12.5f, fftLin.specSize() + 5, height - 12.5f);
  textSize(11f);
  
  for(int i = startPos; i < fftLin.specSize() + startPos; i += (fftLin.specSize()/fftLin.getBandWidth()) * 10){
      drawLine(i, height - 18.25f, i , height - 9.25f); 
      text(String.valueOf((i - startPos) * fftLin.getBandWidth()), i + 5, height - 4.25f);
  }
  
  text("[Hz]", fftLin.specSize() + 50f, height - 10.5f);
  textSize(18f);
}

private void drawVertAxis(){
  if(typeCbx.getSelectedIndex() == 0){
    drawLine(5 , height + 10, 5, height - Math.abs(in.getGain()) * 1.5 );
    textSize(10f);
    text("[dB]", 2.5f ,height - Math.abs(in.getGain()) * 1.65);
    for(int i = 25; i < Math.abs(in.getGain()) + 25 ; i += 8){
      drawLine(5, height - i, 10, height - i);
      text(String.valueOf(25-i), 15 , height - i);
    }
    textSize(18f);
  }
}

private void preparePanel(){
   
  workPanel.addControl(typeCbx,5f,20f);
  workPanel.setFont(f);
  sinePlotChckbx.setFont(f);
  //workPanel.addControl(gLabel, 5f, 60f);
  workPanel.addControl(windowTypCbx, 5f, 70f); 
  workPanel.addControl(sinePlotChckbx, typeCbx.getWidth() + 5f,20f);
 
}
