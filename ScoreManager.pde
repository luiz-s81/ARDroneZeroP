class ScoreManager{
   int mScore;
   String mStr;
   PFont scoreFont;
   color mColor;
   
   
   ScoreManager(int initScore){
     mScore = initScore;
     mStr = new String("Score : ");
     // scoreFont = loadFont("./data/BuxtonSketch-48.vlw");
     scoreFont = createFont("Courier New Bold", 18);
     mColor = color(255, 0, 0, 255);//Red,Green,Blue and Alpha in 0(black, transparent)..255(white, intransparent)
   }
   
   void set(int score){
     mScore = score;
   }
   
   void add(int add){
     mScore += add;
   }
   
   void drawScore(int x, int y){
     if(x < 0 || y < 0)return;
     fill(mColor);
     textFont(scoreFont);
     text( mStr + Integer.toString(mScore), x, y);
   }
   
};

