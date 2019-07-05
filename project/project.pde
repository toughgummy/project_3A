import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;

Minim       minim;
AudioPlayer player;
FFT         fft;
ControlP5 slider_1, slider_2, Button_1, Button_up, Button_down;
float sliderValue_1, sliderValue_2, Gain;
String state = "on";


final int MAXBAND = 48;    
float     specSize;              
float     initBand;              
int       stepCount;             
int       wakuX, wakuY;          
int       wakuWidth, wakuHeight; 
int       barWidth;              
int       bandHz[] =  {   43,   43,   43,   43,   43,   43,   43,    43, 
                          43,   43,   43,   43,   43,   43,   43,    43,
                          86,   86,   86,   86,   86,   86,   86,    86,
                         172,  172,  172,  172,  688,  688,  688,   688,
                         215,  215,  344,  344,  516,  516,  688,   688,
                        1032, 1032, 1204, 1376, 1548, 1720, 1892,  2064 };
 
void setup(){
  minim = new Minim(this);
  player = minim.loadFile("bgm_piano33.mp3");
  Gain = player.getGain();
  size(640, 480, P2D);
  
  
  wakuX = 10;
  wakuY = 10;
  wakuWidth = 620;
  wakuHeight = 460;
  //player.bufferSize();//size
  //player.sampleRate();//rate
  fft = new FFT( player.bufferSize(), player.sampleRate()); //make new fft
  specSize = fft.specSize(); // get fftsize
  fft.window( FFT.HANN );
  initBand = fft.getBandWidth(); // get fftwide
  barWidth = wakuWidth / MAXBAND;
  
  slider_1 = new ControlP5(this);
  slider_1.addSlider("sliderValue_1", 0, 255, 0, 30, 30, 200, 20)
    .setNumberOfTickMarks(256);
  slider_1.getController("sliderValue_1")
    .getValueLabel()
    .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(-20);
    
  slider_2 = new ControlP5(this);
  slider_2.addSlider("sliderValue_2", 1, 4, 0, 300, 30, 200, 20)
    .setNumberOfTickMarks(4);
  slider_2.getController("sliderValue_2")
    .getValueLabel()
    .align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
    .setPaddingX(-20);
    
  //int Color1 = color(255, 255, 255);
  Button_1 = new ControlP5(this);
  Button_1.addButton("Button_01")
    .setLabel("on/off")
    .setPosition(30, 130)
    .setSize(50, 20);
    //.setColorActive(Color1);
  
  Button_up = new ControlP5(this);
  Button_up.addButton("Button_up")
    .setLabel("+")
    .setPosition(80, 80)
    .setSize(50, 20);
    
  Button_down = new ControlP5(this);
  Button_down.addButton("Button_down")
    .setLabel("-")
    .setPosition(30, 80)
    .setSize(50, 20);
  player.loop();
}

void Button_01(){
  //println("fileA clicked");
  if (state == "off"){
    player.loop();
    state = "on";
  }else{
    player.pause();
    state = "off";
  }
}

void Button_up(){
  if (state=="on"){
  Gain += 5;
  player.setGain( Gain );
  }
}

void Button_down(){
  Gain -= 5;
  player.setGain( Gain );
}

void draw(){
  background(sliderValue_1);
  

  strokeWeight( 2 );
  stroke( 0 );
  noFill();
  rect( wakuX, wakuY, wakuWidth, wakuHeight );
  if( player.isPlaying() == false ){
    return;
  }
  fft.forward( player.mix );//left + right
  int ToStep = 0;     
  int FromStep = 0;    
  for( int index = 0; index < MAXBAND; index++ ){
    int bandStep = (int)( bandHz[index] / initBand );
    if( bandStep < 1 ){ bandStep = 1; }
    ToStep = ToStep + Math.round( bandStep );
    if( ToStep > specSize ){ ToStep = (int)specSize; }   
    float bandAv = 0;
    for( int j = FromStep ; j < ToStep; j++ ){      
       float bandDB = 0; 
      if ( fft.getBand( j ) != 0 ) {   
        bandDB = 2 * ( 20 * ((float)Math.log10(fft.getBand(j))) + 40);
        if( bandDB < 0 ){ bandDB = 0; }
      }      
      bandAv = bandAv + bandDB;
    }    
    bandAv = bandAv / bandStep;  
    FromStep = ToStep;
    float y = map( bandAv, 0, 250, 0, wakuHeight ); 
    if( y < 0) { y = 0; }
    color c1 = color( 0,0,255 );
    color c2 = color( 255,255,0 );    
    color c3 = lerpColor( c1, c2, index/32.0 );
    fill( c3, 140 );     
    rect( index*barWidth+wakuX,( wakuHeight-y )+wakuY, barWidth, y );
  } 
  
  
  
  text( "Value : " + sliderValue_1, 20, 20 );
  text( "Gain : " + Gain, 120, 20 );
  fill(0, 127, 255, 200);
  float radiusM = player.mix.level() * width;
  float radiusL = player.left.level() * width;
  float radiusR = player.right.level() * width;
  noStroke();
  ellipse(width/2, height/2, radiusM/3, radiusM/3);//center
  for(int i = 1; i < sliderValue_2; i++){
    ellipse(width/2, height*i/4, radiusM/3, radiusM/3);//center
    ellipse(width/4, height*i/4, radiusL/3, radiusL/3);//left
    ellipse(width*3/4, height*i/4, radiusR/3, radiusR/3);//right
  }
  player.printControls();
}

void stop(){
  player.close();
  minim.stop();
}
