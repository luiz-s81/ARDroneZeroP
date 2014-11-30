
/*
  ARDroneZeroP - Processing game for Parrot ARDrone 2.0 - https://github.com/lgmsampaio/ARDroneZeroP
  Collaborators: 
  Luiz Gustavo Moreira Sampaio - lgmsampaio@gmail.com 
  Kazuki Sakai
  Shinichi Tamura
  Koudai Fujii
  With the kind consultancy of Christopher Michael Yap and the supervision of professor Shigeru Kashihara.
  
  Strongly based in the [ODC - Open Drone Control] http://www.opendronecontrol.org/
*/

//////////////////////////////////////////////////////
// [Manual]
// 'u' : take off / land
// 'x' : shoot
// [How to play] 2014/11/24
// *** detect marker and shoot 3d ghost(object), then you got points! ***
// If ghost HP is 0, the ghost die. A few seconds later, the ghost revive.
// 1st you should detect marker, 2nd, you capture the marker in therget circle, and shoot(press 'x'), after that you can get points.
// All ghost has HP, and HP is decreased by shooting.
// If HP is 0, the ghost has 'died';
// One marker has one ghost.
// If the marker has dead ghost, you can watch 3D X mark on the marker instead of 3D ghost.
// You can't get any points from X mark(because the ghost has already die).
/////////////////////////////////////////////////////


import java.io.*;
import java.awt.image.BufferedImage;
import org.opendronecontrol.platforms.ardrone.ARDrone;
import org.opendronecontrol.spatial.Vec3;
import scala.collection.immutable.List;
import jp.nyatla.nyar4psg.*;


final int gMAX_TIME = 20;

String dataPath;
final String patternPath = "ARToolKit_Patterns";
final String camPara = "camera_para.dat";

ARDrone drone;  // this creates our drone class
BufferedImage bimg;  // a 2D image from JAVA returns current video frame
 
PImage img;
DroneState state;
float droneX;
float droneY;
float droneZ;
float droneYaw;

int arWidth = 640;
int arHeight = 480;
int numMarkers = 10;

int gMAX_NUM_OF_ENEMY;//this is always same value of numMarkers.

//for the AR Markers
MultiMarker nya;
color[] colors = new color[numMarkers];
float[] scaler = new float[numMarkers];

//for game component
ArrayList<Object> objs;//object array
TargetCircle tCircle;
ScoreManager score;
Timer time;
boolean gHasShoot;//does user shoot?

void setup(){
  dataPath = getDataPath();

  size(arWidth, arHeight, P3D);
  time = new Timer(1);
  
  //setup drone
  drone = new ARDrone("192.168.1.1"); // default IP is 192.168.1.1
  drone.connect();
  state = new DroneState();
  
  //setup game component
  background(255, 255, 255);
  frameRate(60);
  reset();
  
  //setup AR marker detection
  nya = new MultiMarker(this, arWidth, arHeight, dataPath+camPara, NyAR4PsgConfig.CONFIG_DEFAULT);
  nya.setLostDelay(1);
  String[] patterns = loadPatternFilenames(dataPath+patternPath);

  for(int i=0; i < numMarkers; i++){
    nya.addARMarker(dataPath + patternPath + "/" + patterns[i], 80);
    //colors[i] = color(random(255), random(255), random(255), 160);
    scaler[i] = random(0.5, 1.9);
  }
  
 
}


void draw(){
 
  state.update(drone);
  ///////////////////
  //draw
  ///////////////////
  if( drone.hasVideo()){
    bimg = drone.video().getFrame(); // on each draw call get the current video frame
    if( bimg != null ){
      img = new PImage(bimg.getWidth(), bimg.getHeight(), PConstants.ARGB); // create a new processing image to hold the current video frame
      bimg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width); // fill the img with buffered frame data from drone
      img.updatePixels();
      img.resize(640,480);
      //image(img,0,0); // display the video frame
      // The function "set" does the same thing as "image" (display the camera image), but with better performance
      set(0, 0, img);
      nya.detect(img);
      drawEnemies();
     }
  }
  
  tCircle.drawCircle();
  textAlign(LEFT);
  
  score.drawScore(0, 40);
  textAlign(RIGHT);
  
  time.drawTime(width, 60);
  textAlign(RIGHT);
  
  state.displayBattery(width, 40);
  ///////////////////
  // input
  ///////////////////
  if(state.flying){
     //if(mouseX < width/2){
     if(key == 'a'){  
      droneX = 0.1;
     }
     if(key == 'd'){
      droneX = -0.1; 
     }
     
     //if(mouseY < height/2){
    if(key == 'w'){   
      droneZ = 0.1;
    // } else {
    }
    if(key == 's')  {
      droneZ = -0.1; 
     }
   }
   

  ///////////////////
  //update
  ///////////////////
  drone.move(droneX,droneY,droneZ,droneYaw);
  
  if( time.mTime <= 0){
     gameover();
     return;//return to startpoint of draw()
  }
  
  //shoot
  if(gHasShoot){
    AttackByDrone(tCircle);
    gHasShoot = false;
  }
    
  
  // I comented the following lines because the enemies are rendered based on markers
  //supplementEnemy( gMAX_NUM_OF_ENEMY - objs.size() );
  
  //recovery object
  for(int i = 0 ; i < objs.size() ; ++i){
    objs.get(i).recovery(0.05);//recover enemy's HP   
  }
  
  //revive object
  for(int i = 0 ; i < objs.size() ; ++i){
    if( objs.get(i).reviveObj() ){
      //DEBUG STATEMENT
      textAlign(CENTER);
      text("object revive", width /2, height / 2);
    }   
  }
  
  time.countDown(1);
  
  //DEBUG STATEMENT
  for(int i = 0 ; i < objs.size() ; ++i){
    objs.get(i).drawObjectState();
  }
}

