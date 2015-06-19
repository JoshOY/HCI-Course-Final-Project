//
//  HCI final project
//  by 1352847 Junpeng Ouyang
//  all rights reserved.
//

import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import java.util.Iterator;

/* IMPORTANT: PLEASE CHANGE THE DIRECTORY VARIABLE TO 
  YOUR ACTUAL DIRECTORY WHICH CONTAINS THIS PROGRAM. */

String directory = "C:\\Users\\Administrator.PC--20140413ZHW\\Desktop\\sketch_hand_detection\\";

/* Global Variables */

Capture video;
OpenCV opencv;

int opMode = -1;
int prevX = 0, prevY = 0;
int handX = 0, handY = 0;
int cursorX = 320, cursorY = 0;
int folderNumMax = 256;
PImage cursor;
int folderImgSize = 30;

String cursorImgUrl = directory + "img\\cursor.png";
String folderImgUrl = directory + "img\\folder.png";

ArrayList<Folder> folderList;
Folder folderSelected = null;

class Folder {
    private PImage img;
    private int posX;
    private int posY;
    private String folderName;
    private boolean deleted;
    
    public int getX() { return this.posX; }
    public int getY() { return this.posY; }
    public String getFolderName() { return this.folderName; }
    
    public Folder() {
        this.img = loadImage(folderImgUrl);
        img.resize(folderImgSize, folderImgSize);
        this.deleted = false;
    }
    
    public Folder setPos(int x, int y) {
        this.posX = x;
        this.posY = y;
        return this;
    }
    
    public Folder setFolderName(String name) {
        this.folderName = name;
        return this;      
    }
    
    /*
    Function onDraw
    This function will be called every time on draw()
    */
    public void onDraw() {
        image(this.img, this.posX, this.posY);
        text(folderName, this.posX + folderImgSize / 2, this.posY + folderImgSize + 5);
    }
    
    public void delete() {
        this.deleted = true;
        this.posX = -200;
        this.posY = -200;
    }
}


void setup() {
    // Execute when the program start, only once.
    
    size(1280, 480);
    background(255, 255, 255);
    video = new Capture(this, 320, 240);
    opencv = new OpenCV(this, 320, 320);
    
    // Load cascade file
    opencv.loadCascade("aGest.xml");
    
    // Start the camera
    video.start();

    cursor = loadImage(cursorImgUrl);
    cursor.resize(15, 15);
    
    folderList = new ArrayList();
    
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
    folderSelected = null;
    Iterator<Folder> it = folderList.iterator();
    while (it.hasNext()) {
      Folder currentFolder = it.next();
      if ( (currentFolder.getX() <= cursorX) &&
           (currentFolder.getX() + folderImgSize >= cursorX) &&
           (currentFolder.getY() <= cursorX) &&
           (currentFolder.getY() + folderImgSize >= cursorY) ) {
           folderSelected = currentFolder;
      }
      currentFolder.onDraw();
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
      else if (cursorY > 240) {
          cursorY = 240;
      }
    }
    
    
    // Draw an rectangle on folder which is selected.
    if (folderSelected != null) {
        noFill();
        stroke(0, 0, 255);
        strokeWeight(1);
        rect(folderSelected.getX() - 5, folderSelected.getY() - 5, folderImgSize + 10, folderImgSize + 10);
    }
    
    // Draw cursor
    image(cursor, cursorX, cursorY);
    
    
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    
    Rectangle[] hands = opencv.detect();
    // println("Hand(s) detected: " + hands.length);
    
    int area = 0;
    int biggestHandIndex = 0;
    for (int i = 0; i < hands.length; ++i) {
        if (area < hands[i].width * hands[i].height) {
            biggestHandIndex = i;
            area = hands[i].width * hands[i].height;
        }
    }
    
    for (int i = 0; i < hands.length; ++i) {
        // println("Hand[" + i + "] Position: (" + hands[i].x + ", " + hands[i].y + ")");
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
    // Case: Moving
    if (key == 'm' || key == 'M'){
        opMode = 1;
        if (folderSelected != null) {
            folderSelected.setPos(cursorX, cursorY);
        }
    }
    // Case: Copy
    else if(key == 'c' || key == 'C'){
        opMode = 2;
    }
    // Case: Delete
    else if(key == 'd' || key == 'D'){
        opMode = 3;
    }
    // Case: Create
    else if(key == 'n' || key == 'N'){
        opMode = 4;
    }
    else {
        opMode = -1;
    }
}
 
void keyReleased() {
  if (opMode == 2) {
      if (folderSelected != null) {
            Folder nf = new Folder();
            nf.setFolderName(folderSelected.getFolderName() + "_copy")
              .setPos(cursorX, cursorY + folderImgSize);
            folderList.add(nf);
            println("A new folder copyed!");
      }
  }
  else if (opMode == 3) {
      if (folderSelected != null) {
          folderSelected.delete();
          folderSelected = null;    
      }
  }
  else if (opMode == 4) {
      Folder nf = new Folder();
      nf.setFolderName("Folder_" + folderList.size())
        .setPos(cursorX, cursorY);
      folderList.add(nf);
      println("A new folder created!");
  }
  opMode = -1;
}


