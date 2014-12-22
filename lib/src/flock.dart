part of dart_webgl;

class Flock {
  int size;

  List<num> goal = [0, 0, 0];
  List<Boid> boids;

  Flock(this.size) {
    boids = new List<Boid>(this.size);
    for (var i = 0; i < size; i++) {
      boids[i] = new Boid();
    }
  }

  void scatter(num radius, List<num> origin, num maxSpeed) {
    boids.forEach((Boid b) {
      b.pos[0] = new Random().nextDouble() * radius * 2 - radius + origin[0];
      b.pos[1] = new Random().nextDouble() * radius * 2 - radius + origin[1];
      b.pos[2] = new Random().nextDouble() * radius * 2 - radius + origin[2];

      b.vel[0] = new Random().nextDouble() * maxSpeed * new Random().nextDouble() * 4 - maxSpeed * new Random().nextDouble();
      b.vel[1] = new Random().nextDouble() * maxSpeed * 2 - maxSpeed;
      b.vel[2] = new Random().nextDouble() * maxSpeed * 2 - maxSpeed;
    });
  }

  List<Boid> findNeighbours(Boid boid) {
    var out = [];

    boids.forEach((Boid b) {
      if (b.canSee(boid)) {
        out.add(b);
      }
    });

    return out;
  }

  void update(num dtime) {
    boids.forEach((Boid b) {
      var neighbours = findNeighbours(b);
      b.update(dtime, neighbours, goal);
    });
  }
}
