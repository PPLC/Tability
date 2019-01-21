import processing.video.*;
import gab.opencv.*;
import hypermedia.net.*;
import netP5.*;
import oscP5.*;

import dmxP512.*;
import processing.serial.*;

//DMX
DmxP512 dmxOutput;
int universeSize=512;
boolean LANBOX=false;
String LANBOX_IP="192.168.1.77";
boolean DMXPRO=true;
String DMXPRO_PORT="COM5";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

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
float r5, g5, b5;
int count;

int startTime;

// OSC -  Network Communication
OscP5 osc;
NetAddress localHostBroadCast;
//UDP udpSend;

int port = 7400;
String ipBoroadCast = "192.168.0.255";
String LocalHost = "127.0.0.255";

//BlobDetection Vars
color trackColor; 
color trackColor2; 
color trackColor3; 
color trackColor4; 
color currentColor;

float threshold = 5;
float distThreshold = 80;

ArrayList<Blob> blobs = new ArrayList<Blob>();

String time = "000";
int initialTime;
int interval = 1000;

void setup() {
  size(800, 800);


  //DMX Object
  dmxOutput=new DmxP512(this, universeSize, false);
  if (LANBOX) {
    dmxOutput.setupLanbox(LANBOX_IP);
  }

  if (DMXPRO) {
    dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  }

  //Create NetworkObj
  osc = new OscP5(this, port);
  localHostBroadCast = new NetAddress(LocalHost, port);
  //localHostBroadCast = new NetAddress(ipBoroadCast, port);

  // Available Webcams
  String[] cameras = Capture.list();
  //printArray(cameras);

  //Captured Webcam
  //video = new Capture(this, cameras[112]);
  video = new Capture(this, cameras[17]);
  video.start();

  //tracked Colors without mouse-click

  //Red
  trackColor = color(202, 117, 62);

  //Green
  trackColor2 = color(165, 179, 121);

  //Blue
  trackColor3 = color(122, 157, 179);

  //Gelb
  trackColor4 = color(245, 223, 134);

  initialTime = millis();
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
    threshold+=1;
  } else if (key == 'x') {
    threshold-=1;
  }

  if (key == '1') {
    startTime = millis();
    println("timer started");
  } else if (key == '2') {
    int elapsed = millis() - startTime;
    println(float(elapsed) / 1000 + " seconds elapsed");
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
      currentColor = video.pixels[loc];
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
      r5 = red(trackColor4);
      g5 = green(trackColor4);
      b5 = blue(trackColor4);


      float d1 = distSq(r1, g1, b1, r2, g2, b2); 
      float d2 = distSq(r1, g1, b1, r3, g3, b3);
      float d3 = distSq(r1, g1, b1, r4, g4, b4);
      float d4 = distSq(r1, g1, b1, r5, g5, b5);

      // println(d1 + " : " + d2+ " : " + d3+ " : " + d4);

      if (d1 < threshold*threshold || d2 < threshold*threshold || d3 < threshold*threshold || d4 < threshold*threshold) {


        boolean found = false;
        for (Blob b : blobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {

          Blob b = new Blob(x, y, 1);
          blobs.add(b);
        }
      }
    }
  }

  switch(blobs.size()) {
  case 0: 
    dmxOutput.set(1, int(red(currentColor)));
    dmxOutput.set(2, int(green(currentColor)));
    dmxOutput.set(3, int(blue(currentColor)));
    break;


  case 1: 
    dmxOutput.set(1, 125);
    dmxOutput.set(2, 0);
    dmxOutput.set(3, 0);
    break;

  case 2: 
    dmxOutput.set(1, 0);
    dmxOutput.set(2, 125);
    dmxOutput.set(3, 0);
    break;

  case 3: 
    dmxOutput.set(1, 0);
    dmxOutput.set(2, 0);
    dmxOutput.set(3, 125);
    break;
  case 4: 
    dmxOutput.set(1, 125);
    dmxOutput.set(2, 125);
    dmxOutput.set(3, 0);
    break;
  }

  //println("Red: " + r1 + " Blue: " + b1 + " Green: " + g1);

  /*
   dmxOutput.set(1, 0);
   dmxOutput.set(2, 0);
   dmxOutput.set(3, 0);
   */
  /*
  int CastRed  = int(r1);
   int CastGreem = int(g1);
   int CastBlue = int(b1);
   
   if (r1 - 40 > g1 | r1 - 40 > b1 )
   {
   CastRed = 255;
   CastGreem = 0;
   CastBlue = 0;
   } else if (g1 > r1 | g1 > b1 )
   {
   CastRed = 0;
   CastGreem = 255;
   CastBlue = 0;
   } else if (b1 > r1 | b1 > g1 )
   {  
   CastRed = 0;
   CastGreem = 0;
   CastBlue = 255;
   }
   
   //println(CastRed  +":" +CastGreem+":" +CastBlue);
   
   if (blobs.size() > 0 )
   {
   if (blobs.get(0) != null) {
   
   
   dmxOutput.set(1, CastRed);
   dmxOutput.set(2, CastGreem);
   dmxOutput.set(3, CastBlue);
   
   dmxOutput.set(1, int(red(trackColor)));
   dmxOutput.set(2, int(green(trackColor)));
   dmxOutput.set(3, int(blue(trackColor)));
   
   } else {
   println("CastColor!");
   }
   }
   */




  //println(CastRed);


  // OSC zeug
  OscMessage msg = new OscMessage("");

  /*
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
   
   
   // Send RED
   msg = new OscMessage("/null/r3");
   msg.add(r3);  
   osc.send(msg, localHostBroadCast);
   //Send GREEN
   msg = new OscMessage("/null/g3");
   msg.add(g3);
   osc.send(msg, localHostBroadCast);
   //Send BLUE
   msg = new OscMessage("/null/b3");
   msg.add(b3);
   osc.send(msg, localHostBroadCast);
   
   // Send RED
   msg = new OscMessage("/null/r4");
   msg.add(r4);  
   osc.send(msg, localHostBroadCast);
   //Send GREEN
   msg = new OscMessage("/null/g4");
   msg.add(g4);
   osc.send(msg, localHostBroadCast);
   //Send BLUE
   msg = new OscMessage("/null/b4");
   msg.add(b4);
   osc.send(msg, localHostBroadCast);
   
   // Send RED
   msg = new OscMessage("/null/r5");
   msg.add(r5);  
   osc.send(msg, localHostBroadCast);
   //Send GREEN
   msg = new OscMessage("/null/g5");
   msg.add(g5);
   osc.send(msg, localHostBroadCast);
   //Send BLUE
   msg = new OscMessage("/null/b5");
   msg.add(b5);
   osc.send(msg, localHostBroadCast);
   */

  if (blobs.size() > 0)
  {
    for (int i = 0; i < blobs.size(); i++)
    {
      //SHOW BLOBS
      blobs.get(i).show();
      //println(blobs.get(i).getX());
      //println(blobs.get(i).getY());

      msg = new OscMessage("/null/"+ i + "xPos");
      msg.add(blobs.get(i).getX());
      osc.send(msg, localHostBroadCast);

      msg = new OscMessage("/null/"+ i + "yPos");
      msg.add(blobs.get(i).getY());
      osc.send(msg, localHostBroadCast);
    }
  }

  //Geht nur schwer da die Blobs bei jedem Frame gelöscht werden
  /*
   for (int i = 1; i < blobs.size(); i++)
   {
   if (blobs.size() != 0) 
   {
   if (blobs.get(i) != null)
   {
   msg = new OscMessage("/" + i + "/1" );
   msg.add(1);  
   osc.send(msg, localHostBroadCast);
   } else 
   {
   msg = new OscMessage("/" + i + "/0" );      
   msg.add(0);  
   osc.send(msg, localHostBroadCast);
   }
   }
   }
   
   */


  /*
   for (Blob b : blobs) {
   if (b.size() > 500) {
   b.show();
   // b.getPixel();
   //Object 1 x POS
   msg = new OscMessage("/null/1xPos");
   msg.add(b.getX());
   osc.send(msg, localHostBroadCast);
   msg = new OscMessage("/null/1yPos");
   msg.add(b.getY());
   osc.send(msg, localHostBroadCast);
   }
   }  
   */
  /*
  //Fenster-Text-Ausgabe
   textAlign(RIGHT);
   fill(0);
   text("distance threshold: " + distThreshold, width-10, 25);
   text("color threshold: " + threshold, width-10, 50);
   text(" red: " + r1, width-10, 75);
   text(" blue: " + b1, width-10, 100);
   text(" green: " + g1, width-10, 125);
   */
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

