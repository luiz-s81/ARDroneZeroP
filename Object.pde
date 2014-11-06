class Object{/* This class interit of ARMarker class*/
  static final float mMAXIMUM_HP = 100;//all object's HP cannot be more than mMAXIMUM_HP
  //3DObjectType mObj;
  float mLife;
  float mMaxLife;//each object's HP cannot be more than mMaxLife
  boolean isAlive;
  
  Object(){
    isAlive = true;
    mLife = mMaxLife = random( mMAXIMUM_HP +1);
  }
  
  void recovery(float a){
    mLife += a;
    if(mLife >= mMaxLife){
      mLife = mMaxLife;
    }
  }
  
  boolean damage(float damage){
    mLife -= damage;
    if(mLife < 0){
      isAlive = false;
    }
    return isAlive;
  }
  
  boolean detectCollisionObj(Object o){

  }
  
  private float SqrDist(Object o){
    return (o.mPos.x - mPos.x) * (o.mPos.x - mPos.x) + (o.mPos.y - mPos.y) * (o.mPos.y - mPos.y);
  }

  void drawObj(){
      //if HP is reduced, the object is becoming transparent.
      //It's an idea that user can understand easily that how much does this object remain it's hit points.
      tint( mLife2Alpha() );
      //image(mImg, mPos.x, mPos.y);
  }
  
  private int mLife2Alpha(){
    return (int)( ( mLife / mMaxLife ) * 255.0 );
  }

};


