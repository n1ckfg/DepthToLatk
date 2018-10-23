class Palette {

  int limit = 16;
  int counter = 0;
  color[] colors;
  
  Palette() {
    colors = new color[limit];
  }
  
  Palette(int _limit) {
    limit = _limit;  
    colors = new color[limit];
  }
  
  color addColor(color c) {
    color returns;

    if (counter < limit) {
      colors[counter] = c;
      returns = colors[counter];
      counter++;
    } else {
      returns = getNearest(c);
    }
    
    return returns;
  }
  
  color getNearest(color c) {
    float[] distances = new float[limit];
    
    for (int i=0; i<distances.length; i++) {
      PVector d1 = new PVector(red(c), green(c), blue(c));
      PVector d2 = new PVector(red(colors[i]), green(colors[i]), blue(colors[i]));
      distances[i] = PVector.dist(d1, d2);
    }
        
    float lowestVal = distances[0];
    int lowestIndex = 0;
    
    for (int i=0; i<distances.length; i++) {
      if (distances[i] < lowestVal) {
        lowestVal = distances[i];
        lowestIndex = i;
      }
    }
    
    return colors[lowestIndex];
  }
  
}
