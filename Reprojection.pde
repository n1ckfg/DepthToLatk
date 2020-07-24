class Reprojection {
  
  PVector principalPoint, imageSize, fov;
  float fx, fy;

  Reprojection() {
    principalPoint = new PVector(320, 240);
    imageSize = new PVector(640, 480);
    fov = new PVector(66,66);
    fx = tan(radians(fov.x) / 2) * 2;
    fy = tan(radians(fov.y) / 2) * 2;
  }
  
  PVector reproject(float _x, float _y, float _z) {    
    float x = ((_x - principalPoint.x) / imageSize.x) * _z * fx;
    float y = ((_y - principalPoint.y) / imageSize.y) * _z * fy;
    float z = _z;
    
    return new PVector(x, y, z);
  }

}
