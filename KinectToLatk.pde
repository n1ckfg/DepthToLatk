import gab.opencv.*;

Latk latk;
PImage depthImg, rgbImg;
PGraphics depthBuffer, rgbBuffer;
PGraphics maskBuffer;
String filePath = "render";
LayoutMode layoutMode;

int pointsWide = 128;
int pointsHigh = 96;
int paletteColors = 16;
float farClip = 5;

int strokeLength = 40;
int curStrokeLength = strokeLength;
float approx = 0.05;
float minArea = 20.0;
int numSlices = 20;
ArrayList<Contour> contours;
OpenCV opencv;

Palette palette;

boolean ready = true;
Settings settings;
boolean sampleDone = false;

float[] depthLookUp = new float[2048];

VertSphere vertSphere;
int detail = 100;

void setup() {
  size(640, 480, P3D);
  layoutMode = LayoutMode.HOLOFLIX;
  
  settings = new Settings("settings.txt");
  
  palette = new Palette(paletteColors);
  
  if (layoutMode == LayoutMode.HOLOFLIX) {
    rgbImg = createImage(640, 480, RGB);
    depthImg = createImage(640, 480, RGB);
  } else if (layoutMode == LayoutMode.RGBDTK) {
    rgbImg = createImage(512, 424, RGB);
    depthImg = createImage(512, 424, RGB);
  } else if (layoutMode == LayoutMode.OU || layoutMode == LayoutMode.OU_EQR) {
    rgbImg = createImage(width, height/2, RGB);
    depthImg = createImage(width, height/2, RGB);
  }
  
  rgbBuffer = createGraphics(pointsWide, pointsHigh, P2D);
  depthBuffer = createGraphics(pointsWide, pointsHigh, P2D);
 
  maskBuffer = createGraphics(rgbImg.width, rgbImg.height, P3D);

  imageMode(CORNER);
  rgbBuffer.imageMode(CORNER);
  depthBuffer.imageMode(CORNER);
  
  latk = new Latk();  

  setupShaders();
  fileSetup();
}