float returnR() {
  return r1;
}

void oscEvent(OscMessage theOscMessage) {
  float value = theOscMessage.get(0).intValue();
  println(value);
}


void sendDMXColor(int s)
{
  switch(s) {
  case 0: 
    dmxOutput.set(1, int(red(trackColor)));
    dmxOutput.set(2, int(green(trackColor)));
    dmxOutput.set(3, int(blue(trackColor)));
    break;

    /*
    
     case 1: 
     dmxOutput.set(1, int(red(trackColor)));
     dmxOutput.set(2, int(green(trackColor)));
     dmxOutput.set(3, int(blue(trackColor)));
     break;
     
     case 2: 
     dmxOutput.set(1, int(red(trackColor2)));
     dmxOutput.set(2, int(green(trackColor2)));
     dmxOutput.set(3, int(blue(trackColor2)));
     break;
     
     case 3: 
     dmxOutput.set(1, int(red(trackColor3)));
     dmxOutput.set(2, int(green(trackColor3)));
     dmxOutput.set(3, int(blue(trackColor3)));
     break;
     case 4: 
     dmxOutput.set(1, int(red(trackColor4)));
     dmxOutput.set(2, int(green(trackColor4)));
     dmxOutput.set(3, int(blue(trackColor4)));
     break;
     
     */
  }
}
