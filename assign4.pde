Ship ship;
PowerUp ruby;
Bullet[] bList;
Laser [] lList;
Alien [] aList;

//Game Status
final int GAME_START   = 0;
final int GAME_PLAYING = 1;
final int GAME_PAUSE   = 2;
final int GAME_WIN     = 3;
final int GAME_LOSE    = 4;
int status;              //Game Status
int point;               //Game Score
int expoInit;            //Explode Init Size
int countBulletFrame;    //Bullet Time Counter
int bulletNum;           //Bullet Order Number

/*--------Put Variables Here---------*/
int countLaserFrame ;
int laserNum;
int dieNum ;


String pStart = "GALIXIAN";
String sStart = "Press Enter to Start";
String pPause = "Pause";
String sPause = "Press Enter to Resume";
String pWin   = "WINNER";
String sWin   = "SCORE";
String pLose  = "BOOM";
String sLose  = "You are dead!";



void printText(
int pSize, int px, int py, String pMark, String sMark) {  
  textSize(pSize);
  text(pMark, px, py);
  fill(95, 194, 226);
  textSize(20);
  text(sMark, px, py+40);
  fill(95, 194, 226);
  textAlign(CENTER);
}

void setup() {

  status = GAME_START;
  
  bList = new Bullet[30];
  lList = new Laser[30];
  aList = new Alien[100];

  size(640, 480);
  background(0, 0, 0);
  rectMode(CENTER);
  dieNum = 0;

  ship = new Ship(width/2, 460, 3);
  ruby = new PowerUp(int(random(width)), -10);

  reset();
}

void draw() {
  background(50, 50, 50);
  noStroke();

  switch(status) {

  case GAME_START:
    /*---------Print Text-------------*/
    printText(60, width/2, height/2, pStart, sStart);
    //text("press enter", 320, 240); // replace this with printText    
    /*--------------------------------*/
    break;

  case GAME_PLAYING:
    background(50, 50, 50);

    drawHorizon();
    drawScore();
    drawLife();
    ship.display(); //Draw Ship on the Screen
    drawAlien();
    drawBullet();
    drawLaser();


    /*---------Call functions---------------*/
    shipLife(4);
    checkRubyDrop(200);
    checkRubyCatch();
    cheatKeys();    
    shootLaser(150);
    


    checkAlienDead();/*finish this function*/
    checkShipHit();  /*finish this function*/

    countBulletFrame+=1;
    countLaserFrame +=1;

    break;

  case GAME_PAUSE:     
    /*---------Print Text-------------*/
    printText(40, width/2, height/2, pPause, sPause);
    /*--------------------------------*/
    break;

  case GAME_WIN:
    /*---------Print Text-------------*/
    printText(40, width/2, height/2+80, pWin, sWin+":"+point);
    /*--------------------------------*/
    winAnimate();
    break;

  case GAME_LOSE:
 
    /*---------Print Text-------------*/
    loseAnimate();
   fill(95, 194, 226);
    printText(40, width/2, height/2, pLose, sLose);

  
    /*--------------------------------*/
    break;
  }
}

void drawHorizon() {
  stroke(153);
  line(0, 420, width, 420);
}

void drawScore() {
  noStroke();
  fill(95, 194, 226);
  textAlign(CENTER, CENTER);
  textSize(23);
  text("SCORE:"+point, width/2, 16);
}

void keyPressed() {
  if (status == GAME_PLAYING) {
    ship.keyTyped();
    cheatKeys();
    shootBullet(30);
  }
  statusCtrl();
}

/*---------Make Alien Function-------------*/
void alienMaker() {
  int i=0;
  int ix=50;
  int iy=50;  
  for (int row =0; row < 5; row++) {
    for (int col = 0; col < 12; col++) {  
      int x = ix + col * 40;
      int y = iy + row * 50;
      aList[i]= new Alien(x, y);
      i++;
      if (i==53) {
        break;
      }
    }
  }
}

void drawLife() {
  fill(230, 74, 96);
  text("LIFE:", 36, 455);
  /*---------Draw Ship Life---------*/
}

void shipLife(int Life) {
  for (int i=0; i<ship.life; i++) {
    fill(230, 74, 96);
    ellipse(78+i*25, 459, 15, 15);
    ellipseMode(CENTER);
  }
}

