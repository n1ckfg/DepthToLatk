import java.awt.Desktop;

int counter = 0;
boolean firstRun = true;
String openFilePath = "render";
String folderPath, filePath;
File dataFolder;
ArrayList imgNames;
String fileName = "frame";
boolean filesLoaded = false;
PImage img;
PGraphics targetImg;

//~~~~~~~~~~~~~~~~~~~~~~~~
void filesLoadedChecker() {
  if (filesLoaded) {
    nextImage(counter);
    prepGraphics();
    surface.setSize(img.width, img.height);
    firstRun = false;
  }
}

void fileLoop() {
  if (counter<imgNames.size()-1) {
    if (counter % maxFrameCount == 0) {
      if (outputCounter >= 1) {      
        saveGraphics(targetImg, true, false); // write, don't exit
      }
      outputCounter++;
    } else {
      saveGraphics(targetImg, false, false); // don't write, don't exit
    }
    counter++;
    nextImage(counter);
    prepGraphics();
  } else {
    saveGraphics(targetImg, true, true); // write and exit
  }
}

void chooseFileDialog() {
    selectInput("Choose a PNG, JPG, GIF, or TGA file.","chooseFileCallback");  
}

void chooseFileCallback(File selection){
    if (selection == null) {
      println("No folder was selected.");
      exit();
    } else {
      filePath = selection.getAbsolutePath();
      println(filePath);
      // TODO
    }
}

void chooseFolderDialog() {
    selectFolder("Choose a PNG, JPG, GIF, or TGA sequence.","chooseFolderCallback");
}

void chooseFolderCallback(File selection){
    if (selection == null) {
      println("No folder was selected.");
      exit();
    } else {
      folderPath = selection.getAbsolutePath();
      println(folderPath);
      countFrames(folderPath);     
    }
}

boolean isImage(String s) {
  s = s.toLowerCase();
  if (s.endsWith("png") || s.endsWith("jpg") || s.endsWith("jpeg") || s.endsWith("gif") || s.endsWith("tga")) {
    return true;
  } else {
    return false;
  }
}

void countFrames(String usePath) {
    imgNames = new ArrayList();
    //loads a sequence of frames from a folder
    dataFolder = new File(usePath); 
    String[] allFiles = dataFolder.list();
    for (int j=0; j<allFiles.length; j++) {
      if (isImage(allFiles[j])) imgNames.add(usePath+"/"+allFiles[j]);
    }
    if (imgNames.size()<=0) {
      exit();
    } else {
      // We need this because Processing 2, unlike Processing 1, will not automatically wait to let you pick a folder!
      String s;
      if (imgNames.size() == 1) {
        s = "image";
      } else {
        s = "images";
      }
      println("FOUND " + imgNames.size() + " " + s);
      Collections.sort(imgNames);
      filesLoaded = true;
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//reveal folder, processing 2 version

void openAppFolderHandler() {
  if (System.getProperty("os.name").equals("Mac OS X")) {
    try {
      print("Trying OS X Finder method.");
      //open(sketchPath(openFilePath));
      Desktop.getDesktop().open(new File(sketchPath("") + "/" + openFilePath));
      //open(sketchPath("ManosOsc.app/Contents/Resources/Java/" + openFilePath));
    } catch (Exception e){ }
  } else {
    try {
      print("Trying Windows Explorer method.");
      Desktop.getDesktop().open(new File(sketchPath("") + "/" + openFilePath));
    } catch (Exception e) { }
  }
}

//run at startup if you want to use app data folder--not another folder.
//This accounts for different locations and OS conventions
void scriptsFolderHandler() {
  String s = openFilePath;
  if (System.getProperty("os.name").equals("Mac OS X")) {
    try {
      print("Trying OS X Finder method.");
      openFilePath = dataPath("") + "/" + s;
    } catch (Exception e) { }
  } else {
    try {
      print("Trying Windows Explorer method.");
      openFilePath = sketchPath("") + "/data/" + s;
    } catch (Exception e) { }
  }
}

void saveGraphics(PGraphics pg, boolean write, boolean last) {
  try {
    String savePath = openFilePath + "/" + fileName + "_" + zeroPadding(counter+1,imgNames.size()) + ".png";
    println("SAVED " + savePath);
  } catch (Exception e) {
    println("Failed to save file.");  
  }
  if(write) {
    latk.layers.get(0).frames.remove(0); // bugfix, removes extra blank frame at start
    latk.write("render/output" + zeroPadding(outputCounter, 100) + ".latk");
    if (last) {
      openAppFolderHandler();
      exit();
    } else {
      latk = new Latk(this);
    }
  }
}

void nextImage(int _n) {
  String imgFile = (String) imgNames.get(_n);
  img = loadImage(imgFile);
  println("RENDERING frame " + (counter+1) + " of " + imgNames.size());
}

String zeroPadding(int _val, int _maxVal) {
  String q = ""+_maxVal;
  return nf(_val,q.length());
}

float tween(float v1, float v2, float e) {
  v1 += (v2-v1)/e;
  return v1;
}

void prepGraphics() {
  targetImg = createGraphics(img.width, img.height, P2D);
}
