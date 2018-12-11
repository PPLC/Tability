import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import gab.opencv.*; 
import hypermedia.net.*; 
import netP5.*; 
import oscP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch_BlobTracking extends PApplet {







// Video to Capture from Webcam
Capture video;

// To get Color from captured video
OpenCV opencv;
float r1;
float g1;
float b1;
int count;

// OSC -  Network Communication
OscP5 osc;
NetAddress localHostBroadCast;
UDP udpSend;

int port = 7400;
String ipBoroadCast = "192.168.0.255";
String LocalHost = "127.0.0.255";

//BlobDetection Vars
int trackColor; 
float threshold = 25;
float distThreshold = 50;

ArrayList<Blob> blobs = new ArrayList<Blob>();

public void setup() {
  

  //Create NetworkObj
  osc = new OscP5(this, port);
  localHostBroadCast = new NetAddress(ipBoroadCast, port);

  // Available Webcams
  String[] cameras = Capture.list();
  printArray(cameras);

  //Captured Webcam
  video = new Capture(this, cameras[6]);
  video.start();

  //TargetColor
  trackColor = color(255, 0, 0);
}

public void captureEvent(Capture video) {
  video.read();
}

public void keyPressed() {
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

public void draw() {
  video.loadPixels();
  image(video, 0, 0);

  //Color Detection
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {

      count=0; 
      // What is current color
      int currentColor = video.pixels[count];
      r1 = red(currentColor);
      g1 = green(currentColor);
      b1 = blue(currentColor);
      count++;
      if (count > (video.width*video.height)) {
        count = 0;
      }
    }
  }
  //println(" red: " + r1 + " green: " + g1 + " blue:" + b1);


  blobs.clear();


  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      int currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d < threshold*threshold) {

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

  // OSC zeug
  OscMessage msg = new OscMessage("");

  // Send RED
  msg = new OscMessage("/null/r1");
  msg.add(r1);  
  osc.send(msg, localHostBroadCast);
  //Send GREEN
  msg = new OscMessage("/null/g1");
  msg.add(g1);
  osc.send(msg, localHostBroadCast);
  //Send BLUE
  msg = new OscMessage("/null/b1");
  msg.add(b1);
  osc.send(msg, localHostBroadCast);

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
    }
  }








  textAlign(RIGHT);
  fill(0);
  text("distance threshold: " + distThreshold, width-10, 25);
  text("color threshold: " + threshold, width-10, 50);
  text(" red: " + r1 , width-10, 75);
  text(" blue: " + b1 , width-10, 100);
  text(" green: " + g1 , width-10, 125);
}


// Custom distance functions w/ no square root for optimization
public float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


public float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

public void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
}

class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;

  ArrayList<PVector> points;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
  }

  public void show() {
    stroke(0);
    fill(255);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);

    for (PVector v : points) {
      //stroke(0, 0, 255);
      //point(v.x, v.y);
    }
  }

  public void add(float x, float y) {
    points.add(new PVector(x, y));
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }

  public float size() {
    return (maxx-minx)*(maxy-miny);
  }

  public boolean isNear(float x, float y) {

    // The Rectangle "clamping" strategy
    // float cx = max(min(x, maxx), minx);
    // float cy = max(min(y, maxy), miny);
    // float d = distSq(cx, cy, x, y);

    // Closest point in blob strategy
    float d = 10000000;
    for (PVector v : points) {
      float tempD = distSq(x, y, v.x, v.y);
      if (tempD < d) {
        d = tempD;
      }
    }

    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }

  public void getPixel() {
    println("X:" + minx, "Y:" + maxy);
  }

  public float getX() {
    return minx;
  }
  public float getY() {
    return miny;
  }
  
  
}

  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sketch_BlobTracking" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
