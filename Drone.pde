/*
This file defines:
 - Drone ... manage drone's data and control the drone
            (extends original ARDrone class)
*/

import java.awt.image.BufferedImage;
import java.awt.*;
import org.opendronecontrol.platforms.ardrone.ARDrone;
import org.opendronecontrol.spatial.Vec3;


///////////////////////////////////////////////////////////
//                                                       //
//                      DRONE CLASS                      //
//                                                       //
///////////////////////////////////////////////////////////
class Drone extends ARDrone{
  // For connection
  private static final String DEFAULT_IPADRESS = "192.168.1.1";

  // For keyboard controlling
  private boolean rightPressed;
  private boolean leftPressed;
  private boolean upPressed;
  private boolean downPressed;
  private boolean shiftPressed;

  // For video
  private boolean       isVideoAvailable;
  private BufferedImage rawVideoB;
  private Graphics2D    rawVideoG; // combined to rawVideoB
  private PImage        video;

  // To hold sensor data
  private boolean isFlyingNow;
  private boolean isFlyingPrev; // from previous frame
  private int     battery;
  private float   altimeter;
  private Vec3    gyroscope;
  private Vec3    velocity;

  // To display battery
  private PFont font;

  Drone() {
    this(DEFAULT_IPADRESS);
  }
  Drone(String IPaddress){
    // Call parent's constructor and connect
    super(IPaddress);
    super.connect();

    // For keyboard controlling
    rightPressed = false;
    leftPressed  = false;
    upPressed    = false;
    downPressed  = false;
    shiftPressed = false;

    // For video
    isVideoAvailable = false;
    rawVideoB = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
    rawVideoG = rawVideoB.createGraphics(); // Bind to rawVideoB
    rawVideoG.setRenderingHint(             // Setting for scaling
      RenderingHints.KEY_INTERPOLATION,
      RenderingHints.VALUE_INTERPOLATION_BILINEAR
    );
    video = createImage(width, height, RGB);

    // To hold sensor data
    isFlyingNow  = false;
    isFlyingPrev = false;
    battery      = 0;
    altimeter    = 0;
    gyroscope    = new Vec3(0,0,0);
    velocity     = new Vec3(0,0,0);

    // To display battery
    font = createFont("Verdana", 20);
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  boolean isFlying() {
    return isFlyingNow;
  }
  boolean isJustLanded() {
    return (isFlyingPrev && !isFlyingNow);
  }
  boolean isVideoAvailable() {
    return isVideoAvailable;
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  boolean update() {
    boolean succeeded = true;
    succeeded &= setSensorData();
    succeeded &= setVideo();
    move();
    return succeeded;
  }
  private boolean setSensorData() {
    isFlyingPrev = isFlyingNow;
    if ( super.hasSensors() ){
      isFlyingNow = super.sensors().get("flying").bool();
      battery     = super.sensors().get("battery").getInt();
      altimeter   = super.sensors().get("altimeter").getFloat();
      gyroscope   = super.sensors().get("gyroscope").vec();
      velocity    = super.sensors().get("velocity").vec();
      return true; // succeeded
    } else {
      return false;// failed
    }
  }

  private boolean setVideo() {
    isVideoAvailable = false;
    if ( super.hasVideo() ) {
      // image will be updated IF AND ONLY IF video is successfully decoded
      // Otherwise, image from old frame remains
      // (However, Video is not available)

      // Put the image into buffer (rawVideoB)
      rawVideoG.drawImage(super.video().getFrame(), 0, 0, 640, 480, null);
      // fill the video with buffer
      rawVideoB.getRGB(0, 0, width, height, video.pixels, 0, width);
      // Reflect it
      video.updatePixels();
      isVideoAvailable = true;
    }
    return isVideoAvailable;
  }

  PImage getVideo() {
    return video;
  }

  void displayBattery() {
    // Position
    int w = 30;
    int h = 14;
    int x1 = width  -10 -w;
    int y1 = height -10 -h;
    int x2 = width  -10;
    int y2 = height -10;

    // Outer part
    fill(#CCCCCC, 100);
    strokeWeight(2);
    stroke(#000000);
    rectMode(CORNERS);
    rect(x1,y1,x2,y2);

    // Battery "+" part
    strokeWeight(4);
    strokeCap(PROJECT);
    line(x2+2,y1+4,x2+2,y2-4);
    strokeCap(ROUND);

    // Inner part
    rectMode(CORNER);
    strokeWeight(1);//reset to default
    noStroke();
    if (battery >20) {
      fill(#11FF11); // green
    } else {
      fill(#FF1111); // red
    }
    rect(x1+2,y1+2,(w-4)*battery/100,h-4);

    // Show battery number
    textAlign(RIGHT);
    textSize(20);
    textFont(font);
    text(String.format("%d%%",battery), x1-4, y2);

    // fill all canvas red
    if (battery < 15) {
      fill(#FF0000,80);
      rect(0,0,width, height);
    }
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void move() {
    if (!shiftPressed) {
      if (rightPressed) super.right(1);
      if (leftPressed)  super.left(1);
      if (upPressed)    super.forward(1);
      if (downPressed)  super.back(1);
    } else {
      if (rightPressed) super.cw(1);
      if (leftPressed)  super.ccw(1);
      if (upPressed)    super.up(1);
      if (downPressed)  super.down(1);
    }
  }

  void land() {
    super.land();
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void keyPressed(int keyCode) {
    switch(keyCode) {
      case ENTER: case 'U':
        if(!isFlying()){
          super.takeOff();
        } else{
          super.land();
        }
        break;
      case SHIFT:
        shiftPressed = true; break;
      case UP   : case 'W':
        upPressed    = true; break;
      case DOWN : case 'S':
        downPressed  = true; break;
      case RIGHT: case 'D':
        rightPressed = true; break;
      case LEFT : case 'A':
        leftPressed  = true; break;
    }
  }

  void keyReleased(int keyCode) {
    switch(keyCode) {
      case SHIFT:
        shiftPressed = false; break;
      case UP   : case 'W':
        upPressed    = false; break;
      case DOWN : case 'S':
        downPressed  = false; break;
      case RIGHT: case 'D':
        rightPressed = false; break;
      case LEFT : case 'A':
        leftPressed  = false; break;
    }
  }
};
