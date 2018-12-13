import gab.opencv.*;

import hypermedia.net.*;
import netP5.*;
import oscP5.*;

import processing.video.*;


OscP5 osc;
NetAddress localHostBroadCast;
UDP udpSend;

int port = 7400;
String ipBoroadCast = "192.168.0.255";
String LocalHost = "127.0.0.255";
float testFloat = 1;

Capture video;
OpenCV opencv;

float r1;
float g1;
float b1;
int count;
void setup() {
  size(800, 600);
  background(0);

  //udpSend= new UDP(this, port, LocalHost);
  //udpSend.log(true);

  osc = new OscP5(this, port);
  localHostBroadCast = new NetAddress(ipBoroadCast, port);
  
  // Camera Zeug
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[112]);
  video.start();
}

void draw() {
  // Camera Zeug 
  video.loadPixels();
  image(video, 0,0);
  

  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {

      count=0; 
      // What is current color
      color currentColor = video.pixels[count];
      r1 = red(currentColor);
      g1 = green(currentColor);
      b1 = blue(currentColor);
      count++;
      if (count > (video.width*video.height)) {
        count = 0;
      }
    }
  }

  println("Red: " + r1 + " Blue: " + b1 + " Green: " + g1);

    //println(" red: " + r1 + " green: " + g1 + " blue:" + b1);
  
  if((r1 > g1) && (r1 > b1)){
    println("red");
  }
  if((b1 > r1) && (b1 > g1)){
    println("blue");
  }
  if((g1 > r1) && (g1 > b1)){
    println("green");
  }
  
  
  // OSC zeug
  OscMessage msg = new OscMessage("");
  
  msg = new OscMessage("/null/r1");
  msg.add(r1);  
    osc.send(msg, localHostBroadCast);
    
  msg = new OscMessage("/null/g1");
  msg.add(g1);
    osc.send(msg, localHostBroadCast);
    
  msg = new OscMessage("/null/b1");
  msg.add(b1);
    osc.send(msg, localHostBroadCast);
 
}
  

// Recive OSC Message

void oscEvent(OscMessage theOscMessage) {
  float value = theOscMessage.get(0).intValue();
  println(value);
}

void mousePressed() {
  testFloat++;
}

void captureEvent(Capture video) {
  // Read image from the camera
  video.read();
}
