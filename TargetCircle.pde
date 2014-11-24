class TargetCircle{
  static final float mDEFAULT_RADIUS = 100;
  PVector mPos;
  float mRadius;
  
  //For AttackEffect 
  int mAttackEffectAlpha;
  int mAttackEffectDa;
  
  TargetCircle(){
    this(width / 2.0, height / 2.0, mDEFAULT_RADIUS);
  }
  
  TargetCircle(float x, float y, float r){
    mPos = new PVector( x, y );
    mRadius = r;
    mAttackEffectAlpha = 5;
    mAttackEffectDa = 75;
  }
  /*
  void move(float x, float y){
     if(0 < mPos.x + x && mPos.x + x < width){
       mPos.x += x;
     }
     if(0 < mPos.y + y && mPos.y + y < height){
       mPos.y += y;
     }
  }
  */
  /*
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
  */
  
  void drawCircle(){
    noFill();
    ellipseMode(CENTER);
    stroke( 255, 255, 0, 128);//yellow
    strokeWeight(10);//
    ellipse( mPos.x, mPos.y, 2.0 * mRadius, 2.0 * mRadius);//write diameter 
  }
  /*
  boolean insideTargetCircle(Object o){
    //float sqrDist =   ( o.mPos.x - mPos.x ) * ( o.mPos.x - mPos.x )
    //                + ( o.mPos.y - mPos.y ) * ( o.mPos.y - mPos.y );
    //return ( sqrDist  <=  mRadius * mRadius ) ? true : false;
    return mPos.dist(o.mPos) <= mRadius;
  }
  */
  
  boolean insideTargetCircle(PVector objectPos){
    //float sqrDist =   ( o.mPos.x - mPos.x ) * ( o.mPos.x - mPos.x )
    //                + ( o.mPos.y - mPos.y ) * ( o.mPos.y - mPos.y );
    //return ( sqrDist  <=  mRadius * mRadius ) ? true : false;
    return mPos.dist(objectPos) <= mRadius;
  }
  
  void attackEffect(){
    if( (frameCount % 2) == 0 ){
      mAttackEffectAlpha += mAttackEffectDa;//mAttackEffectAlpha vibrate between 0 to 255
      if(mAttackEffectAlpha > 255 || mAttackEffectAlpha < 0){
        mAttackEffectDa *= -1;
      }
    }
    fill( 255, 0, 0, mAttackEffectAlpha);
    ellipseMode(CENTER);
    stroke( 255, 255, 0, 128);//yellow
    strokeWeight(10);//
    ellipse( mPos.x, mPos.y, 2.0 * mRadius, 2.0 * mRadius);//write diameter
    //DEBUG
    /*
    String str = "AttackEffectAlpha = ";
    str += Integer.toString( mAttackEffectAlpha ) + ", da : " + Integer.toString( mAttackEffectDa);
    textAlign(LEFT);
    fill(0, 255, 0);
    text(str , 0, height - 20);
    */
  }
};

