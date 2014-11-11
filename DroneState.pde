class DroneState{
  boolean flying;
  int battery;
  float alti;
  Vec3 gyro;
  Vec3 velo;
  color mColor;
  PFont mFont;
  
  DroneState(){
    flying  = false;
    battery = 0;
    alti    = 0;
    gyro    = new Vec3(0,0,0);
    velo    = new Vec3(0,0,0);
    mFont   = createFont("Courier New Bold", 18);
    mColor  = color(255, 0, 0, 255);
  }
  
  boolean update(ARDrone drone) {
    if ( drone.hasSensors() ){
      flying  = drone.sensors().get("flying").bool();
      battery = drone.sensors().get("battery").getInt();
      alti    = drone.sensors().get("altimeter").getFloat();
      gyro    = drone.sensors().get("gyroscope").vec();
      velo    = drone.sensors().get("velocity").vec();
      return true;
    } else {
      return false;
    }
  }
  
  void displayBattery(final int x, final int y) {
    if( x < 0 || y < 0)return;
    fill(mColor);
    textFont(mFont);
    text("Battery : " + Integer.toString(battery), x, y);
  }
  
};

