/*
This file defines 2 classes:
 - EnemyBase ... manage each enemies appearance and life
 - Enemies   ... manage all enemies in associate with NYARmarker
*/
import jp.nyatla.nyar4psg.*;
import java.util.Random;
Random rand = new Random();

///////////////////////////////////////////////////////////
//                                                       //
//                   ENEMY BASE CLASS                    //
//                                                       //
///////////////////////////////////////////////////////////
class EnemyBase{
  private static final int POSSIBLE_MAX_LIFE = 1000;//all object's HP cannot be more than MAX_POSSIBLE_HP
  private int id;  // Marker ID
  private int life;
  private int maxLife;//initial life == life when they revived
  private int REVIVAL_INTERVAL = 15;//seconds
  private int timeToRevive;
  private PShape shape;

  EnemyBase(final int markerId) {
    id    = markerId;
    life  = maxLife = rand.nextInt(POSSIBLE_MAX_LIFE) + 1;
    shape = loadShape("data/retopo.obj");
    shape.scale(50);
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  boolean isAlive() {
    return (life > 0);
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  int getLife() {
    return maxLife;
  }

  void recover(){
    if ( this.isAlive() ) {   // If it is alive,
      if(life < maxLife) {    // it will recover up to it's max life
        life += 1;
      }
    } else {                  // If is dead
      if (timeToRevive > 0) { // and time remains, it keep dead...
        timeToRevive -= 1;
      } else {                // If time is up, it will revive!
        life = maxLife;
      }
    }
  }

  boolean damage(int damage){
    if (!this.isAlive()) { // You can't kill dead enemy any more.
        return false;
    }
    life -= damage;
    if(!this.isAlive()){   // If you succeed to kill it
      timeToRevive = REVIVAL_INTERVAL*(int)frameRate;
      return true;//KILLED!
    } else {
      return false;//NOT KILLED YET...
    }
  }

  void refresh() {
    life = maxLife;
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void display(){
    //if HP is reduced, the object is becoming transparent.
    //It's an idea that user can understand easily
    //that how much does this object remain it's hit points.
    //But tint does not affect to 3D object...
    // tint( mLife2Alpha() );

    // Light setting
    directionalLight(255,255,255,0,0,-1);
    ambientLight(100,100,100);

    if ( this.isAlive() ) {
      drawObj(); // Ghost it self, if it's alive
    } else {
      drawX();   // Red cross for dead ghost
    }
  }

  private void drawObj(){
    rotateX(PI);
    shape(shape);
  }

  private void drawX(){
    fill( 255, 0, 0);
    stroke( 255, 255, 255);//yellow
    strokeWeight(2);

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
  }
};

///////////////////////////////////////////////////////////
//                                                       //
//                   ENEMIES CLASS                       //
//                                                       //
///////////////////////////////////////////////////////////
class Enemies{
  private static final int MAX_ENEMIES = 10;
  private ArrayList<EnemyBase> enemiesList;

  //for the AR Markers
  private String patternPath;
  private String camparaPath;
  private MultiMarker markers;

  // for keyboard shooting
  private boolean isShooted;

  Enemies (PApplet parent) {
    // Make enemies list
    // i-th enemy correspond to i-th marker pattern.
    enemiesList = new ArrayList<EnemyBase>();
    for(int id=0 ; id < MAX_ENEMIES; ++id){
      enemiesList.add( new EnemyBase(id) );
    }

    String pathToDataFolder = dataPath("").replace("\\","/") + "/";
    // Path to the directory of pattern files (.patt)
    patternPath = pathToDataFolder + "ARMarkers/";
    // Path to camera parameter file
    camparaPath = pathToDataFolder + "camera_para.dat";
    markers = new MultiMarker(parent, width, height, camparaPath, NyAR4PsgConfig.CONFIG_DEFAULT);
    // ARmarker parameter
    markers.setLostDelay(1);
    // list of filenames of .patt files.
    String[] patterns = loadPattFilenames(patternPath);
    for(int id=0; id < enemiesList.size(); ++id){
      markers.addARMarker(patternPath + "/" + patterns[id], 80);
    }

    isShooted = false;
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  boolean isMarkerValid(int id) {
    // Set threshold of marker's life to 5
    // This value indicate how many times the marker detected continuously
    return markers.isExistMarker(id) && markers.getLife(id) > 5;
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void display(){
    // display all enemies on screen
    for(int i = 0; i < enemiesList.size(); i++){
      if( isMarkerValid(i) ){
        markers.beginTransform(i); // display on marker's coord
        enemiesList.get(i).display();
        markers.endTransform();    // recover original coord
      }
    }
  }

  int update(PImage img, TargetCircle circle){
    int score = 0;//return value
    // First, detect the marker
    markers.detectWithoutLoadPixels(img);

    // Then, update the state of each enemy
    for(int i = 0; i < enemiesList.size(); ++i){
      if( isMarkerValid(i) ){
        PVector makerPosition = center(markers.getMarkerVertex2D(i));
        if( isShooted && circle.isCapturing(makerPosition) ){ // If the enemy is inside of circle,
          if( enemiesList.get(i).damage(10) ){             // it will be damaged by the attack.
            score += enemiesList.get(i).getLife()/frameRate;      // And if it dies by the attack, score goes up
          }
        } else {                                           // If the enemy is outside of circle,
          enemiesList.get(i).recover();                    // it will recover it's HP
        }
      }
    }
    return score;
  }

  void refresh(){
    for(int i = 0; i < enemiesList.size(); ++i){
      enemiesList.get(i).refresh();
    }
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void keyPressed(int keyCode) {
    if (keyCode=='X' || keyCode==' ') {
      isShooted = true;
    }
  }
  void keyReleased(int keyCode) {
    if (keyCode=='X' || keyCode==' ') {
      isShooted = false;
    }
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  private String[] loadPattFilenames(String path){
    File folder = new File(path.replaceAll("/$","")); // remove / at end
    FilenameFilter pattFilter = new FilenameFilter(){ // filter for .patt files
      public boolean accept(File dir, String name){
        return name.toLowerCase().endsWith(".patt");
      }
    };
    return folder.list(pattFilter);
  }
  private PVector center(PVector[] positions) { // Calculate the center of given list of  positions
    int n = positions.length;
    PVector center = new PVector(0.0f, 0.0f);
    for (int i=0; i<n; ++i) {
      center.add( positions[i] );
    }
    center.mult( 1.0/n );
    return center;
  }
};
