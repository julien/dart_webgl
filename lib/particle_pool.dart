part of dart_webgl;

class ParticlePool {
  
  List<Particle> elements = new List<Particle>();
  DoublyLinkedList freeElements = new DoublyLinkedList();
  
  ParticlePool() {
    grow();
  }
  
  void grow([int growth = 5]) {
    
    var oldsize = elements.length,
        newsize = (oldsize + growth + 1) << 0;
    
    elements.length = newsize;
    
    for (var i = oldsize; i < newsize; i++) {
      elements[i] = new Particle(i);
      freeElements.add(i);
    }
  }
  
  Particle get_free() {
    var index, particle;
    
    if (freeElements.size() < 1) {
      grow();
    }
    
    index = freeElements.remove(0);
    
    // print('index $index');
    
    particle = elements[index];
    particle.allocated = true;
    
    return particle;
  }
  
  void free(Particle particle) {
    if (particle.allocated) {
      particle.allocated = false;
      particle.reset();
      
      freeElements.add(particle.poolindex);
    }
  }
}