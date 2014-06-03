part of dart_webgl;

class Particle {
  
  int poolindex;
  Map<String, double> pos =  {'x': 0.0, 'y': 0.0};
  Map<String, double> vel =  {'x': 0.0, 'y': 0.0};
  Map<String, double> acc =  {'x': 0.0, 'y': 0.0};
  Map<String, double> size = {'x': 0.0, 'y': 0.0};
  int life = 0;
  bool allocated = false;
  
  Particle(int this.poolindex);
  
  void setup(double x, double y, double w, double h, int l) {
    pos['x'] = x;  
    pos['y'] = y;
    size['x'] = w; 
    size['y'] = h;
    life = l;
  }
  
  void setvel(double x, double y) {
    vel['x'] = x; 
    vel['y'] = y;
  }
  
  void reset() {
    setup(0.0, 0.0, 0.0, 0.0, 0);
    setvel(0.0, 0.0);
    acc['x'] = 0.0;
    acc['y'] = 0.0;
  }
}