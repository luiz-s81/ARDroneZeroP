class TargetCircle{
  float mDEFAULT_RADIUS = 100;
  PVector mPos;
  float mRadius;
  
  TargetCircle(){
    mPos = new PVector( width / 2.0, height / 2.0);
    mRadius = mDEFAULT_RADIUS;
  }
  
  TargetCircle(float x, float y, float r){
    mPos = new PVector( x, y );
    mRadius = r;
  }
  
  void move(float x, float y){
     if(0 < mPos.x + x && mPos.x + x < width){
       mPos.x += x;
     }
     if(0 < mPos.y + y && mPos.y + y < height){
       mPos.y += y;
     }
  }
  
  void moveThere(int mouseX, int mouseY, float d){//d is susumu kyori
    if(d < 0) d = -d;
    float disX = mouseX - mPos.x;
    float disY = mouseY - mPos.y;
    if( abs(disX) < 1.1f){
      mPos.x = mouseX + ( (disX < 0) ? -d : d );
    }else{
      mPos.x = mouseX;
    }
    if( abs(disY) < 1.1f){
      mPos.y = mouseY + ( (disY < 0) ? -d : d );
    }else{
      mPos.y = mouseY;
    }
  }
  
  void drawCircle(){
    noFill();
    ellipseMode(CENTER);
    stroke( 255, 255, 0);//yellow
    strokeWeight(10);//
    ellipse( mPos.x, mPos.y, 2.0 * mRadius, 2.0 * mRadius);//write diameter 
  }
  
  boolean insideTargetCircle(Object o){
    //float sqrDist =   ( o.mPos.x - mPos.x ) * ( o.mPos.x - mPos.x )
    //                + ( o.mPos.y - mPos.y ) * ( o.mPos.y - mPos.y );
    //return ( sqrDist  <=  mRadius * mRadius ) ? true : false;
    return mPos.dist(o.mPos) <= mRadius;
  }
};

