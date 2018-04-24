import ddf.minim.*;
import ddf.minim.ugens.*;

  AudioOutput out;
  Oscil       wave;
  private boolean snapFreq = false;
  private boolean isOscilOn = false;
  
  public void drawPlot(){
    background(0);
    stroke(255);
    strokeWeight(1);

    for(int i = 0; i < out.bufferSize() - 1; i++)
    {
      line( i, 50  - out.left.get(i)*50,  i+1, 50  - out.left.get(i+1)*50 );
      line( i, 150 - out.right.get(i)*50, i+1, 150 - out.right.get(i+1)*50 );
    }
  }

  public void mouseMoved(){
    if(snapFreq){
      float amp = map( mouseY, 0, height, 1, 0 );
      wave.setAmplitude( amp );
  
      float freq = map( mouseX, startPos, fftLin.specSize(), 10, 22039 );
      wave.setFrequency( freq );
    }
  }

public void keyPressed(){ 
 if(key == 'o'){
   isOscilOn = !isOscilOn;
   if(isOscilOn){
     wave.patch(out);
   }else{
      wave.unpatch(out);
   }
 }

  if(key == '+' && amplifier <= 10f){
     amplifier += 0.5f; 
  }else if(key == '-' && amplifier > 0){
     amplifier -= 0.5f;
  }
 
 if(isOscilOn){
   
  switch(key)
  {
    case '1': 
      wave.setWaveform( Waves.SINE );
      break;
     
    case '2':
      wave.setWaveform( Waves.TRIANGLE );
      break;
     
    case '3':
      wave.setWaveform( Waves.SAW );
      break;
    
    case '4':
      wave.setWaveform( Waves.SQUARE );
      break;
      
    case '5':
      wave.setWaveform( Waves.QUARTERPULSE );
      break;
    case 'l':
      snapFreq = !snapFreq;
      break;
    default: break; 
  }
 }
}
