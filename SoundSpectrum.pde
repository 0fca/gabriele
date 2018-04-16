import ddf.minim.analysis.*;
import ddf.minim.*;
import java.awt.*;
import g4p_controls.*;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import java.lang.reflect.*;
import java.util.function.*;

private Minim minim;  
private FFT fftLin, fftLog,fftLinl, fftLinr;

private AudioInput in;

final float spectrumScale = 4;
final int startPos = 30;
private PFont font;

void setup(){
  
  size(700, 480, P2D);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO);
  fftLin = fftLinl = fftLinr = new FFT( 1024, 44100 );
  fftLin.linAverages(50);
  fftLinl.linAverages(25);
  fftLinr.linAverages(25);

  fftLog = new FFT( 1024, 44100 );

  fftLog.logAverages( 12, 4 );
  
  rectMode(CORNERS);
  font = loadFont("ArialMT-12.vlw");
  
  createGUI();
}

void draw(){
  background(0);
  
  textFont(font);
  textSize( 18 );
 
  float centerFrequency = 0;
  
  fftLin.forward(in.mix);
  fftLog.forward(in.mix);
  fftLinl.forward(in.left);
  fftLinr.forward(in.right);
  
  int r = ThreadLocalRandom.current().nextInt(0, 255);
  drawVertAxis();
  switch(typeCbx.getSelectedIndex()){

    case 0:
    noFill();

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
        drawHorAxis();
        drawLine(i,  height - 25, i, height - 25 - (float)(fftLin.getBand(t)) * slider1.getValueF());
        if(sinePlotChckbx.isSelected()){
          drawLinLeft(i,t);
          drawLinRight(i,t);
        }
      }else{
        double sin = (double) (75 * Math.sin((t / 100.0) * 2 * Math.PI));
        drawLine(i,  height, i, height - (float)(fftLin.getBand(t) * sin ) * slider1.getValueF());
      }
      
    }
    text("Right channel spectrum", startPos, 325);
    text("Left channel spectrum", startPos, height % 150 * 5 + 25);
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
      
      rect(t*w, height, t*w + w, height - fftLin.getAvg(t)* spectrumScale * slider1.getValueF());
      
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
      
      rect( xl, height, xr, height - fftLog.getAvg(t) * spectrumScale * slider1.getValueF());
    }
    break;
  }
}

public void drawLinLeft(int i, int t){
  fill(255,128);
  drawLine(i, height % 150 * 5, i, height % 150 * 5 - (fftLinl.getBand(t) * slider1.getValueF()));
}

public void drawLinRight(int i, int t){
  fill(255,128);
  drawLine(i, 300 , i, (300 - fftLinr.getBand(t) * slider1.getValueF()));
}

private void drawLine(float x1, float y1, float x2, float y2){
  line(x1,y1,x2,y2);
}

private void drawHorAxis(){
  drawLine(startPos, height - 12.5f, fftLin.specSize() + 5, height - 12.5f);
  textSize(11f);
  final HashSet<Integer> labels = new HashSet<Integer>();
  
  for(int i = startPos; i < fftLin.specSize() + startPos; i += (fftLin.specSize()/fftLin.getBandWidth()) * 10){
      drawLine(i, height - 18.25f, i , height - 9.25f); 
      labels.add(i);
  }
  
  Consumer<Integer> c = new Consumer(){
    public void accept(Object t){
        text(String.valueOf((new Integer(t.toString()) - startPos) * fftLin.getBandWidth()), new Float(t.toString()), height - 8.25f);
    }
  };
  
  labels.forEach(c);
  
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
