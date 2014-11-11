import saito.objloader.*;

class Object{/* This class interit of ARMarker class*/
  static final float mMAXIMUM_HP = 100;//all object's HP cannot be more than mMAXIMUM_HP
  OBJModel mObj;
  float mLife;
  float mMaxLife;//each object's HP cannot be more than mMaxLife=initial mLife
  boolean isAlive;
  PVector mPos;
  color mColor;
  
  Object(PApplet main){
    isAlive = true;
    mLife   = mMaxLife = random( mMAXIMUM_HP +1);
    mObj    = new OBJModel(main, "data/retopo.obj");
    mObj.scale(50);
    mPos    = new PVector(random(main.width), random(main.height), 0.0);
    mColor = color(0, 0, 0, 200);//Red,Green,Blue and Alpha in 0(black, transparent)..255(white, intransparent)
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
    // Not comiled yet...
    return true;
  }
  
  private float SqrDist(Object o){
    return mPos.dist(o.mPos);
  }

  void drawObj(){
      //if HP is reduced, the object is becoming transparent.
      //It's an idea that user can understand easily that how much does this object remain it's hit points.
      // tint( mLife2Alpha() );
      stroke(mColor);
      strokeWeight(1);
      
      // position of the 3D model
      pushMatrix();
      translate(mPos.x, mPos.y, mPos.z);
      rotateY(PI);
      mObj.draw();
      popMatrix();
      
      noStroke();
  }
  
  private int mLife2Alpha(){
    return (int)( ( mLife / mMaxLife ) * 255.0 );
  }

};


