//import peasy.PeasyCam;

//PeasyCam cam;
Latk latk;
PImage depthImg, rgbImg;
PGraphics depthBuffer, rgbBuffer;
String filePath = "render";

int pointsWide = 128;
int pointsHigh = 96;
int strokeLength = 40;
int curStrokeLength = strokeLength;
int paletteColors = 16;
float strokeNoise = 0.3;
float shuffleOdds = 0.1;
float farClip = 5;

Palette palette;

boolean ready = true;
Settings settings;
boolean sampleDone = false;

float[] depthLookUp = new float[2048];

void setup() {
  size(640, 480, P2D);
  settings = new Settings("settings.txt");
  
  palette = new Palette(paletteColors);
  
  rgbImg = createImage(640, 480, RGB);
  depthImg = createImage(640, 480, RGB);
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
  
  rgbImg = img.get(640, 120, 640, 480);
  depthImg = img.get(0, 120, 640, 480);
    
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

  rgbBuffer.loadPixels();
  depthBuffer.loadPixels();
  
  image(rgbBuffer,0,0);
  image(depthBuffer,rgbBuffer.width,0);
  
  LatkFrame frame = new LatkFrame();
  
  for (int y = 0; y < rgbBuffer.height; y++) {
    ArrayList<PVector> p = new ArrayList<PVector>();
    for (int x = 0; x < rgbBuffer.width; x++) {
      int loc = x + y * rgbBuffer.width;
      
      color col = rgbBuffer.pixels[loc];
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

  latk.layers.get(0).frames.add(frame);
    
  fileLoop();
}

float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}
