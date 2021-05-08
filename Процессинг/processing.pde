int thisZ = 0;
int thisY = 0;
int thisX = 0;
int rotX = 20, prevRotX;
int rotY =20, prevRotY;
PImage img;
boolean clickFlag, turnFlag, leftClickFlag;
boolean[][][] dotArray = new boolean[16][16][16];
int[][][] colR = new int [16][16][16];
int[][][] colG = new int [16][16][16];
int[][][] colB = new int [16][16][16];
int[][][] colA = new int [16][16][16];
PFont Font1;
int[] thiscol= new int[3];

void setup() {
  thiscol[0]=255;
  thiscol[1]=255;
  thiscol[2]=255;
  size(1920, 1027, P3D);
  textAlign(CENTER, CENTER);
  Font1 = createFont("Arial Bold", 18);
  textFont(Font1);
  fillArray();
  img = loadImage("hsv.jpg");
}
void draw() {  
  background(128, 128, 128);
  image(img, 0, 700);  
  circles();
  buttons();
  mouseTick();
  fill(255);
  textSize(25);
  text("Текущий цвет:", 95, 980);
  fill(colR[thisX][thisY][thisZ], colG[thisX][thisY][thisZ], colB[thisX][thisY][thisZ]);
  rect(200, 970, 50, 30);
  drawBalls();
}


void buttons() {
  stroke(0);
  textSize(20);
  fill(255);
  textSize(25);
  text("Cube generator", 250, 20);

  fill(60);
  //rect(25, 600, 100, 40, 8);
  //rect(135, 600, 100, 40, 8);
  //rect(245, 300, 100, 40, 8);
  
  fill(255);
  textSize(20);
  text("CLEAR", 25+100/2, 640);
  text("SAVE", 135+100/2, 640);
  fill(255, 0, 0);
  text("Z:", 75, 50);
  text(thisZ, 94, 50);
  text("X:", 125, 50);
  text(thisX, 144, 50);
  text("Y:", 175, 50);
  text(thisY, 194, 50);
}
void circles() {
  stroke(255);
  for (byte x = 0; x < 16; x++) {
    for (byte y = 0; y < 16; y++) {
      if (dotArray[x][y][thisZ]) {
        fill(colR[x][y][thisZ], colG[x][y][thisZ], colB[x][y][thisZ]);
        if (colR[x][y][thisZ]==0) {
          if (colB[x][y][thisZ]==0) {
            if (colG[x][y][thisZ]==0) {
              colR[x][y][thisZ]=thiscol[0];
              colG[x][y][thisZ]=thiscol[1];
              colB[x][y][thisZ]=thiscol[2];
              print(thiscol);
            }
          }
        }
      } else { 
        fill(0);
      }
      circle(x*25+50, y*25+90, 20);
    }
  }
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

void clearCube() {
  for (byte k = 0; k < 16; k++)
    for (byte i = 0; i < 16; i++)
      for (byte j = 0; j < 16; j++) {        
        dotArray[i][j][k] = false;
        colR[i][j][k]=0;
        colG[i][j][k]=0;
        colB[i][j][k]=0;
      }
}

void saveBitmap() {
  String[] lines = new String[18];
  text("SAVED", 100, 10);
  lines[0] = "const uint32_t arot[16][256] PROGMEM = {";
  for (int z = 0; z < 16; z++) {    
    lines[z+1] = "\t{";    
    for (byte y = 0; y < 16; y++) {  
      for (byte x = 0; x < 16; x++) {
        if (x*y!=225){
        if (dotArray[x][y][z]){
        String hex = String.format("0x%02x%02x%02x",colR[x][y][z],colG[x][y][z],colB[x][y][z]);  
        print(hex);
        lines[z+1] += hex+",";
      }
        else {
        lines[z+1] += "0x000000"+",";
      }}
        else{
        if (dotArray[x][y][z]){
        String hex = String.format("0x%02x%02x%02x",colR[x][y][z],colG[x][y][z],colB[x][y][z]);  
        lines[z+1] +=hex;
      }
        else { 
        lines[z+1] += "0x000000";
      }
        }
      }
    }

    lines[z+1] += "},";
  }

  lines[17] = "};";
  
  saveStrings("../Ардуино/lines.ino", lines);
}
void mousePressed() 
{
  if (mouseY>650) {
    if (mouseY<1020) {
      if (mouseX<750) {
        color c = get(mouseX, mouseY);                                       // получаем RGB-цвет по позиции курсора
        String colors = int(red(c))+","+int(green(c))+","+int(blue(c))+"\n"; // формируем строку RGB значений
        print(colors, thisX, thisY, thisZ);    
        thiscol[0]= int(red(c));
        thiscol[1]= int(green(c));
        thiscol[2]= int(blue(c));
        colR[thisX][thisY][thisZ]= int(red(c));
        colG[thisX][thisY][thisZ]= int(green(c));
        colB[thisX][thisY][thisZ]= int(blue(c));
      }
    }
  }
}

void mouseTick() {
  if (mousePressed && (mouseButton == RIGHT)) {
    clickFlag = true;
    turnFlag = true;
  }

  noStroke();

  if (mousePressed && (mouseButton == LEFT)) {
    if (!leftClickFlag) {
      leftClickFlag = true;
      if (overRect(25, 600, 100, 40)) clearCube();
      if (overRect(135, 600, 100, 40)) saveBitmap();

      //fillArray();
      for (byte x = 0; x < 16; x++) {
        for (byte y = 0; y < 16; y++) {
          if (overCircle(x*25+50, y*25+90, 20)) {
            dotArray[x][y][thisZ] = !dotArray[x][y][thisZ];
            thisX=x;
            thisY=y;
          }
        }
      }
    }
  }
}



void mouseDragged() {
  if (turnFlag) {
    if (clickFlag) {
      clickFlag = false;
      prevRotX = mouseX;
      prevRotY = mouseY;
    }
    rotX -= prevRotX - mouseX;
    rotY -= prevRotY - mouseY;
    prevRotX = mouseX;
    prevRotY = mouseY;
  }
}

void fillArray() {
  for (byte k = 0; k < 16; k++)
    for (byte i = 0; i < 16; i++)
      for (byte j = 0; j < 16; j++) {  
        dotArray[i][j][k] = false;
        colR[i][j][k] = 0;
        colG[i][j][k] = 0;
        colB[i][j][k] = 0;
      }
}

void mouseReleased() {
  clickFlag = false;
  leftClickFlag = false;
  turnFlag = false;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  thisZ -= e;
  if (thisZ < 0) thisZ = 0;
  if (thisZ > 15) thisZ = 15;
}
void drawBalls() {
  noStroke();
  fill(255);
  lights();

  translate(1280/2+150, 360, -25*4);
  rotateY(rotX * 0.017);
  rotateX(rotY * 0.017);
  translate(-25*4+25/2, -25*4+25/2, 25*4);

  for (byte z = 0; z < 16; z++) {
    if (z == thisZ) fill(0, 255, 255);
    else fill(255);

    for (byte y = 0; y < 16; y++) {
      for (byte x = 0; x < 16; x++) {

        if (dotArray[x][y][z] == true) {
          fill(colR[x][y][z], colG[x][y][z], colB[x][y][z]);
          sphere(10);
        } else {
          fill(colR[x][y][z], colG[x][y][z], colB[x][y][z], 30);
          sphere(10);
          fill(255);
        }

        translate(25, 0, 0);
      }
      translate(-25*16, 25, 0);
    }
    translate(0, -25*16, -25);
  }
}
