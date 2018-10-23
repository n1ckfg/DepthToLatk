import java.util.*;

class Col {
  color c;
  float d;
 
  Col(color _c, float _d) {
    c = _c;
    d = _d;
  }
   
}

class Palette {

  int limit = 16;
  int counter = 0;
  color[] colors;
  PImage img;
  
  Palette() {
    colors = new color[limit];   
  }
  
  Palette(int _limit) {
    limit = _limit;  
    colors = new color[limit];   
  }
  
  Palette(int _limit, PImage _img) {
    limit = _limit;  
    colors = new color[limit];   
    sample(_img);
  }
  
  Palette(PImage _img) {
    colors = new color[limit];   
    sample(_img);
  }
   
  void sample(PImage _img) {
    _img.loadPixels();
    ArrayList<Col> _imgColors = new ArrayList<Col>();
    
    for (int i=0; i<_img.pixels.length; i++) {
      color c = _img.pixels[i];
      PVector d1 = new PVector(red(c), green(c), blue(c));
      PVector d2 = new PVector(0,0,0);
      _imgColors.add(new Col(c, PVector.dist(d1, d2)));
    }
        
    Collections.sort(_imgColors, new Comparator<Col>() {
        @Override
        public int compare(Col o1, Col o2) {
            return new Float(o1.d).compareTo(o2.d);
        }
    });

    int step = int(_img.pixels.length / limit);
    for (int i=0; i<colors.length; i++) {
      colors[i] = _imgColors.get(i * step).c;
    }
    counter = limit;
    
    createImg();
  }
  
  void createImg() {
    img = createImage(limit, 1, RGB);
    img.loadPixels();
    for (int i=0; i<img.pixels.length; i++) {
      img.pixels[i] = colors[i];
    }
    img.updatePixels();
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
      println(d1 + " " + d2);
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