void drawBullet() {
  for (int i=0; i<bList.length-1; i++) {
    Bullet bullet = bList[i];
    if (bullet!=null && !bullet.gone) { // Check Array isn't empty and bullet still exist
      bullet.move();     //Move Bullet
      bullet.display();  //Draw Bullet on the Screen
      if (bullet.bY<0 || bullet.bX>width || bullet.bX<0) {
        removeBullet(bullet); //Remove Bullet from the Screen
      }
    }
  }
}

void drawLaser() {
  for (int i=0; i<lList.length-1; i++) { 
    Laser laser = lList[i];
    if (laser!=null && !laser.gone) { // Check Array isn't empty and Laser still exist
      laser.move();      //Move Laser
      laser.display();   //Draw Laser
      if (laser.lY>480) {
        removeLaser(laser); //Remove Laser from the Screen
      }
    }
  }
}

void drawAlien() {
  for (int i=0; i<aList.length-1; i++) {
    Alien alien = aList[i];
    if (alien!=null && !alien.die) { // Check Array isn't empty and alien still exist
      alien.move();    //Move Alien
      alien.display(); //Draw Alien
      /*---------Call Check Line Hit---------*/
      CheckLineHit(alien.aY);
      /*--------------------------------------*/
    }
  }
}

/*--------Check Line Hit---------*/
void CheckLineHit(int alien){  
  if (alien>420){
    status = GAME_LOSE;
  }
}
/*---------Ship Shoot-------------*/
void shootBullet(int frame) {
  if ( key == ' ' && countBulletFrame>frame) {
    if (!ship.upGrade) {
      bList[bulletNum]= new Bullet(ship.posX, ship.posY, -3, 0);
      if (bulletNum<bList.length-2) {
        bulletNum+=1;
      } else {
        bulletNum = 0;
      }
    } 
    /*---------Ship Upgrade Shoot-------------*/
    else {
      bList[bulletNum]  = new Bullet(ship.posX, ship.posY, -3, 0); 
      bList[bulletNum+1]= new Bullet(ship.posX, ship.posY, -3, 1); 
      bList[bulletNum+2]= new Bullet(ship.posX, ship.posY, -3, -1); 
      if (bulletNum<bList.length-6) {
        bulletNum+=3;
      } else {
        bulletNum = 0;
      }
    }
    countBulletFrame = 0;
  }
}

/*---------Check Alien Hit-------------*/
void checkAlienDead() {
  
  for (int i=0; i<bList.length-1; i++) {
    Bullet bullet = bList[i];
    for (int j=0; j<aList.length-1; j++) {
      Alien alien = aList[j];            
      if (bullet != null && alien != null && !bullet.gone && !alien.die // Check Array isn't empty and bullet / alien still exist
      /*------------Hit detect-------------*/      ) {
        int LENGTH = 10;
        if (
        //X
        bList[i].bX <= aList[j].aX + LENGTH &&
        bList[i].bX >= aList[j].aX - LENGTH &&
        //Y
        bList[i].bY <= aList[j].aY + LENGTH &&
          bList[i].bY >= aList[j].aY - LENGTH     
          ) {     
          removeBullet(bList[i]);
          removeAlien (aList[j]);
          point+=10;          
          dieNum+=1;
          if(dieNum == 53){
        status = GAME_WIN;
        }        
        }
      }
    }
  }
}

void shootLaser(int frame ) {
  laserNum =0;
  if (countLaserFrame==frame) {    
    for (int i = 0; i<aList.length-1; i++) {
      int ii =int (random(i));      
      if (aList[ii]!=null && !aList[ii].die) {                   
        lList[laserNum]= new Laser(aList[ii].aX, aList[ii].aY );
        if(lList[laserNum].lY>height){
          if (laserNum<lList.length-3) {
              laserNum++;
              }
           else {
        laserNum = 0;
         }
       }else{
     }
   countLaserFrame = 0;
   }
  }
 }
}

/*---------Alien Drop Laser-----------------
 
/*---------Check Laser Hit Ship-------------*/
void checkShipHit() {
  for (int i=0; i<lList.length-1; i++) {
    Laser laser = lList[i];
    if (laser!= null && !laser.gone // Check Array isn't empty and laser still exist
    /*------------Hit detect-------------*/    ) {
      int LENGTH = 10;
        if (
        //X
        lList[i].lX <= ship.posX  + LENGTH &&
        lList[i].lX >= ship.posX  - LENGTH &&
        //Y
        lList[i].lY <= ship.posY  + LENGTH &&
        lList[i].lY >= ship.posY  - LENGTH     
        ) {     
          removeLaser(lList[i]);         
          ship.life-=1;
          if (ship.life==0) {
          status = GAME_LOSE;
          }   
      /*-------do something------*/
      }
    }
  }
}

