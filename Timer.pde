class Timer{
  static final int mDEFAULT_TIME = 10;
  int mTime;
  PFont mTimerFont;
  color mRGB;
  char mAlpha;
  
  Timer(final int init){
    mTime = (init > 0) ? init : mDEFAULT_TIME;
    mTimerFont = loadFont("./data/");
    mRGB = new color(255, 0, 0);
    mAlpha = 255;//0(transparent), 255(no transparent)
  }
  void drawTime(final int x, final int y){
    if( x < 0 || y < 0)return;
    textFont( mTimerFont );
    fill(mRGB, mAlpha);
    text("Time : " + Integer.toString(mTime), x, y);
  }
}
