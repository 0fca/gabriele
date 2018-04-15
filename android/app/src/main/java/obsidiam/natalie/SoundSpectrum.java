package obsidiam.natalie;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.analysis.*; 
import ddf.minim.*; 
import java.awt.*; 
import g4p_controls.*; 
import java.util.*; 
import java.util.concurrent.ThreadLocalRandom; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SoundSpectrum extends PApplet {








Minim minim;  
FFT fftLin;
FFT fftLog;
AudioInput in;

final float spectrumScale = 4;
final int startPos = 20;
int lastWidth;
PFont font;

public void setup()
{
  
  
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

public void draw()
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
        drawLine(i,  height - 25, i, height - 25 - (float)(fftLin.getBand(i)) * spectrumScale * slider1.getValueF());
        
      }else{
        double sin = (double) (75 * Math.sin((i / 100.0f) * 2 * Math.PI));
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
    int w = PApplet.parseInt( width/fftLin.avgSize());
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
    int wi = PApplet.parseInt(width/fftLog.avgSize());
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
  lastWidth = width;
}

public void drawLinLeft(){
  text("Left channel spectrum", startPos, height % 150 * 5 + 25);
  fftLin.forward(in.left);
  
  for(int i = startPos; i < fftLin.specSize() + startPos; i++){
      drawLine(i, height % 150 * 5, i, height % 150 * 5 - (fftLin.getBand(i) * spectrumScale * slider1.getValueF()));
  }
}

public void drawLinRight(){
  text("Right channel spectrum", startPos, 325);
  fftLin.forward(in.right);
  
  for(int i = startPos; i < fftLin.specSize() + startPos; i++){
      drawLine(i, 300 , i, (300 - fftLin.getBand(i) * spectrumScale * slider1.getValueF()));
  }
}

private void drawLine(float x1, float y1, float x2, float y2){
  line(x1,y1,x2,y2);
}

private void drawHorAxis(){
  drawLine(startPos, height - 12.5f, fftLin.specSize() + 5, height - 12.5f);
  for(int i = startPos; i < fftLin.specSize() + startPos; i += (fftLin.specSize()/fftLin.getBandWidth()) * 10){
      drawLine(i, height - 18.25f, i , height - 9.25f);
      textSize(11f);
      text(String.valueOf((i - startPos) * fftLin.getBandWidth()), i - 5 , height - 5.25f);
  }
  text("[Hz]", fftLin.specSize() + 15f, height - 10.5f);
  textSize(18f);
}

private void drawVertAxis(){
  drawLine(5 , height, 5, 0);
  for(int i = (startPos + 2); i < height; i+= 10){
    drawLine(5, i, 10, i);
  }
}
/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void typeCbx_clickEvt(GDropList source, GEvent event) { //_CODE_:typeCbx:342525:
} //_CODE_:typeCbx:342525:

public void slider1_change1(GSlider source, GEvent event) { //_CODE_:slider1:334156:
  
} //_CODE_:slider1:334156:

public void checkbox1_clicked1(GCheckbox source, GEvent event) { //_CODE_:sinePlotChckbx:934500:
  if(source.isSelected()){
    slider1.setValue(5.0f);
  }else{
    slider1.setValue(1.0f);
  }
} //_CODE_:sinePlotChckbx:934500:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(true);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("Natalie");
  typeCbx = new GDropList(this, 31, 38, 192, 80, 3);
  typeCbx.setItems(loadStrings("list_342525"), 0);
  typeCbx.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  typeCbx.addEventHandler(this, "typeCbx_clickEvt");
  slider1 = new GSlider(this, 238, 25, 100, 48, 10.0f);
  slider1.setShowValue(true);
  slider1.setLimits(5, 1, 10);
  slider1.setNbrTicks(10);
  slider1.setStickToTicks(true);
  slider1.setShowTicks(true);
  slider1.setNumberFormat(G4P.INTEGER, 0);
  slider1.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  slider1.setOpaque(false);
  slider1.addEventHandler(this, "slider1_change1");
  sinePlotChckbx = new GCheckbox(this, 361, 38, 135, 23);
  sinePlotChckbx.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  sinePlotChckbx.setText("Standard spectrum plot");
  sinePlotChckbx.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  sinePlotChckbx.setOpaque(true);
  sinePlotChckbx.addEventHandler(this, "checkbox1_clicked1");
  sinePlotChckbx.setSelected(true);
}

// Variable declarations 
// autogenerated do not edit
GDropList typeCbx; 
GSlider slider1; 
GCheckbox sinePlotChckbx; 
  public void settings() {  size(700, 480, P2D); }
}
