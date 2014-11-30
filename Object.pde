class Object{/* This class interit of ARMarker class*/
  static final float mMAXIMUM_HP = 100;//all object's HP cannot be more than mMAXIMUM_HP
  int mMAX_REMAINING_TIME_OF_REVIVAL = 5;
  PShape mObj;
  float mLife;
  float mMaxLife;//each object's HP cannot be more than mMaxLife=initial mLife
  boolean isAlive;//object has two state(dead / alive)
  PVector mPos;
  color mColor;
  int mRemainingTimeOfRevival;
  int mID;
  
  Object(PApplet main, final int id){
    mID = id;
    isAlive = true;
    mLife   = mMaxLife = random( mMAXIMUM_HP +1);
    mObj    = loadShape("data/retopo.obj");
    mObj.scale(50);
    mColor = color(0, 0, 0, 200);//Red,Green,Blue and Alpha in 0(black, transparent)..255(white, intransparent)
    
    mRemainingTimeOfRevival = 0;
  }
  
  void recovery(float a){
    if( !(this.isAlive) ){
      mLife = 0;
      return;
    }
    mLife += a;
    if(mLife >= mMaxLife){
      mLife = mMaxLife;
    }
  }
  
  boolean damage(float damage){
    mLife -= damage;
    if(mLife < 0){
      mRemainingTimeOfRevival = (int)(random(mMAX_REMAINING_TIME_OF_REVIVAL) )+ 1;
      isAlive = false;
    }
    return isAlive;
  }
  
  boolean reviveObj(){//this function is called by dead object
    if(this.isAlive){
      return false;
    }
    if(frameCount % 60 == 0){
      this.mRemainingTimeOfRevival -= 1;
      if(this.mRemainingTimeOfRevival <= 0){
        this.isAlive = true;
        mLife = random( mMaxLife +1);
        return true;//if isAlive changes, return true;
      }
    }
    return false;
  }


  private int mLife2Alpha(){
    return (int)( ( mLife / mMaxLife ) * 255.0 );
  }

 void drawObj(){
      //if HP is reduced, the object is becoming transparent.
      //It's an idea that user can understand easily that how much does this object remain it's hit points.
      // tint( mLife2Alpha() );

      // Light setting
      directionalLight(255,255,255,0,0,-1);
      ambientLight(100,100,100);


      // position of the 3D model
      pushMatrix();
      //translate(0, 0, 0.0);
      rotateY(PI);
      rotateZ(PI);
      shape(mObj);
      popMatrix();
  }


  void drawObjectState(){//draw debug statement
        String str = "ID";
        str += Integer.toString(mID);
        str += " : HP " + Integer.toString( (int)mLife);
        str += " : " + ( (this.isAlive) ? "Alive" : "Dead");
        str += ", remaining time = " + Integer.toString(this.mRemainingTimeOfRevival);
        textAlign(LEFT);
        fill(255, 0, 0);
        text(str, 0, height / 2 + mID * 12);
  }

};