/*---------Check Win Lose------------------*/
void checkWinLose() {       
    if (ship.life==0) {
      status = GAME_LOSE;
    }     
      if(dieNum == 2){
        status = GAME_WIN;
        } 
      }        
void winAnimate() {
  int x = int(random(128))+70;
  fill(x, x, 256);
  ellipse(width/2, 200, 136, 136);
  fill(50, 50, 50);
  ellipse(width/2, 200, 120, 120);
  fill(x, x, 256);
  ellipse(width/2, 200, 101, 101);
  fill(50, 50, 50);
  ellipse(width/2, 200, 93, 93);
  ship.posX = width/2;
  ship.posY = 200;
  ship.display();
}

void loseAnimate() {
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+200, expoInit+200);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+150, expoInit+150);
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+100, expoInit+100);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+50, expoInit+50);
  fill(50, 50, 50);
  ellipse(ship.posX, ship.posY, expoInit, expoInit);
  expoInit+=5;
}

/*---------Check Ruby Hit Ship-------------*/
void checkRubyDrop(int score) {
  if (point>score) {
    ruby.show = true;
    ruby.display();
    ruby.move();
  }
}
/*---------Check Level Up------------------*/
void checkRubyCatch() {
  int LENGTH =9;
  if (
  //X
  ruby.pX <= ship.posX + LENGTH &&
  ruby.pX >= ship.posX - LENGTH &&
    //Y
  ruby.pY <= ship.posY + LENGTH &&
  ruby.pY >= ship.posY - LENGTH     
    ) {

    ship.upGrade = true;
    ruby.pX = int(random(width));
    ruby.pY = height+50;
    ruby.show = false;
  }
}
/*---------Print Text Function-------------*/


void removeBullet(Bullet obj) {
  obj.gone = true;
  obj.bX = 2000;
  obj.bY = 2000;
}

void removeLaser(Laser obj) {
  obj.gone = true;
  obj.lX = 2000;
  obj.lY = 2000;
}

void removeAlien(Alien obj) {
  obj.die = true;
  obj.aX = 1000;
  obj.aY = 1000;
}

/*---------Reset Game-------------*/
void reset() {
  for (int i=0; i<bList.length-1; i++) {
    bList[i] = null;
    lList[i] = null;
  }

  for (int i=0; i<aList.length-1; i++) {
    aList[i] = null;
  }

  point = 0;
  expoInit = 0;
  countBulletFrame = 30;
  bulletNum = 0;
  /*--------Init Variable Here---------*/
  ship.life= 3;
  laserNum = 0;

  /*-----------Call Make Alien Function--------*/
  alienMaker();

  ship.posX = width/2;
  ship.posY = 460;
  ship.upGrade = false;
  ruby.show = false;  
  ruby.pX = int(random(width));
  ruby.pY = -10;
}

/*-----------finish statusCtrl--------*/
void statusCtrl() {
  if (key == ENTER) {
    switch(status) {

    case GAME_START:
      status = GAME_PLAYING;
      break;
      /*-----------add things here--------*/
    case GAME_PLAYING:
      status = GAME_PAUSE;
      break;
    case GAME_PAUSE:
      status = GAME_PLAYING;
      break;
    case GAME_WIN:
      status = GAME_PLAYING;
      reset();
      break;
    case GAME_LOSE:
      status = GAME_PLAYING;
      reset();
      break;
    }
  }
}

void cheatKeys() {

  if (key == 'R'||key == 'r') {
    ruby.show = true;
    ruby.display();
    ruby.move();
  }
  if (key == 'Q'||key == 'q') {
    ship.upGrade = true;
  }
  if (key == 'W'||key == 'w') {
    ship.upGrade = false;
  }
  if (key == 'S'||key == 's') {
    for (int i = 0; i<aList.length-1; i++) {
      if (aList[i]!=null) {
        aList[i].aY+=50;
      }
    }
  }
}
