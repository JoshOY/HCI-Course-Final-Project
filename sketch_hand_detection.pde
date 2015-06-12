//
//  HCI final project
//  by 1352847 Junpeng Ouyang
//  all rights reserved.
//

import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import g4p_controls.*;

/* Global Variables */

Capture video;
OpenCV opencv;
GWindow win;

int opMode = -1;
int prevX = 0, prevY = 0;
int handX = 0, handY = 0;
int cursorX = 320, cursorY = 0;
int folderNumMax = 256;
int currentNewFolderIndex = 0;
PImage cursor;
PImage[] folders;
int[] folderX;
int[] folderY;
int folderImgSize = 30;

String cursorImgUrl = "C:\\Users\\Administrator.PC--20140413ZHW\\Desktop\\sketch_hand_detection\\cursor.png";
String folderImgUrl = "C:\\Users\\Administrator.PC--20140413ZHW\\Desktop\\sketch_hand_detection\\folder.png";
String[] folderName;


void setup() {
    // Execute when the program start, only once.
    
    size(1280, 480);
    background(255, 255, 255);
    video = new Capture(this, 320, 240);
    opencv = new OpenCV(this, 320, 320);
    opencv.loadCascade("fist.xml");
    
    // video = new Capture(this, 640, 480);
    // opencv = new OpenCV(this, 640, 480);
    // opencv.startBackgroundSubtraction(5, 3, 0.5);
    
    video.start();

    cursor = loadImage(cursorImgUrl);
    cursor.resize(15, 15);
    
    folders = new PImage[folderNumMax];
    folderX = new int[folderNumMax];
    folderY = new int[folderNumMax];
    folderName = new String[folderNumMax];
    
    textAlign(CENTER);
    textFont(createFont("Arial", 8, true));
}


void draw() {
    scale(2);
    opencv.loadImage(video);
    
    // refill the right window
    fill(255, 255, 255);
    image(video, 0, 0);
    stroke(255, 255, 255);
    rect(320, 0, 640, 480);
    fill(0);
    
    // Update folder icons
    for (int i = 0; i < folderNumMax; ++i) {
        if (folders[i] != null) {
            image(folders[i], folderX[i], folderY[i]);
            text("folder_" + i, folderX[i] + 15, folderY[i] + 35);
        }  
    }
    
    // Update cursor in the screen  
    if (abs(handX - prevX) <= 30 && abs(handY - prevX) <= 30) {
      cursorX = cursorX + (handX - prevX) * 3;
      cursorY = cursorY + (handY - prevY) * 2;
      if (cursorX < 320) {
        cursorX = 320;
      }
      else if (cursorX > 640) {
        cursorX = 640;
      }
      if (cursorY < 0) {
        cursorY = 0;
      }
      else if (cursorY > 480) {
        cursorY = 480;
      }
    }
    image(cursor, cursorX, cursorY);
    
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    
    Rectangle[] hands = opencv.detect();
    println("Hand(s) detected: " + hands.length);
    
    int area = 0;
    int biggestHandIndex = 0;
    for (int i = 0; i < hands.length; ++i) {
        if (area < hands[i].width * hands[i].height) {
          biggestHandIndex = i;
          area = hands[i].width * hands[i].height;
        }
    }
    
    for (int i = 0; i < hands.length; ++i) {
        println("Hand[" + i + "] Position: (" + hands[i].x + ", " + hands[i].y + ")");
        if (i == biggestHandIndex) {
            stroke(255, 0, 0);
            rect(hands[i].x, hands[i].y, hands[i].width, hands[i].height);
            prevX = handX;
            prevY = handY;
            handX = (hands[i].x + hands[i].width) / 2;
            handY = (hands[i].y + hands[i].height) / 2;
            
            stroke(0, 255, 0);
            continue;
        }
        rect(hands[i].x, hands[i].y, hands[i].width, hands[i].height);
    }
    // println(opMode);
}

void captureEvent(Capture c) {
    c.read();
}

void keyPressed() {
    if (key == 'm' || key == 'M'){
    // println("Key M down!");
        opMode = 1;
    }
    else if(key == 'c' || key == 'C'){
        opMode = 2;
       
    }
    else if(key == 'd' || key == 'D'){
        opMode = 3;
    }
    else if(key == 'n' || key == 'N'){
        opMode = 4;
    }
    else {
        opMode = -1;
    }
}
 
void keyReleased(){
  if (opMode == 4) {
      folders[currentNewFolderIndex] = loadImage(folderImgUrl);
      folders[currentNewFolderIndex].resize(folderImgSize, folderImgSize);
      folderX[currentNewFolderIndex] = cursorX;
      folderY[currentNewFolderIndex] = cursorY;
  }
  opMode = -1;
}
