PFont FONT;
float[] XFROM = new float[9];
float[] XTO = new float[9];
float[] YFROM = new float[9];
float[] YTO = new float[9];

public class PutCell {
  
  //member
  float boardWidth, boardHeight;
  float startX, startY;
  
  //constructor
  PutCell (float _boardWidth, float _boardHeight, float _startX, float _startY) {
    //member initialize
    boardWidth = _boardWidth;
    boardHeight = _boardHeight;
    startX = _startX;
    startY = _startY;
  }
  
  public void drawLine() {
    float cellWidth = round(boardWidth/3);
    float cellHeight = round(boardHeight/3);
    
    fill(0);
    line(startX + cellWidth, startY, startX + cellWidth, startY + boardHeight);
    line(startX + cellWidth*2, startY, startX + cellWidth*2, startY + boardHeight);
    line(startX, startY + cellHeight, startX + boardWidth, startY + cellHeight);
    line(startX, startY + cellHeight*2, startX + boardWidth, startY + cellHeight*2);
  }
  
  public void setPos() {
    for(int i = 0; i < 9; i++) {
      if (i%3 == 0) {
        XFROM[i] = startX;
        XTO[i] = XFROM[i] + round(boardWidth/3);
        YFROM[i] = startY + round(boardHeight/3) * i/3;
        YTO[i] = YFROM[i] + round(boardHeight/3);
      } else {
        XFROM[i] = XTO[i-1];
        XTO[i] = XFROM[i] + round(boardWidth/3);
        YFROM[i] = YFROM[i-1];
        YTO[i] = YFROM[i] + round(boardHeight/3);
      }
    }
  }
  
  public float getXTO(int pos) {
    return XTO[pos];
  }
  
  public float getYTO(int pos) {
    return YTO[pos];
  }
  
  public int checkCell(float checkX, float checkY) {
    int pos = -1;
    for (int i = 0; i < 9; i++) {
      if (checkX >= XFROM[i] && checkX < XTO[i]
          && checkY >= YFROM[i] && checkY < YTO[i]) {
        pos = i;
      }
    }
    
    return pos;
  }
}

public class PutOX {
  
  //member
  int oxStatus;
  float x, y, r;
  
  //constructor
  PutOX(int _oxStatus, float _x, float _y, float _r) {
    oxStatus = _oxStatus;
    x = _x;
    y = _y;
    r = _r;
  }
  
  public int getStatus() {
    return oxStatus;
  }
  
  public void changeStatus(int nowStatus) {
    if (oxStatus == 0 || /* or initialize*/ nowStatus == 0) {
      oxStatus = nowStatus;
    }
  }
  
  public void drawOX() {    
    if (oxStatus != 0) {
      if (oxStatus == 1) {
        fill(19,39,51);
        smooth();
        ellipse(x,y,r,r);
        noSmooth();
      } else if (oxStatus == 2) {
        fill(0);
        smooth();
        line(x + r/2 * cos(radians(225)), y + r/2 * sin(radians(225)),
            x + r/2 * cos(radians(45)), y + r/2 * sin(radians(45)));
        line(x + r/2 * cos(radians(315)), y + r/2 * sin(radians(315)),
            x + r/2 * cos(radians(135)), y + r/2 * sin(radians(135)));
        noSmooth();
      } else if (oxStatus == 3) {
        fill(0);
        smooth();
        textFont(FONT);
        textSize(18);
        textAlign(CENTER);
        text("good",x,y);
        noSmooth();
      } else if (oxStatus == 4) {
        fill(0);
        smooth();
        textFont(FONT);
        textSize(18);
        textAlign(CENTER);
        text("sorry",x,y);
        noSmooth();
      }
    }
  }
  
  //debug  
  void viewStatus() {
    textSize(22);
    textAlign(CENTER);
    fill(255,0,0);
    text(oxStatus,x,y);
  }
  
}

final float SX = 0;
final float W = 240;
final float SY = 0;
final float H = 240;
PutCell PC;
PutOX[] OXs = new PutOX[9];
int POS = -1; //now position
boolean TURN = true; //true:O:user, false:X:CPU
//OXs[POS].changeStatus(...0:empty, 1:O, 2:X...);
color resetClr = color(255);

void setup() {
  size(240, 310);
  background(255);
  FONT = loadFont("MS-Gothic-48.vlw");
  
  PC = new PutCell(W,H,SX,SY);
  PC.drawLine();
  PC.setPos();
  
  for (int i = 0; i < 9; i++) {
    OXs[i] = new PutOX(0,PC.getXTO(i) - 40,PC.getYTO(i) - 40,70);
  }
  
  dispReset();
}

