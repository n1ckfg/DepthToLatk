PShader shader_color_depth, shader_color_depth_flip;

PVector shaderMousePos = new PVector(0,0);
PVector shaderMouseClick = new PVector(0,0);

void setupShaders() {
  shader_color_depth = loadShader("color_depth.glsl"); 
  shader_color_depth_flip = loadShader("color_depth_flip.glsl"); 
  shaderSetSize(shader_color_depth, depthBuffer.width, depthBuffer.height);
}

void updateShaders() {
  //shaderSetMouse(shader);
  //shaderSetTime(shader);
  //shaderSetTexture(shader_depth_color, "tex0", depthBuffer);
}

//void drawShaders() {
  //filter(shader);
//}

// ~ ~ ~ ~ ~ ~ ~

void shaderSetVar(PShader ps, String name, float val) {
    ps.set(name, val);
}

void shaderSetSize(PShader ps) {
  ps.set("iResolution", float(width), float(height), 1.0);
}

void shaderSetSize(PShader ps, float w, float h) {
  ps.set("iResolution", w, h, 1.0);
}

void shaderSetMouse(PShader ps) {
  if (mousePressed) shaderMousePos = new PVector(mouseX, height - mouseY);
  ps.set("iMouse", shaderMousePos.x, shaderMousePos.y, shaderMouseClick.x, shaderMouseClick.y);
}

void shaderSetTime(PShader ps) {
  ps.set("iGlobalTime", float(millis()) / 1000.0);
}

void shaderMousePressed() {
  shaderMouseClick = new PVector(mouseX, height - mouseY);
}

void shaderMouseReleased() {
  shaderMouseClick = new PVector(-shaderMouseClick.x, -shaderMouseClick.y);
}

void shaderSetTexture(PShader ps, String name, PImage tex) {
  ps.set(name, tex);
}

PImage shaderApplyEffect(PShader ps, PImage img) {
  PGraphics temp = createGraphics(img.width, img.height, P2D);
  temp.beginDraw();
  shaderSetSize(ps, img.width, img.height);
  shaderSetTexture(ps, "tex0", img);
  temp.filter(ps);
  temp.endDraw();
  return temp.get();
}
