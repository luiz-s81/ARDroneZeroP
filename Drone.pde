class Drone extends ARDrone{
  // For keyboard controlling
  private boolean right_pressed;
  private boolean left_pressed;
  private boolean up_pressed;
  private boolean down_pressed;
  private boolean shift_pressed;

  // For video
  private final static int width = 640;
  private final static int height = 480;
  private final static int TYPE_INT_RGB = 1;
  private boolean video_available;
  private BufferedImage raw_video;
  private Graphics2D raw_graphic;
  private PImage video;

  // To hold sensor data
  private boolean flying;
  private int     battery;
  private float   alti;
  private Vec3    gyro;
  private Vec3    velo;

  // To display sensor data
  private color   mColor;
  private PFont   mFont;

  Drone(String IPaddress){
    // Call parent's constructer and connect
    super(IPaddress);
    super.connect();

    // For keyboard controlling
    right_pressed = false;
    left_pressed  = false;
    up_pressed    = false;
    down_pressed  = false;
    shift_pressed = false;

    // For video
    video_available = false;
    raw_video = new BufferedImage(width, height, TYPE_INT_RGB);
    raw_graphic = raw_video.createGraphics();
    raw_graphic.setRenderingHint(
      RenderingHints.KEY_INTERPOLATION,
      RenderingHints.VALUE_INTERPOLATION_BILINEAR
    );
    video = createImage(width, height, RGB);

    // To hold sensor data
    flying  = false;
    battery = 0;
    alti    = 0;
    gyro    = new Vec3(0,0,0);
    velo    = new Vec3(0,0,0);

    // To display sensor data
    mFont   = createFont("Courier New Bold", 18);
    mColor  = color(255, 0, 0, 255);
  }

  boolean update() {
    boolean ret = setSensorData();
    ret &= setVideo();
    move();
    return ret;
  }

  void keyPressed(int keyCode) {
    switch(keyCode) {
      case ENTER: case 'U':
        if(!flying){
          super.takeOff();
        } else{
          super.land();
        }
        break;
      case SHIFT:
        shift_pressed = true; break;
      case UP   : case 'W':
        up_pressed    = true; break;
      case DOWN : case 'S':
        down_pressed  = true; break;
      case RIGHT: case 'D':
        right_pressed = true; break;
      case LEFT : case 'A':
        left_pressed  = true; break;
    }
  }

  void keyReleased(int keyCode) {
    switch(keyCode) {
      case SHIFT:
        shift_pressed = false; break;
      case UP   : case 'W':
        up_pressed    = false; break;
      case DOWN : case 'S':
        down_pressed  = false; break;
      case RIGHT: case 'D':
        right_pressed = false; break;
      case LEFT : case 'A':
        left_pressed  = false; break;
    }
  }

  void move() {
    if (!shift_pressed) {
      if (right_pressed) super.right(1);
      if (left_pressed)  super.left(1);
      if (up_pressed)    super.forward(1);
      if (down_pressed)  super.back(1);
    } else {
      if (right_pressed) super.cw(1);
      if (left_pressed)  super.ccw(1);
      if (up_pressed)    super.up(1);
      if (down_pressed)  super.down(1);
    }
  }

  boolean setSensorData() {
    if ( super.hasSensors() ){
      flying  = super.sensors().get("flying").bool();
      battery = super.sensors().get("battery").getInt();
      alti    = super.sensors().get("altimeter").getFloat();
      gyro    = super.sensors().get("gyroscope").vec();
      velo    = super.sensors().get("velocity").vec();
      return true;
    } else {
      return false;
    }
  }

  boolean setVideo() {
    video_available = false;
    if ( super.hasVideo() ) {
      raw_graphic.drawImage(super.video().getFrame(), 0, 0, 640, 480, null);
      if (raw_video != null) {
        // img will be updated IF AND ONLY IF video is  succesfully decoded
        // Otherwise, image from old frame remains

        // fill the img with buffered frame data from drone
        raw_video.getRGB(0, 0, width, height, video.pixels, 0, width);
        video.updatePixels();
        video_available = true;
      }
    }
    return video_available;
  }

  PImage getVideo() {
    return video;
  }

  void displayBattery(final int x, final int y) {
    if( x < 0 || y < 0)return;
    fill(mColor);
    textFont(mFont);
    text("Battery : " + Integer.toString(battery), x, y);
  }

  boolean isFlying() {
    return flying;
  }

  boolean hasVideo() {
    return video_available;
  }

};

