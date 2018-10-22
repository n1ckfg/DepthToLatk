import peasy.PeasyCam;

PeasyCam cam;
Latk latk;
PImage depthImg, rgbImg;

String fileName = "sharkMovie2.mp4";
String fileNameNoExt = "";
String filePath = "render";

int lastFrameTime = 0;
boolean ready = true;

void setup() {
  size(800, 600, P3D);
  
  setupMoviePlayer(fileName);
  fileNameNoExt = getFileNameNoExt(fileName);
  
  cam = new PeasyCam(this, 100);
  latk = new Latk();  
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/100.0, cameraZ*100.0);
  
  setupShaders();
}

void draw() {
  background(0);

  if (ready && millis() > lastFrameTime + int((1.0/latk.fps) * 1000)) {
    rgbImg = moviePlayer[0].movie.get(640, 120, 1280, 600);
    depthImg = moviePlayer[0].movie.get(0, 120, 640, 600);
    rgbImg.loadPixels();
    depthImg.loadPixels();
    
    int strokeLength = 50;
    int downRes = 10;
    ArrayList<PVector> p = new ArrayList<PVector>();
    color col = color(255);
    LatkFrame frame = new LatkFrame();
    for (int x = 0; x < rgbImg.width; x += downRes) {
      for (int y = 0; y < rgbImg.height; y += downRes) {
        int loc = x + y * rgbImg.width;
        loc = constrain(loc, 0, depthImg.pixels.length-1);
        p.add(new PVector(float(x)/float(rgbImg.width), float(y)/float(rgbImg.height), red(depthImg.pixels[loc])/float(255)));
        
        if (p.size() == 1) {
          col = rgbImg.pixels[loc];
        } else if (p.size() >= strokeLength) {
          LatkStroke stroke = new LatkStroke(p, col);
          frame.strokes.add(stroke);
          p = new ArrayList<PVector>();
        }
      }
    }

    latk.layers.get(0).frames.add(frame);
    lastFrameTime = millis();
  }
  
  latk.run();
}

String getFileNameNoExt(String s) {
  String returns = "";
  String[] temp = s.split(".");
  for (int i=0; i<temp.length-1; i++) {
    returns += temp[i];
  }
  return returns;
}
  
