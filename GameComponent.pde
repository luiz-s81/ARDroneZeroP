/*
This file defines 2 classes:
 - TargetCircle
 - GameComponent ... every game component (score, time etc.)
*/

///////////////////////////////////////////////////////////
//                                                       //
//                 TARGET CIRCLE CLASS                   //
//                                                       //
///////////////////////////////////////////////////////////
class TargetCircle{
  private static final float DEFAULT_RADIUS = 100;
  private PVector position;
  private float radius;

  //For AttackEffect
  private int attackEffectAlpha;
  private int attackEffectDa;

  TargetCircle(){
    this(width/2.0, height/2.0, DEFAULT_RADIUS);
  }

  TargetCircle(float x, float y, float r){
    position = new PVector( x, y );
    radius = r;
    attackEffectAlpha = 5;
    attackEffectDa = 75;
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void display(boolean isShooting){
    if (!isShooting) {
      noFill();
    } else {
      // while shooting, inside of circle became red
      // (the opacity vibrate between 0 and 255)
      attackEffectAlpha += attackEffectDa;
      if(attackEffectAlpha > 255 || attackEffectAlpha < 0){
        attackEffectDa *= -1;
      }
      fill( 255, 0, 0, attackEffectAlpha);
    }
    ellipseMode(CENTER);
    stroke(#FFFF00, 128);//yellow
    strokeWeight(10);
    ellipse(position.x, position.y, 2*radius, 2*radius);//write diameter
    strokeWeight(1);
  }

  boolean isCapturing(PVector objectPos){
    return position.dist(objectPos) <= radius;
  }
};

class GameComponent{
  // game state
  private static final int GAMEOVER  = 0;
  private static final int READY     = 1;
  private static final int GAMING    = 2;
  private static final int PREPARING = 3;
  private int state;

  // game parameters
  private static final int DEFAULT_SCORE = 0;
  private int score;
  private static final int DEFAULT_TIME = 60;//seconds
  private int time;
  // The idea of "LIFE" is not introduced yet...
  //   because enemies will never attack us.
  // private static final int DEFAULT_LIFE = 100;
  // private int life;
  TargetCircle circle;

  // to display
  private PFont font;

  // to keyboard control
  private boolean isShooting;

  GameComponent(){
    circle = new TargetCircle();
    font = createFont("Courier New Bold", 24);
    state = READY;
    // parameters are reset when game start (READY->GAMING)
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void start() {
    this.start(DEFAULT_SCORE, DEFAULT_TIME);
  }
  void start(int initScore, int initTime) {
    score = initScore;
    time  = initTime;
    state = GAMING;
  }
  void abort() { // Emergency stop
    state = PREPARING;
  }
  void end() {
    if (isOnGoing()) {
      state = GAMEOVER;
    }
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  boolean isReady() {
    return state==READY;
  }
  boolean isNotReady() {
    // Not that !isReady != isNotReady
    // (if state==GAMEOVER)
    return state==PREPARING;
  }
  boolean isOnGoing() {
    return state==GAMING;
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void scoreUp(int add){
    score += add;
  }
  void countDown(){
    if (time > 0) {
      if ( ((int)frameCount) % ((int)frameRate) == 0) {
        time -= 1;
      }
    }
  }
  void update() {
    if ( isOnGoing() ) {
      countDown();
      if (time <= 0) { // end the game if time is up
        end();
      }
    } else if ( isNotReady() ) {
      state = READY;
      // This class cannot know if the drone is actually ready
      // If drone is not ready yet,
      // then main applet makes the state PREPARING
      // (using abort())
    }
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void display() {
    textSize(24);
    textFont(font);
    switch (state) {
      case PREPARING:
        displayWaitMessage(); break;
      case READY:
        displayStartWindow(); break;
      case GAMING:
        displayController(); break;
      case GAMEOVER:
        displayScoreBoard(); break;
    }
  }

  void displayWaitMessage() {
    displayBackground();
    textAlign(CENTER);
    fill(#FFFFFF);
    text("Sorry, drone is not ready yet...", width/2, height/2-50);
    text("Be patient for a second...", width/2, height/2);
  }
  void displayStartWindow() {
    displayBackground();
    textAlign(CENTER);
    fill(#FFFFFF);
    int y = 60;
    int x1 = width/4;
    int x2 = width/2;
    int x3 = width*3/4 - 20;
    int x4 = width*7/8;

    // Title
    int size=24;
    textSize(size);
    text("Control the drone to find and kill ghosts!", x2, y); y += size*1.5;

    // Instruction1 (how to play)
    size=18;
    textSize(size);
    text("Ghosts are said to haunt around ARMarkers...", x2, y); y += size;
    text("Capture 'em in the circle, and shoot 'em!",    x2, y); y += size*1.5;
    text("If a ghost dies, you will see the red grave,", x2, y); y += size;
    text("but be careful...it will soon revive...",      x2, y); y += size*1.5;
    text("Hit ENTER to start the game!!",                x2, y); y += size*4;

    // Instruction2 (how to control)
    fill(#FFFF66);
    text("Go front",                    x1, y);
    text("Go up",                       x3, y); y += size;
    text("˄",                           x1, y);
    text("˄",                           x3, y); y += size;
    text(" Go left <   > Go right",     x1, y);
    text(" Turn left <   > Turn right", x3, y); y += size;
    text("˅",                           x1, y);
    text("˅",                           x3, y); y += size;
    text("Go back",                     x1, y);
    text("Go down",                     x3, y); y += size;
    text("(w/ SHIFT)",                  x4, y); y += size*2;
    text("ENTER ... Fly the drone & start the game,    ",x2, y); y += size;
    text("          Land the drone & finish the game.  ",x2, y); y += size*2;
    text("SPACE ... Shoot the ghosts inside the circle.",x2, y);
  }
  void displayController() {
    circle.display(isShooting);
    displayScore();
    displayTime();
  }
  void displayScoreBoard() {
    displayBackground();
    textAlign(CENTER);
    fill(#FFFFFF);
    text("GAME OVER!", width/2, height/2-50);
    text(String.format("You earned %d pts!",score), width/2, height/2);
    text("Hit ENTER to continue...", width /2, height / 2 +50);
  }
  private void displayScore(){
    noStroke();
    fill(#000000, 150);
    quad(
      0,           0,
      width/3,     0,
      width/3-30, 50,
      0,          50
    );//Draw rectangle

    textAlign(LEFT);
    fill(#FFFFFF);
    text(String.format("Score : %2d", score), 10, 30);
  }
  private void displayTime(){
    noStroke();
    fill(#000000, 150);
    quad(
      width*2/3,     0,
      width,         0,
      width,        50,
      width*2/3+30, 50
    );//Draw rectangle

    textAlign(RIGHT);
    fill(#FFFFFF);
    text(String.format("Time : %2d", time), width-10, 30);
  }
  void displayBackground() {
    fill(#000000, 180);
    rect(0,0,width, height);
  }

  //--//--//--//--//--//--//--//--//--//--//--//--//--//--

  void keyPressed(int keyCode) {
    if (keyCode==ENTER || keyCode=='U') {
      switch (state) {
        case READY:
          this.start(); break;
        case GAMEOVER:
          state = READY; break;
      }
    } else if (keyCode=='X' || keyCode==' ') {
      isShooting = true;
    }
  }

  void keyReleased(int keyCode) {
    if (keyCode=='X' || keyCode==' ') {
      isShooting = false;
    }
  }
};
