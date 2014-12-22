part of dart_webgl;

class Boid {

  List<num> pos = [0, 0, 0];
  List<num> vel = [1, 0, 0];
  num rotation = 0;
  int viewDistance = 100;
  num viewArc = PI * 3;

  Function _applySteering() {

    var steeringWeights = {
      'cohesion':   0.5,
      'separation': 0.7,
      'alignment':  0.5,
      'seek':       0.3
    };

    var maxSteering = 0.2;
    var maxSpeed = 3;

    var limitForce = (List<num> f, num max) {
      var magSq = f[0] * f[0] + f[1] * f[1] + f[2] * f[2];
      if (magSq > max * max) {
        var mag = sqrt(magSq);

        f[0] = f[0] / mag * max;
        f[1] = f[1] / mag * max;
        f[2] = f[2] / mag * max;
      }
    };

    var orgWeight = 1 - steeringWeights['cohesion'] - steeringWeights['separation'] - steeringWeights['alignment'];

    return (Map <String, List<num>> steering) {
      limitForce(steering['cohesion'], maxSteering);
      limitForce(steering['separation'], 0.4);
      limitForce(steering['alignment'], maxSteering);
      limitForce(steering['seek'], 0.5);

      vel[0] += steering['cohesion'][0] * steeringWeights['cohesion'] +
                steering['separation'][0] * steeringWeights['separation'] +
                steering['alignment'][0] * steeringWeights['alignment'] +
                steering['seek'][0] * steeringWeights['seek'];

      vel[1] += steering['cohesion'][1] * steeringWeights['cohesion'] +
          steering['separation'][1] * steeringWeights['separation'] +
          steering['alignment'][1] * steeringWeights['alignment'] +
          steering['seek'][1] * steeringWeights['seek'];

      vel[2] += steering['cohesion'][2] * steeringWeights['cohesion'] +
          steering['separation'][0] * steeringWeights['separation'] +
          steering['alignment'][0] * steeringWeights['alignment'] +
          steering['seek'][0] * steeringWeights['seek'];

      limitForce(vel, maxSpeed);
    };
  }

  bool canSee(Boid other) {

    if (this == other) return false;

    var diff = [
        pos[0] - other.pos[0],
        pos[1] - other.pos[1],
        pos[2] - other.pos[2]];
    var distSq = diff[0] * diff[0] + diff[1] * diff[1] + diff[2] * diff[2];

    if (distSq < viewDistance) return false;

    var speedSq = vel[0] * vel[0] + vel[1] * vel[1] + vel[2] * vel[2];
    var angleToDir =
        (diff[0] * vel[0] + diff[1] * vel[1] + diff[2] * vel[2]) /
        (sqrt(speedSq) * sqrt(distSq));
    angleToDir = acos(angleToDir);

    return angleToDir < viewArc;
  }

  void update(num time, List<Boid> neighbours, List<num> goal) {

    var steering = {
      'cohesion':   [0, 0, 0],
      'separation': [0, 0, 0],
      'alignment':  [0, 0, 0],
      'seek': [      goal[0] - pos[0],
                     goal[1] - pos[1],
                     goal[2] - pos[2]
      ]
    };

    if (neighbours.length > 0) {
      var l = neighbours.length;

      neighbours.forEach((Boid b) {

        steering['cohesion'][0] += b.pos[0] / l;
        steering['cohesion'][1] += b.pos[1] / l;
        steering['cohesion'][2] += b.pos[2] / l;

        steering['separation'][0] += b.pos[0] - pos[0];
        steering['separation'][1] += b.pos[1] - pos[1];
        steering['separation'][2] += b.pos[2] - pos[2];

        steering['cohesion'][0] += b.vel[0] / l;
        steering['cohesion'][1] += b.vel[1] / l;
        steering['cohesion'][2] += b.vel[2] / l;
      });

      steering['cohesion'][0] = steering['cohesion'][0] - pos[0];
      steering['cohesion'][1] = steering['cohesion'][1] - pos[1];
      steering['cohesion'][2] = steering['cohesion'][2] - pos[2];
    }

    _applySteering()(steering);

    pos[0] += vel[0];
    pos[1] += vel[1];
    pos[2] += vel[2];
  }
}

