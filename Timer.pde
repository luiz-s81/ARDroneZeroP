class Timer{
  static final int mDEFAULT_TIME = 10;
  int mTime;
  PFont mTimerFont;
  color mColor;
  
  Timer(final int init){
    mTime = (init > 0) ? init : mDEFAULT_TIME;
    // mTimerFont = loadFont("./data/");
    mTimerFont = createFont("Courier New Bold", 18);
    mColor = color(255, 0, 0, 255);//Red,Green,Blue and Alpha in 0(black, transparent)..255(white, intransparent)
  }
  
  void countDown(final int c){
    if(frameCount % 60 == 0){
      mTime += (mTime <= 0)? 0 : ( (c>0) ? -c : -c);
    }
  }
  
  void drawTime(final int x, final int y){
    if( x < 0 || y < 0)return;
    fill(mColor);
    textFont(mTimerFont);
    text("Time : " + Integer.toString(mTime), x, y);
  }
}
