class Settings {

  int exampleInt = 0;
  float exampleFloat = 0.0;
  String exampleString = "";
  boolean exampleBoolean = false;
        
  String[] data;

  Settings(String _s) {
    try {
      data = loadStrings(_s);
      for (int i=0;i<data.length;i++) {
        if (data[i].equals("Max Frame Count")) maxFrameCount = setInt(data[i+1]);
        if (data[i].equals("Points Wide")) pointsWide = setInt(data[i+1]);
        if (data[i].equals("Points High")) pointsHigh = setInt(data[i+1]);
        if (data[i].equals("Palette Colors")) paletteColors = setInt(data[i+1]);
        if (data[i].equals("Far Clip (Grayscale)")) farClip = setFloat(data[i+1]);
        if (data[i].equals("Stroke Length")) strokeLength = setInt(data[i+1]);
        if (data[i].equals("Sphere Detail")) detail = setInt(data[i+1]);

        if (data[i].equals("Layout Mode (HOLOFLIX, RGBDTK, OU, OU_EQR, SBS, SINGLE)")) {
            if (data[i+1].equals("HOLOFLIX")) {
              layoutMode = LayoutMode.HOLOFLIX;
            } else if (data[i+1].equals("RGBDTK")) {
              layoutMode = LayoutMode.RGBDTK;
            } else if (data[i+1].equals("OU")) {
              layoutMode = LayoutMode.OU;
            } else if (data[i+1].equals("OU_EQR")) {
              layoutMode = LayoutMode.OU_EQR;
            } else if (data[i+1].equals("SBS")) {
              layoutMode = LayoutMode.SBS;
            } else if (data[i+1].equals("SINGLE")) {
              layoutMode = LayoutMode.SINGLE;
            }
        }
        
        if (data[i].equals("Vector Mode (ROWS, CONTOURS)")) {
            if (data[i+1].equals("ROWS")) {
              vectorMode = VectorMode.ROWS;
            } else if (data[i+1].equals("CONTOURS")) {
              vectorMode = VectorMode.CONTOURS;
            }
        }
        
        if (data[i].equals("Row Resolution")) rowResolution = setInt(data[i+1]);
        if (data[i].equals("Contour Approximation")) approx = setFloat(data[i+1]);
        if (data[i].equals("Contour Min Area")) minArea = setFloat(data[i+1]);
        if (data[i].equals("Contour Slices")) numSlices = setInt(data[i+1]);          
        
        //if (data[i].equals("Example Int Setting")) exampleInt = setInt(data[i+1]);
        //if (data[i].equals("Example Float Setting")) exampleFloat = setFloat(data[i+1]);
        //if (data[i].equals("Example String Setting")) exampleString = setString(data[i+1]);
        //if (data[i].equals("Example Boolean Setting")) exampleBoolean = setBoolean(data[i+1]);
      }
    } 
    catch(Exception e) {
      println("Couldn't load settings file. Using defaults.");
    }
  }

  int setInt(String _s) {
    return int(_s);
  }

  float setFloat(String _s) {
    return float(_s);
  }

  boolean setBoolean(String _s) {
    return boolean(_s);
  }
  
  String setString(String _s) {
    return ""+(_s);
  }
  
  String[] setStringArray(String _s) {
    int commaCounter=0;
    for(int j=0;j<_s.length();j++){
          if (_s.charAt(j)==char(',')){
            commaCounter++;
          }      
    }
    //println(commaCounter);
    String[] buildArray = new String[commaCounter+1];
    commaCounter=0;
    for(int k=0;k<buildArray.length;k++){
      buildArray[k] = "";
    }
    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')') && _s.charAt(i)!=char('{') && _s.charAt(i)!=char('}') && _s.charAt(i)!=char('[') && _s.charAt(i)!=char(']')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
            buildArray[commaCounter] += _s.charAt(i);
         }
       }
     }
     println(buildArray);
     return buildArray;
  }

  color setColor(String _s) {
    color endColor = color(0);
    int commaCounter=0;
    String sr = "";
    String sg = "";
    String sb = "";
    String sa = "";
    int r = 0;
    int g = 0;
    int b = 0;
    int a = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
          if (commaCounter==0) sr += _s.charAt(i);
          if (commaCounter==1) sg += _s.charAt(i);
          if (commaCounter==2) sb += _s.charAt(i); 
          if (commaCounter==3) sa += _s.charAt(i);
         }
       }
     }

    if (sr!="" && sg=="" && sb=="" && sa=="") {
      r = int(sr);
      endColor = color(r);
    }
    if (sr!="" && sg!="" && sb=="" && sa=="") {
      r = int(sr);
      g = int(sg);
      endColor = color(r, g);
    }
    if (sr!="" && sg!="" && sb!="" && sa=="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      endColor = color(r, g, b);
    }
    if (sr!="" && sg!="" && sb!="" && sa!="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      a = int(sa);
      endColor = color(r, g, b, a);
    }
      return endColor;
  }
}
