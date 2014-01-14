part of glh;

class Vec2 {
  Float32List _data;
  
  Vec2(double x, double y) {
    _data = new Float32List.fromList([x, y]);
  }

  double operator[](int idx) {  return _data[idx]; }
  operator +(Vec2 b) { _data[0] += b[0]; _data[1] += b[1]; }
  operator -(Vec2 b) { _data[0] -= b[0]; _data[1] -= b[1]; }
  operator *(Vec2 b) { _data[0] *= b[0]; _data[1] *= b[1]; }
  operator /(Vec2 b) { _data[0] /= b[0]; _data[1] /= b[1]; }

  double angle([double val]) {
    var len;
    if (val != null) {
      len = length();
      _data[0] = cos(val) * len;
      _data[1] = sin(val) * len;
    }
    return atan2(_data[1], _data[0]);
  }
  
  double length([double val]) {
    var angle;
    if (val != null) {
      angle = angle();
      _data[0] = cos(angle) * val;
      _data[1] = sin(angle) * val;
    } 
    return sqrt(_data[0] * _data[0] + _data[1] * _data[1]);
  }
}