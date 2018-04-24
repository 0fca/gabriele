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
import java.lang.reflect.*; 
import java.util.function.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SoundSpectrum extends PApplet {










private Minim minim;  
private FFT fftLin, fftLog,fftLinl, fftLinr;

private AudioInput in;

final float spectrumScale = 4;
final int startPos = 30;
private PFont font;

public void setup(){
  
  
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

public void draw(){
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
        
        drawLine(i,  height - 25, i, height - 25 - (float)(fftLin.getBand(t)) * slider1.getValueF());
        if(sinePlotChckbx.isSelected()){
          drawLinLeft(i,t);
          drawLinRight(i,t);
        }
      }else{
        double sin = (double) (75 * Math.sin((t / 100.0f) * 2 * Math.PI));
        drawLine(i,  height, i, height - (float)(fftLin.getBand(t) * sin ) * slider1.getValueF());
      }
      
    }
    text("Right channel spectrum", startPos, 325);
    text("Left channel spectrum", startPos, height % 150 * 5 + 25);
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
      
      rect(t*w, height, t*w + w, height - fftLin.getAvg(t)* spectrumScale * slider1.getValueF());
      
    }
    break;
  
    case 2:
    int wi = PApplet.parseInt(width/fftLog.avgSize());
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
  
  for(int i = startPos; i < fftLin.specSize() + startPos; i += (fftLin.specSize()/fftLin.getBandWidth()) * 10){
      drawLine(i, height - 18.25f, i , height - 9.25f); 
      text(String.valueOf((i - startPos) * fftLin.getBandWidth()), i + 5, height - 4.25f);
  }
  
  text("[Hz]", fftLin.specSize() + 50f, height - 10.5f);
  textSize(18f);
}

private void drawVertAxis(){
  if(typeCbx.getSelectedIndex() == 0){
    drawLine(5 , height + 10, 5, height - Math.abs(in.getGain()) * 1.5f );
    textSize(10f);
    text("[dB]", 2.5f ,height - Math.abs(in.getGain()) * 1.65f);
    for(int i = 25; i < Math.abs(in.getGain()) + 25 ; i += 8){
      drawLine(5, height - i, 10, height - i);
      text(String.valueOf(25-i), 15 , height - i);
    }
    textSize(18f);
  }
}
final public class FilesystemController{
  
}
final public class GeneratorController{
  
}
final public class Recorder{
  
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
  sinePlotChckbx.setEnabled(typeCbx.getSelectedIndex() == 0 ? true : false );
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

public void windowTypeCbx_click1(GDropList source, GEvent event) { //_CODE_:windowTypCbx:8787println(FFT.GAUSS);03:
  Field[] fs = FFT.class.getFields();
  for(Field f : fs){
    //println(f.toString().toLowerCase());
     if(f.toString().toLowerCase().contains(source.getSelectedText().toLowerCase())){
       try{
         println(f.get(null));
         fftLin.window((WindowFunction)f.get(null));
       }catch(IllegalAccessException e){
         e.printStackTrace();
       }
     }
  }
  
} //_CODE_:windowTypCbx:878703:



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
  sinePlotChckbx.setOpaque(false);
  sinePlotChckbx.addEventHandler(this, "checkbox1_clicked1");
  sinePlotChckbx.setSelected(true);
  windowTypCbx = new GDropList(this, 509, 38, 132, 80, 3);
  windowTypCbx.setItems(loadStrings("list_878703"), 0);
  windowTypCbx.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  windowTypCbx.addEventHandler(this, "windowTypeCbx_click1");
}

// Variable declarations 
// autogenerated do not edit
GDropList typeCbx; 
GSlider slider1; 
GCheckbox sinePlotChckbx; 
GDropList windowTypCbx; 
  public void settings() {  size(700, 480, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SoundSpectrum" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
