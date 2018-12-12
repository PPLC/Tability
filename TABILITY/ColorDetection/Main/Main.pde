
import processing.video.*;

Capture video;

void setup() {
  size(640, 480);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an 
    // element from the array returned by list():
    video = new Capture(this, cameras[1]);
    video.start();
  }
}

float r1;
float g1;
float b1;
int count;

void draw() {
  if (video.available() == true) {
    video.read();
  }
  video.loadPixels();
  image(video, 0, 0);

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

  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);
}
