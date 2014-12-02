/*
 * ARDroneZeroP - Processing game for Parrot ARDrone 2.0
 * ---------------------------------------------------------
 * The MIT Licence
 * Copyright (c) 2014 Luiz Gustavo M. Sampaio
 * https://github.com/lgmsampaio/ARDroneZeroP
 *
 * Collaborators:
 * - Luiz Gustavo Moreira Sampaio - lgmsampaio@gmail.com
 * - Kazuki Sakai
 * - Shinichi Tamura
 * - Koudai Fujii
 * With the kind consultancy of Christopher Michael Yap
 * and the supervision of professor Shigeru Kashihara.
 *
 * Strongly based on:
 * - ODC - Open Drone Control
 *     http://www.opendronecontrol.org/
 * - NyAR4psg - NyARTookit for Processing
 *     http://nyatla.jp/nyartoolkit/wp/?page_id=357
 */

import java.io.*;

Drone drone;
GameComponent game;
Enemies enemies;

void setup(){
  // setup canvas
  size(640, 480, P3D);
  frameRate(20);

  // setup components
  enemies = new Enemies(this);
  game = new GameComponent();
  drone = new Drone();
}


void draw(){
  // update drone and game state
  drone.update();
  game.update();

  // game state is strongly depend on drone's state
  //  - no video -> drone is not ready yet  (CASE 1)
  //  - landed   -> game is over            (CASE 2)
  if( drone.isVideoAvailable() ){
    // Display the video
    set(0, 0, drone.getVideo());
    if (game.isOnGoing()) {
      if(drone.isJustLanded()){ // CASE 1
        game.end();             //  -> end the game
      } else {
        // This is normal case.
        // Shoot the enemy and reflect the score
        int earned_score = enemies.update(drone.getVideo(), game.circle);
        enemies.display();
        game.scoreUp(earned_score);
      }
    }
  } else {                      // CASE 2
    game.abort();               //  -> cannot start the game
  }
  if (game.isReady()) {
    enemies.refresh();// reset the enemies' state
  }

  // Display the game controller
  game.display();
  // Display the battery state
  drone.displayBattery();
}

void keyPressed(){
  if(keyCode == ESC) {//Emergency quit
    drone.land();
  }
  game.keyPressed(keyCode);
  if (game.isReady() || game.isOnGoing()) {
    drone.keyPressed(keyCode);
  }
  if (game.isOnGoing()) {
    enemies.keyPressed(keyCode);
  }
}

void keyReleased(){
  game.keyReleased(keyCode);
  if (game.isReady() || game.isOnGoing()) {
    drone.keyReleased(keyCode);
  }
  if (game.isOnGoing()) {
    enemies.keyReleased(keyCode);
  }
}
