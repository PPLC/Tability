class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;
  //color blobColor;
  float dsquare;

  ArrayList<PVector> points;

  Blob(float x, float y,   float d ) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    dsquare = d;
    points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
  }

  public float GetBlobSqr()
  { 
    return dsquare;
  }

  void show() {
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

  void add(float x, float y) {
    points.add(new PVector(x, y));
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }

  boolean isNear(float x, float y) {

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

  void getPixel() {
    println("X:" + minx, "Y:" + maxy);
  }

  float getX() {
    return minx;
  }
  float getY() {
    return maxy;
  }
}