void draw() {
  background(255);
  PC.drawLine();
  dispReset();
  
  //CPU turn
  if (TURN == false) {
    getNext();
  }
  
  //judge
  int win = 0;
  win = getSet(0,3,1);
  if (win < 9) {
    win = getSet(3,6,1);
  }
  if (win < 9) {
    win = getSet(6,9,1);
  }
  if (win < 9) {
    win = getSet(0,7,3);
  }
  if (win < 9) {
    win = getSet(1,8,3);
  }
  if (win < 9) {
    win = getSet(2,9,3);
  }
  if (win < 9) {
    win = getSet(0,9,4);
  }
  if (win < 9) {
    win = getSet(2,7,2);
  }
  
  if (win >= 9) {
    for (int i = 0; i < 9; i++) {
      OXs[i].changeStatus((win == 9)? 3:4);
    }
  }
  
  //ox objects      
  for (int i = 0; i < 9; i++) {
    OXs[i].drawOX();
  }  

  //debug  
  //  for (int i = 0; i < 9; i++) {
  //    OXs[i].viewStatus();
  //  }
  
  noLoop();
}

void getNext() {
  boolean ck = true;
  
  for (int i = 0; i < 9; i++) {
    if (OXs[i].getStatus() == 0) {
      ck = false;
    }
  }
  
  if (ck) {
    POS = -1;
  } else {
    int nextPos = -1;
    int eCnt = 0, oCnt = 0, xCnt = 0;
    
    for (int i = 0; i < 9; i++) {
      if (OXs[i].getStatus() == 0) {
        eCnt++;
      }      
      if (OXs[i].getStatus() == 1) {
        oCnt++;
      }      
      if (OXs[i].getStatus() == 2) {
        xCnt++;
      }
    }
    
    if (oCnt == 1 && OXs[4].getStatus() == 0) {
      nextPos = 4;
    } else {
      nextPos = getSet(0,3,1);
      if (nextPos == -1) {
        nextPos = getSet(3,6,1);
      }
      if (nextPos == -1) {
        nextPos = getSet(6,9,1);
      }
      if (nextPos == -1) {
        nextPos = getSet(0,7,3);
      }
      if (nextPos == -1) {
        nextPos = getSet(1,8,3);
      }
      if (nextPos == -1) {
        nextPos = getSet(2,9,3);
      }
      if (nextPos == -1) {
        nextPos = getSet(0,9,4);
      }
      if (nextPos == -1) {
        nextPos = getSet(2,7,2);
      }
      
      if (nextPos == -1) {  
        nextPos = PC.checkCell(random(SX,SX + W),random(SY,SY + H));
      }
    }
    
    if (nextPos != -1 && nextPos < 9) {
      int nextPosStatus = OXs[nextPos].getStatus();
      if (nextPosStatus == 0) {
        POS = nextPos;
      } else {
        getNext();
      }
      OXs[POS].changeStatus(2);
      TURN = true;
    }      
  }
}

int getSet(int startI, int maxI, int inc) {
  int nextPos = -1;
  int eCnt = 0, oCnt = 0, xCnt = 0;
  int[] oxSet = new int[3];
  int oxSetIndex = 0;
      
  for (int i = startI; i < maxI; i += inc) {
    if (OXs[i].getStatus() == 0) {
      eCnt++;
    }      
    if (OXs[i].getStatus() == 1) {
      oCnt++;
    }      
    if (OXs[i].getStatus() == 2) {
      xCnt++;
    }
    oxSet[oxSetIndex] = i;
    oxSetIndex++;
  }
      
  if (oCnt == 3 || xCnt == 3) {
    if (oCnt == 3) {
      nextPos = 9; //user win
    }
    if (xCnt == 3) {
      nextPos = 10; //CPU win
    }
  } else {
    if (xCnt == 2 && eCnt == 1) {
      for (int i = 0; i < 3; i++) {
        if (OXs[oxSet[i]].getStatus() == 0) {
          nextPos = oxSet[i];
        }
      }
    }
    if (oCnt == 2 && eCnt == 1) {
      for (int i = 0; i < 3; i++) {
        if (OXs[oxSet[i]].getStatus() == 0) {
          nextPos = oxSet[i];
        }
      }
    }
  }        
  return nextPos;
}

void dispReset() {
  noStroke();
  fill(resetClr);
  rectMode(CENTER);
  rect(width/2,height - 30,(width - 50)/3,30);
  
  stroke(0);
  fill(0);
  textSize(18);
  textAlign(CENTER);
  text("reset",width/2,height - 25);
}

void mousePressed() {
  if (mouseX > width/2 - (width - 50)/6 && mouseX < width/2 + (width - 50)/6 &&
      mouseY > height - 45) {
        resetClr = color(119,124,141);
        dispReset();
        loop();
  }
}

void mouseReleased() {
  resetClr = color(255);
  dispReset();
  POS = PC.checkCell(mouseX,mouseY);
  
  //user turn
  if (POS != -1 && TURN) {
    if (OXs[POS].getStatus() == 0) {
      OXs[POS].changeStatus(1);
      TURN = false;
    }
  }
  
  if (mouseX > width/2 - (width - 50)/6 && mouseX < width/2 + (width - 50)/6 &&
      mouseY > height - 45) {
        for (int i = 0; i < 9; i++) {
          OXs[i].changeStatus(0);
        }
        TURN = true;
  }
  
  loop();
}

/*
void keyPressed() {
  if (key == 's') {
    save("SN_P5_ox_" + year() + month() + day() + hour() + minute() + second() + ".png"); //save image
  }
}
*/
   