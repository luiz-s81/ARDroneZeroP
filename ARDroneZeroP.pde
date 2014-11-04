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

import java.awt.image.BufferedImage;
import org.opendronecontrol.platforms.ardrone.ARDrone;
import org.opendronecontrol.spatial.Vec3;
import scala.collection.immutable.List;

ARDrone drone;  // this creates our drone class
BufferedImage bimg;  // a 2D image from JAVA returns current video frame
 
PImage img;
Vec3 gyro; // storing gyroscope data
boolean flying; 
float droneX;
float droneY;
float droneZ;
float droneYaw;

void setup(){
  size(640,480, OPENGL);
  drone = new ARDrone("192.168.1.1"); // default IP is 192.168.1.1
  drone.connect();
  gyro = new Vec3(0.0,0.0,0.0);
}

void draw(){
  
  if (drone.hasSensors()){
    flying = drone.sensors().get("flying").bool();
  }
  
  if( drone.hasVideo()){
    
    bimg = drone.video().getFrame(); // on each draw call get the current video frame
    
    if( bimg != null ){
      img = new PImage(bimg.getWidth(),bimg.getHeight(),PConstants.ARGB); // create a new processing image to hold the current video frame
      bimg.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width); // fill the img with buffered frame data from drone
      img.updatePixels();
      img.resize(640,480);
      image(img,0,0); // display the video frame
     }
  }
    
  if( drone.hasSensors()){
    gyro = drone.sensors().get("gyroscope").vec();
    //println("gyro x: " + round(gyro.x()) + " gyro y: " + round(gyro.y()) + " gyro z: " + round(gyro.z()));  
  }
  
  fill((gyro.y()+180)/360*255,0,60);
  ellipse(gyro.z()*10 + width/2, gyro.x()*10 + height/2, 80, 80);
    
  if(flying==true){
    
     //if(mouseX < width/2){
     if(key == 'a')  
      droneX = 0.1;
     if(key == 'd'){
      droneX = -0.1; 
     }
     
     //if(mouseY < height/2){
    if(key == 'w')   
      droneZ = 0.1;
    // } else {
    if(key == 's')  {
      droneZ = -0.1; 
     }
   }

  drone.move(droneX,droneY,droneZ,droneYaw);
}

void keyPressed(){
  if (key =='u'){
    if(flying==false){
      drone.takeOff(); 
    } else{
     drone.land(); 
    }
  }
}

