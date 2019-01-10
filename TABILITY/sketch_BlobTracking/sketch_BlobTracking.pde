import processing.video.*;
import gab.opencv.*;
import hypermedia.net.*;
import netP5.*;
import oscP5.*;

// Video to Capture from Webcam
Capture video;

// To get Color from captured video
OpenCV opencv;
float r1;
float g1;
float b1;
float r2;
float g2;
float b2;
float r3;
float g3;
float b3;
float r4;
float g4;
float b4;
int count;

// OSC -  Network Communication
OscP5 osc;
NetAddress localHostBroadCast;
UDP udpSend;

int port = 7400;
String ipBoroadCast = "192.168.0.255";
String LocalHost = "127.0.0.255";

//BlobDetection Vars
color trackColor; 
color trackColor2; 
color trackColor3; 
float threshold = 25;
float distThreshold = 50;

ArrayList<Blob> blobs = new ArrayList<Blob>();

void setup() {
  size(800, 800);

  //Create NetworkObj
  osc = new OscP5(this, port);
  //localHostBroadCast = new NetAddress(LocalHost, port);
  localHostBroadCast = new NetAddress(ipBoroadCast, port);

  // Available Webcams
  String[] cameras = Capture.list();
  printArray(cameras);

  //Captured Webcam
  //video = new Capture(this, cameras[112]);
  
  video = new Capture(this, cameras[17]);
  video.start();

  //tracked Colors without mouse-click
  trackColor = color(120, 20, 20);
  trackColor2 = color(180, 150, 20);
  trackColor3 = color(25, 25, 25);
}

void captureEvent(Capture video) {
  video.read();
}

void keyPressed() {
  if (key == 'a') {
    distThreshold+=5;
  } else if (key == 'z') {
    distThreshold-=5;
  }
  if (key == 's') {
    threshold+=5;
  } else if (key == 'x') {
    threshold-=5;
  }


  println(distThreshold);
}

void draw() {
 
  
  video.loadPixels();
  image(video, 0, 0);

  


  blobs.clear(); //  don't need this for multiple color blobbing


  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
        r1 = red(currentColor);
        g1 = green(currentColor);
        b1 = blue(currentColor);
        r2 = red(trackColor);
        g2 = green(trackColor);
        b2 = blue(trackColor);
        r3 = red(trackColor2);
        g3 = green(trackColor2);
        b3 = blue(trackColor2);
        r4 = red(trackColor3);
        g4 = green(trackColor3);
        b4 = blue(trackColor3);


      float d1 = distSq(r1, g1, b1, r2, g2, b2); 
      float d2 = distSq(r1, g1, b1, r3, g3, b3);
      float d3 = distSq(r1, g1, b1, r4, g4, b4);

      if (d1 < threshold*threshold || d2 < threshold*threshold || d3 < threshold*threshold) {

        boolean found = false;
        for (Blob b : blobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {
          Blob b = new Blob(x, y);
          blobs.add(b);
        }
      }
    }
  }

  //println("Red: " + r2 + " Blue: " + b2 + " Green: " + g2);

  // OSC zeug
  OscMessage msg = new OscMessage("");

  // Send RED
  msg = new OscMessage("/null/r2");
  msg.add(r2);  
  osc.send(msg, localHostBroadCast);
  //Send GREEN
  msg = new OscMessage("/null/g2");
  msg.add(g2);
  osc.send(msg, localHostBroadCast);
  //Send BLUE
  msg = new OscMessage("/null/b2");
  msg.add(b2);
  osc.send(msg, localHostBroadCast);
  //println(r1+" "+ b1 +" "+ g1+" ");
  
  for (Blob b : blobs) {
    if (b.size() > 500) {
      b.show();
      // b.getPixel();
      //Object 1 x POS
      msg = new OscMessage("/null/1xPos");
      msg.add(b.getX());
      osc.send(msg, localHostBroadCast);
      //Object 1 y Pos
      msg = new OscMessage("/null/1yPos");
      msg.add(b.getY());
      osc.send(msg, localHostBroadCast);
      //println(b.getY());
    }
  }

  //Fenster-Text-Ausgabe
  textAlign(RIGHT);
  fill(0);
  text("distance threshold: " + distThreshold, width-10, 25);
  text("color threshold: " + threshold, width-10, 50);
  text(" red: " + r1, width-10, 75);
  text(" blue: " + b1, width-10, 100);
  text(" green: " + g1, width-10, 125);
}


// Custom distance functions w/ no square root for optimization
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
  // trackColor = color(255,255,255);

  //colorMode(HSB,360,100,100);
  //color c = color(0,100,50);

  //RGB-Output for every single Blob per color that is clicked
  float r1 = red(trackColor);
  float g1 = green(trackColor);
  float b1 = blue(trackColor);
  println(r1 + " " + g1 + " " + b1);
}

float returnR(){
  return r1;
}

void oscEvent(OscMessage theOscMessage) {
  float value = theOscMessage.get(0).intValue();
  println(value);
}
