float[][] field;
int resolution = 10;
int cols, rows;
float increment = 0.1;
float zOffset = 0;

float isovalue = 0.5;

class CPoint {
  float x;
  float y;
  float value;
  
  CPoint(float x, float y, float value) {
    this.x = x;
    this.y = y;
    this.value = value;
  }
}

void setup() {
  size(1920, 1080, P2D);
  frameRate(30);
  cols = width / resolution + 1;
  rows = height / resolution + 1;
  field = new float[cols][rows];
}

void draw() {
  background(127);
 
  float xOffset = 0;
  
  for (int i = 0; i < cols; i++) {
    float yOffset = 0;
    xOffset += increment;
    
    for (int j = 0; j < rows; j++) {
      field[i][j] = noise(xOffset, yOffset, zOffset);
      yOffset += increment;
    }
  }
  
  //zOffset += 0.02;

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      stroke(field[i][j] * 255);
      strokeWeight(resolution * 0.4);
      point(i * resolution, j * resolution);
    }
  }
  
  for (int i = 0; i < cols - 1; i++) {
    for (int j = 0; j < rows - 1; j++) {
      float x = i * resolution;
      float y = j * resolution;
      CPoint tl = new CPoint(x, y, field[i][j]);
      CPoint tr = new CPoint(x + resolution, y, field[i + 1][j]);
      CPoint br = new CPoint(x + resolution, y + resolution, field[i + 1][j + 1]);
      CPoint bl = new CPoint(x, y + resolution, field[i][j + 1]);

      int state = getState(step(tl.value), step(tr.value), step(br.value), step(bl.value));

      stroke(255);
      strokeWeight(1);
      
      switch(state) {
        case 1:
        case 14:
          line(interpolate(tl, bl), interpolate(bl, br));
          break;
        case 2:
        case 13:
          line(interpolate(tr, br), interpolate(bl, br));
          break;
        case 3:
        case 12:
          line(interpolate(tl, bl), interpolate(tr, br));
          break;
        case 4:
        case 11:
          line(interpolate(tl, tr), interpolate(tr, br));
          break;
        case 5:
          line(interpolate(tl, bl), interpolate(tl, tr));
          line(interpolate(bl, br), interpolate(tr, br));
          break;
        case 6:
        case 9:
          line(interpolate(tl, tr), interpolate(bl, br));
          break;
        case 7:
        case 8:
          line(interpolate(tl, bl), interpolate(tl, tr));
          break;
        case 10:
          line(interpolate(tl, bl), interpolate(bl, br));
          line(interpolate(tl, tr), interpolate(tr, br));
          break;
        default:
          break;
      }
    }
  }
}

void line(PVector v1, PVector v2) {
  line(v1.x, v1.y, v2.x, v2.y);
}

int getState(int a, int b, int c, int d) {
  return a * 8 + b * 4 + c * 2 + d * 1;
}


int step(float value) {
  if (value >= isovalue) {
    return 1;
  }
  
  return 0;
}

float getT(CPoint fv1, CPoint fv2) {
  float v2 = max(fv2.value, fv1.value); 
  float v1 = min(fv2.value, fv1.value);
  return (isovalue - v1) / (v2 - v1);
} //<>//

PVector interpolate(CPoint v1, CPoint v2) {
  float t = getT(v1, v2);
  float x = int((1 - t) * v1.x + t * v2.x);
  float y = int((1 - t) * v1.y + t * v2.y);
  return new PVector(x, y);
}

void mouseWheel(MouseEvent event) {
  zOffset += 0.02 * event.getCount();
}