void draw() { 
  if (palette.img != null) {
    image(palette.img, 0, 0, width, height);
  }
  
  if (layoutMode == LayoutMode.HOLOFLIX) {
    rgbImg = img.get(640, 120, 640, 480);
    depthImg = img.get(0, 120, 640, 480);
  } else if (layoutMode == LayoutMode.RGBDTK) {
    rgbImg = img.get(0, 0, 512, 424);
    depthImg = img.get(0, 424, 512, 424);
  } else if (layoutMode == LayoutMode.OU || layoutMode == LayoutMode.OU_EQR) {
    rgbImg = img.get(0, 0, img.width, img.height/2);
    depthImg = img.get(0, img.height/2, img.width, img.height/2);
  }
  
  rgbBuffer.beginDraw();  
  rgbBuffer.image(rgbImg, 0, 0, rgbBuffer.width, rgbBuffer.height);
  rgbBuffer.endDraw();

  if (!sampleDone) {
    palette.sample(rgbBuffer);
    sampleDone = true;
  }
  
  depthBuffer.beginDraw();
  depthBuffer.image(depthImg, 0, 0, depthBuffer.width, depthBuffer.height);
  depthBuffer.endDraw();

  if (layoutMode == LayoutMode.RGBDTK) {
    depthImg = shaderApplyEffect(shader_color_depth_flip, depthImg);
  }
  
  rgbImg.loadPixels();
  depthImg.loadPixels();
  rgbBuffer.loadPixels();
  depthBuffer.loadPixels();
  
  image(rgbBuffer,0,0);
  image(depthBuffer,rgbBuffer.width,0);
  
  LatkFrame frame = new LatkFrame();
  
  contours = new ArrayList<Contour>();
  opencv = new OpenCV(this, rgbImg);
  for (int i=0; i<255; i += int(255/numSlices)) {
    doContour(i);
  }
  
  if (layoutMode != LayoutMode.OU_EQR) { 
    for (int i=0; i<contours.size(); i++) {
      Contour contour = contours.get(i);
      
      if (contour.area() >= minArea) { 
        ArrayList<PVector> pOrig = contour.getPolygonApproximation().getPoints();
        ArrayList<PVector> p = new ArrayList<PVector>();
        PVector firstPoint = pOrig.get(0);
        
        color col = getColor(rgbImg.pixels, firstPoint.x, firstPoint.y, rgbImg.width); 
        
        for (int j=0; j<pOrig.size(); j++) {
          PVector pt = pOrig.get(j);
          float z = getZ(depthImg.pixels, pt.x, pt.y, depthImg.width);
          if (z >= farClip) {
            col = getColor(rgbImg.pixels, pt.x, pt.y, rgbImg.width);          
            p.add(new PVector(pt.x / float(rgbImg.width), 1.0 - (pt.y / float(rgbImg.width)), 1.0 - (z / 255.0)));
          }   
        
          if (p.size() > curStrokeLength || (j > pOrig.size()-1 && p.size() > 0)) {
            LatkStroke stroke = new LatkStroke(p, palette.getNearest(col));
            frame.strokes.add(stroke);        
            p = new ArrayList<PVector>();
            curStrokeLength = int(random(strokeLength/2, strokeLength*2));
          }
        }
      }  
    }
  } else {
    // EQR contour version
    maskBuffer.beginDraw();
    maskBuffer.background(0);
    for (int i=0; i<contours.size(); i++) {
      Contour contour = contours.get(i);
      ArrayList<PVector> pOrig = contour.getPolygonApproximation().getPoints();
      if (contour.area() >= minArea) {  
        maskBuffer.stroke(255);
        maskBuffer.strokeWeight(2);
        maskBuffer.noFill();
        maskBuffer.beginShape();
        for (int j=0; j<pOrig.size(); j++) {
          PVector po = pOrig.get(j);
          maskBuffer.vertex(po.x, po.y);
        }
        maskBuffer.endShape();
      }
    }
    maskBuffer.endDraw();
    maskBuffer.save("test.png");
    
    vertSphere = new VertSphere(rgbImg, depthImg, maskBuffer, detail);
    println("sphere verts: " + vertSphere.verts.size());
    
    // ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
    
    ArrayList<PVector> p = new ArrayList<PVector>();
    color col = vertSphere.verts.get(0).col;
    float w = float(vertSphere.tex_depth.width);
    float h = float(vertSphere.tex_depth.height);
    for (int i = 0; i < vertSphere.verts.size(); i++) { 
      Vert v = vertSphere.verts.get(i);
      float scaler = 1000.0;
      float x = v.co.x / -scaler;
      float y = v.co.y / -scaler;
      float z = v.co.z / scaler;
      PVector co = new PVector(x, y, z);
      
      float d = PVector.dist(co, new PVector(0,0,0));
      //println("distance: " + d);
      if (d < farClip) {
        p.add(co);
      }   
      
      if (p.size() > curStrokeLength) {
        LatkStroke stroke = new LatkStroke(p, palette.getNearest(col));
        frame.strokes.add(stroke);        
        p = new ArrayList<PVector>();
        col = vertSphere.verts.get(i).col;
        curStrokeLength = int(random(strokeLength/2, strokeLength*2));
      }
    }
  }
  
  latk.layers.get(0).frames.add(frame);
    
  fileLoop();
}

float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

int getLoc(float x, float y, int w) {
  return int(x) + int(y) * w;
}

color getColor(color[] px, float x, float y, int w) {
  return px[getLoc(x, y, w)];
}

float getZ(color[] px, float x, float y, int w) {
  return red(px[getLoc(x, y, w)]);
}

void doContour(int thresh) {  
  opencv.gray();
  opencv.threshold(thresh);
  ArrayList<Contour> newContours = opencv.findContours();
  
  for (Contour contour : newContours) {
    contour.setPolygonApproximationFactor(contour.getPolygonApproximationFactor() * approx);
    contours.add(contour);
  }
}
