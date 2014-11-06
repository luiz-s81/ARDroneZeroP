class ScoreManager{
   int mScore;
   String mStr;
   PFont scoreFont;
   color mRGB;
   char mAlpha;
   
   
   ScoreManager(int initScore){
     mScore = initScore;
     mStr = new String("Score : ");
     scoreFont = loadFont("./data/BuxtonSketch-48.vlw");
     textFont(scoreFont);
     mRGB = new color(255, 0, 0);
     mAlpha = 255;
   }
   
   void set(int score){
     mScore = score;
   }
   
   void add(int add){
     mScore += add;
   }
   
   void drawScore(int x, int y){
     if(x < 0 || y < 0)return;
     fill(mRGB, mAlpha);
     text( mStr + Integer.toString(mScore), x, y);
   }
   
};