void reset(){
  gMAX_NUM_OF_ENEMY = numMarkers;
  score = new ScoreManager(0);
  time = new Timer(20);
  tCircle = new TargetCircle(width / 2.0, height / 2.0, 100);//center of image
  objs = new ArrayList<Object>();
  // I comented the following lines because the enemies are rendered based on markers
  //supplementEnemy( gMAX_NUM_OF_ENEMY );
  //  for(int i = 0 ; i < gMAX_NUM_OF_ENEMY ; ++i){
  //    objs.add( new Object(this) );
  //  }
  for(int i = 0 ; i < objs.size()  ; ++i){
    objs.remove(i);//all object removed
  }  
  for(int i = 0 ; i < gMAX_NUM_OF_ENEMY ; ++i){
    objs.add( new Object(this, i) );
  }
}

void gameover(){
  textAlign(LEFT);
  score.drawScore(0, 40);
  for(int i = 0 ; i < objs.size()  ; ++i){
    objs.get(i).isAlive = false;
  }  
  textAlign(CENTER);
  text("GAME OVER", width /2, height / 2);
  text("Press 'q' to restart", width /2, height / 2 +50);
  if( keyPressed  ){
    if(key == 'q'){
      reset();
    }
  }
}

void keyPressed(){
  //takeoff anf release
  if (key =='u'){
    if(!state.flying){
      drone.takeOff(); 
    } else{
     drone.land(); 
    }
  }else if(key == 'x'){
    gHasShoot = true;
  }
    
}
/*
void supplementEnemy(final int numOfSupplement){
  for(int i = 0 ; i < numOfSupplement ; ++i){
    objs.add( new Object(this) );
  }
  for(Object obj : objs){
    obj.drawObj();
  }
}
*/
String[] loadPatternFilenames(String path){
  File folder = new File(path);
  FilenameFilter pattFilter = new FilenameFilter(){
    public boolean accept(File dir, String name){
      return name.toLowerCase().endsWith(".patt");
    }
  };
  return folder.list(pattFilter);
}

String getDataPath() {
  return dataPath("").replace("\\","/") + "/";
}

void drawEnemies(){
  for(int i = 0; i < numMarkers; i++){
    /*if(objs.get(i).isAlive && nya.isExistMarker(i)){
          pushMatrix();
          setMatrix( nya.getMarkerMatrix(i) );
          objs.get(i).drawObj3();
          popMatrix();
    }  
    */
    if(nya.isExistMarker(i)){
      if(objs.get(i).isAlive){
        pushMatrix();
        setMatrix( nya.getMarkerMatrix(i) );
        objs.get(i).drawObj3();
        popMatrix();
      }else{
        //draw X mark on the marker instead of dead object
        PVector[] pos2d = nya.getMarkerVertex2D(i);
        pushMatrix();
        setMatrix( nya.getMarkerMatrix(i) );
        drawX();
        popMatrix();
      }
    }  
  }
}

void drawX(){
  fill( 255, 0, 0);
  stroke( 255, 255, 255);//yellow
  strokeWeight(2);
  
  pushMatrix();
  
  pushMatrix();
  translate(0, -30/2, 0);
  rotateY( radians(45) );
  translate(0, 30 / 2, 0);
  box(120, 30, 30);
  popMatrix();
  
  pushMatrix();
  translate(0, -30/2, 0);
  rotateY( radians(-45) );
  translate(0, 30 / 2, 0);
  box(120, 30, 30);
  popMatrix();
  
  popMatrix();
}

void AttackByDrone(TargetCircle tCircle){
  tCircle.attackEffect();
  
  PVector centerPos = new PVector();//calc center of marker in drone's image coordinate
  for(int i = 0; i < numMarkers; i++){
    if(nya.isExistMarker(i) && objs.get(i).isAlive){
      PVector[] pos2d = nya.getMarkerVertex2D(i);
      centerPos.set(0.0f, 0.0f);
      centerPos.add( pos2d[0]); 
      centerPos.add( pos2d[1]); 
      centerPos.add( pos2d[2]); 
      centerPos.add( pos2d[3]);
      centerPos.mult( 0.25 );// divide 4.0;
      if( tCircle.insideTargetCircle( centerPos )){
        if( objs.get(i).damage(10) ){
          score.add(10);
        }else{//object HP is 0 ==> delete
          //any effect?
          //DEBUG
          /*
          textAlign(CENTER);
          text("GREAT!", width /2, height / 2);
          */
        }
      }
    }
      
  }
}  
