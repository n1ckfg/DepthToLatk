import gab.opencv.*;
//import peasy.PeasyCam;

//PeasyCam cam;
Latk latk;
PImage depthImg, rgbImg;
PGraphics depthBuffer, rgbBuffer;
String filePath = "render";
LayoutMode layoutMode;
RenderMode renderMode;

int pointsWide = 128;
int pointsHigh = 96;
int paletteColors = 16;
float farClip = 5;

// grid render mode
int strokeLength = 40;
int curStrokeLength = strokeLength;
float strokeNoise = 0.3;
float shuffleOdds = 0.1;

// contour render mode
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

void setup() {
  size(640, 480, P2D);
  layoutMode = LayoutMode.HOLOFLIX;
  renderMode = RenderMode.GRID;
  
  settings = new Settings("settings.txt");
  
  palette = new Palette(paletteColors);
  
  if (layoutMode == LayoutMode.HOLOFLIX) {
    rgbImg = createImage(640, 480, RGB);
    depthImg = createImage(640, 480, RGB);
  } else if (layoutMode == LayoutMode.RGBDTK) {
    rgbImg = createImage(512, 424, RGB);
    depthImg = createImage(512, 424, RGB);
  }
  rgbBuffer = createGraphics(pointsWide, pointsHigh, P2D);
  depthBuffer = createGraphics(pointsWide, pointsHigh, P2D);
  
  imageMode(CORNER);
  rgbBuffer.imageMode(CORNER);
  depthBuffer.imageMode(CORNER);
  
  //for (int i = 0; i < depthLookUp.length; i++) {
    //depthLookUp[i] = rawDepthToMeters(i);
  //}

  //cam = new PeasyCam(this, 100);
  latk = new Latk();  
  //float fov = PI/3.0;
  //float cameraZ = (height/2.0) / tan(fov/2.0);
  //perspective(fov, float(width)/float(height), cameraZ/100.0, cameraZ*100.0);
  
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
    if (renderMode == RenderMode.GRID) {
      depthBuffer.beginDraw();
      shaderSetTexture(shader_color_depth, "tex0", depthBuffer);
      depthBuffer.filter(shader_color_depth);
      depthBuffer.endDraw();
      depthBuffer.save("test.png");
    } else if (renderMode == RenderMode.CONTOUR) {
      depthImg = shaderApplyEffect(shader_color_depth_flip, depthImg);
      depthImg.save("test.png");
    }
  }
  
  rgbImg.loadPixels();
  depthImg.loadPixels();
  rgbBuffer.loadPixels();
  depthBuffer.loadPixels();
  
  image(rgbBuffer,0,0);
  image(depthBuffer,rgbBuffer.width,0);
  
  LatkFrame frame = new LatkFrame();
  
  if (renderMode == RenderMode.GRID) {
    for (int y = 0; y < rgbBuffer.height; y++) {
      ArrayList<PVector> p = new ArrayList<PVector>();
      for (int x = 0; x < rgbBuffer.width; x++) {
        int loc = x + y * rgbBuffer.width;
        
        color col = palette.getNearest(rgbBuffer.pixels[loc]);
        float z = red(depthBuffer.pixels[loc]);
        
        float xx = float(x) + random(-strokeNoise, strokeNoise);
        float yy = float(y) + random(-strokeNoise, strokeNoise);
        
        if (z >= farClip) {
          p.add(new PVector(xx / float(rgbBuffer.width), 1.0 - (yy / float(rgbBuffer.width)), 1.0 - (z / 255.0)));
        }
        
        if (p.size() >= curStrokeLength) {
          curStrokeLength = int(random(strokeLength/2, strokeLength*2));
          if (random(1) < shuffleOdds) Collections.shuffle(p);
          LatkStroke stroke = new LatkStroke(p, palette.getNearest(col));
          frame.strokes.add(stroke);
          p = new ArrayList<PVector>();
        }
      }
    }
  } else if (renderMode == RenderMode.CONTOUR) {
    contours = new ArrayList<Contour>();
    opencv = new OpenCV(this, rgbImg);
    for (int i=0; i<255; i += int(255/numSlices)) {
      doContour(i);
    }
    
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
