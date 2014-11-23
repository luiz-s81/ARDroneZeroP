
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
import java.io.*;
import java.awt.image.BufferedImage;
import org.opendronecontrol.platforms.ardrone.ARDrone;
import org.opendronecontrol.spatial.Vec3;
import scala.collection.immutable.List;
import jp.nyatla.nyar4psg.*;

final int gMAX_NUM_OF_ENEMY = 3;
final int gMAX_TIME = 20;

final String camPara = "C:/Users/sakaikazuki/Documents/Processing/libraries/NyAR4psg/data/camera_para.dat";//"D:/sakaikazuki/My Documents/Processing/libraries/NyAR4psg/data/camera_para.dat";
final String patternPath = "C:/Users/sakaikazuki/Documents/Processing/libraries/NyAR4psg/patternMaker/examples/ARToolKit_Patterns";////"D:/Luiz/Dropbox/My Documents/Processing/libraries/NyAR4psg/patternMaker/examples/ARToolKit_Patterns";

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

//for the AR Markers
MultiMarker nya;
color[] colors = new color[numMarkers];
float[] scaler = new float[numMarkers];

//for game component
ArrayList<Object> objs;
TargetCircle tCircle;
ScoreManager score;
Timer time;

void setup(){
  size(arWidth, arHeight, P3D);
  
  //setup drone
  drone = new ARDrone("192.168.1.1"); // default IP is 192.168.1.1
  drone.connect();
  state = new DroneState();
  
  //setup game component
  background(255, 255, 255);
  frameRate(60);
  reset();
  
  //setup AR marker detection
  nya = new MultiMarker(this, arWidth, arHeight, camPara, NyAR4PsgConfig.CONFIG_DEFAULT);
  nya.setLostDelay(1);
  String[] patterns = loadPatternFilenames(patternPath);
  
  for(int i=0; i < numMarkers; i++){ 
    nya.addARMarker(patternPath + "/" + patterns[i], 80);
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
  
  /*
   ARMarkerClassObject : amo
   for(int i = 0 ; i < amo.size() ; ++i){
     draw3DObject( amo[i].id );
   }
  */
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

   
   if( time.mTime <= 0){
     gameover();
     return;//return to startpoint of draw()
   }
   
   //AR Marker detection
   /*
   ARMarkerClassObject : amo
   amo = ARMargerDetection();
   */
   
   /*
   //shoot!
   if(key == 's'){//shoot!
     drawShootEffect();
   }
   */
   

  ///////////////////
  //update
  ///////////////////
  drone.move(droneX,droneY,droneZ,droneYaw);
 
    
  
  // I comented the following lines because the enemies are rendered based on markers
  //supplementEnemy( gMAX_NUM_OF_ENEMY - objs.size() );
  
  //object move
  for(int i = 0 ; i < objs.size() ; ++i){
    //Object tmp = objs.get(i);
    objs.get(i).recovery(0.05);//recover enemy's HP   
  }
  

  //hit detection
  /*
  for(int i = 0 ; i < amo.size() ; ++i){//for all object which the marker is detected
    if(amo[i] is shooted){
      object got damages.
      if(object hp is under 0){
        object is removed;
        score.add(10);
      }
    }
  }
  */
    
}

void reset(){
  score = new ScoreManager(0);
  time = new Timer(20);
  tCircle = new TargetCircle(width / 2.0, height / 2.0, 100);//center of image
  objs = new ArrayList<Object>();
  // I comented the following lines because the enemies are rendered based on markers
  //supplementEnemy( gMAX_NUM_OF_ENEMY );
  //  for(int i = 0 ; i < gMAX_NUM_OF_ENEMY ; ++i){
  //    objs.add( new Object(this) );
  //  }
}

void gameover(){
  textAlign(LEFT);
  score.drawScore(0, 40);
  for(int i = 0 ; i < objs.size()  ; ++i){
    objs.remove(i);//all object removed
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

void drawEnemies(){
  //textAlign(LEFT, TOP);
  //textSize(10);
  //noStroke();
  //scale(displayScale);
                                    
  for(int i = 0; i < numMarkers; i++){
    
    if(nya.isExistMarker(i)){
     
      Object obj = new Object(this);
      if( keyPressed  ){
        if(key == 'c'){
          pushMatrix();//don't forget this!
          setMatrix( nya.getMarkerMatrix(i) );
          obj.drawObj3();
          popMatrix();//don't forget this!
        }
      }else{
        //older version(not correct)
        PVector[] pos2d = nya.getMarkerVertex2D(i);
        // The object pos2d has the marker 4 points.
        // Now we are using just one
        //for(int j = 0; j < pos2d.length; j++){
        obj.drawObj2(pos2d[0].x, pos2d[0].y);

        
        /*
        String s = "(" + int(pos2d[j].x) + "," + int(pos2d[j].y) + ")";
        fill(255);
        rect(pos2d[j].x, pos2d[j].y, textWidth(s) + 3, textAscent() + textDescent() + 3);
        fill(0);
        text(s, pos2d[j].x + 2, pos2d[j].y + 2);
        fill(255, 0, 0);
        ellipse(pos2d[j].x, pos2d[j].y, 5, 5);
        */
        //}
      }
    }  
  }
 
  
}


