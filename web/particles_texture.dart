import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';
import 'package:dart_webgl/dart_webgl.dart';

CanvasElement canvas;
ImageElement img;
RenderingContext gl;
Program program;
int a_position, a_texCoord;
UniformLocation u_matrix;
Float32List meshVertices = new Float32List(500 * 30);

double time = window.performance.now();
ParticlePool particles = new ParticlePool();

void main() {
  canvas = querySelector('canvas');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  img = querySelector('#texture-invader');

  gl = canvas.getContext('webgl');
  if (gl == null) {
    throw 'Unable to create WebGL context';
  }

  var vs = gl.createShader(RenderingContext.VERTEX_SHADER),
      fs = gl.createShader(RenderingContext.FRAGMENT_SHADER);

  gl.shaderSource(vs, querySelector('#vs').text);
  gl.shaderSource(fs, querySelector('#fs').text);
  gl.compileShader(vs);
  gl.compileShader(fs);

  if (!gl.getShaderParameter(vs, RenderingContext.COMPILE_STATUS)) {
    throw gl.getShaderInfoLog(vs);
  }
  if (!gl.getShaderParameter(fs, RenderingContext.COMPILE_STATUS)) {
    throw gl.getShaderInfoLog(fs);
  }

  program = gl.createProgram();
  gl.attachShader(program, vs);
  gl.attachShader(program, fs);
  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, RenderingContext.LINK_STATUS)) {
    throw gl.getProgramInfoLog(program);
  }

  gl.useProgram(program);

  a_position = gl.getAttribLocation(program, 'a_position');
  a_texCoord = gl.getAttribLocation(program, 'a_texCoord');
  u_matrix = gl.getUniformLocation(program, 'u_matrix');

  var texture = gl.createTexture();
  gl.bindTexture(RenderingContext.TEXTURE_2D, texture);
  gl.texParameteri(
      RenderingContext.TEXTURE_2D,
      RenderingContext.TEXTURE_WRAP_S,
      RenderingContext.CLAMP_TO_EDGE);
  gl.texParameteri(
      RenderingContext.TEXTURE_2D,
      RenderingContext.TEXTURE_WRAP_T,
      RenderingContext.CLAMP_TO_EDGE);
  gl.texParameteri(
      RenderingContext.TEXTURE_2D,
      RenderingContext.TEXTURE_MIN_FILTER,
      RenderingContext.NEAREST);
  gl.texParameteri(
      RenderingContext.TEXTURE_2D,
      RenderingContext.TEXTURE_MAG_FILTER,
      RenderingContext.NEAREST);

  gl.texImage2D(
      RenderingContext.TEXTURE_2D,
      0,
      RenderingContext.RGBA,
      RenderingContext.RGBA,
      RenderingContext.UNSIGNED_BYTE,
      img);

  gl.enable(RenderingContext.BLEND);
  gl.blendFunc(RenderingContext.ONE, RenderingContext.ONE);

  var vertexBuffer = gl.createBuffer();
  gl.enableVertexAttribArray(a_position);
  gl.enableVertexAttribArray(a_texCoord);

  gl.bindBuffer(RenderingContext.ARRAY_BUFFER, vertexBuffer);
  gl.vertexAttribPointer(a_position, 3, RenderingContext.FLOAT, false, 20, 0);
  gl.vertexAttribPointer(a_texCoord, 2, RenderingContext.FLOAT, false, 20, 12);

  gl.clearColor(0.1, 0.1, 0.1, 1.0);

  sizeCanvas();

  window.addEventListener('resize', onResize, false);

  tick();
}

void onResize(Event e) {
  sizeCanvas();
}

void sizeCanvas([int width, int height, double scaling]) {
  if (width == null) width = window.innerWidth;
  if (height == null) height = window.innerHeight;
  if (scaling == null) scaling = 1.0;

  var w = (width * scaling).toInt(),
      h = (height * scaling).toInt();

  canvas.width = w;
  canvas.height = h;

  gl.viewport(0, 0, w, h);


  var viewMatrix = new Float32List.fromList(
      [
          2.0,
          0.0,
          0.0,
          -1.0,
          0.0,
          2.0,
          0.0,
          1.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0]);

  viewMatrix[0] *= 1 / width;
  viewMatrix[5] *= -1 / height;
  gl.uniformMatrix4fv(u_matrix, false, viewMatrix);
}

void tick([num delta]) {
  window.requestAnimationFrame(tick);

  step(particles);
}

void step(ParticlePool particles) {
  var i,
      rand = new Random(),
      min = -12,
      max = 12,
      velx = 0,
      vely = 0,
      w = 20.0,
      h = 20.0,
      life = 80,
      num_particles = particles.elements.length,
      particle,
      direction;

  direction = rand.nextDouble() < 0.5 ? 1.0 : -1.0;

  w = h = rand.nextInt(20) * rand.nextDouble();

  for (i = 0; i < 5; i++) {
    velx = min + rand.nextInt(max - min) * direction;
    vely = min + rand.nextInt(max - min) * direction;
    particle = particles.get_free();
    particle.setup(
        window.innerWidth * 0.5,
        window.innerHeight * 0.5,
        w,
        h,
        life);
    particle.setvel(velx.toDouble(), vely.toDouble());
  }

  for (i = 0; i < num_particles; i++) {
    particle = particles.elements[i];

    if (particle.allocated) {
      if (particle.life == 0 || isInBounds(particle)) {
        particles.free(particle);
      } else {
        integrate(particle);
      }
      particle.life--;
    }
  }

  draw(particles.elements);
}

void integrate(Particle particle) {
  var rnd = new Random(),
      delta = 0.025 * rnd.nextDouble() * 0.5,
      gravity = 4 * rnd.nextDouble() * 1.5;

  particle.acc['y'] += gravity;

  particle.acc['x'] *= delta;
  particle.acc['y'] *= delta;

  particle.vel['x'] += particle.acc['x'];
  particle.vel['y'] += particle.acc['y'];

  particle.pos['x'] += particle.vel['x'];
  particle.pos['y'] += particle.vel['y'];

  particle.acc['x'] = 0.0;
  particle.acc['y'] = 0.0;
}

bool isInBounds(Particle particle) {
  var x = particle.pos['x'],
      y = particle.pos['y'],
      w = particle.size['x'],
      h = particle.size['y'],
      areaw = window.innerWidth,
      areah = window.innerHeight;

  return (x > areaw || x + w < 0 || y > areah || y + h < 0);
}

void draw(List<Particle> particles) {

  if (meshVertices.length < particles.length * 30) {
    meshVertices = new Float32List(particles.length * 30);
  }

  var quads = 0,
      quads30 = 0,
      half_res = 0.5,
      num_particles = particles.length;

  for (var i = 0; i < num_particles; i++) {

    var particle = particles[i];

    if (particle.allocated) {

      var quads30i = quads30,
          x = particle.pos['x'],
          y = particle.pos['y'],
          xx = x + particle.size['x'],
          yy = y + particle.size['y'];

      meshVertices[quads30i++] = x; // x
      meshVertices[quads30i++] = y; // y
      meshVertices[quads30i++] = 0.0; // z
      meshVertices[quads30i++] = 0.0; // s
      meshVertices[quads30i++] = 0.0; // t

      meshVertices[quads30i++] = xx;
      meshVertices[quads30i++] = y;
      meshVertices[quads30i++] = 0.0;
      meshVertices[quads30i++] = 1.0;
      meshVertices[quads30i++] = 0.0;

      meshVertices[quads30i++] = x;
      meshVertices[quads30i++] = yy;
      meshVertices[quads30i++] = 0.0;
      meshVertices[quads30i++] = 0.0;
      meshVertices[quads30i++] = 1.0;

      meshVertices[quads30i++] = x;
      meshVertices[quads30i++] = yy;
      meshVertices[quads30i++] = 0.0;
      meshVertices[quads30i++] = 0.0;
      meshVertices[quads30i++] = 1.0;

      meshVertices[quads30i++] = xx;
      meshVertices[quads30i++] = y;
      meshVertices[quads30i++] = 0.0;
      meshVertices[quads30i++] = 1.0;
      meshVertices[quads30i++] = 0.0;

      meshVertices[quads30i++] = xx;
      meshVertices[quads30i++] = yy;
      meshVertices[quads30i++] = 0.0;
      meshVertices[quads30i++] = 1.0;
      meshVertices[quads30i++] = 1.0;


      quads30 += 30;
      quads++;
    }
  }

  gl.clear(RenderingContext.COLOR_BUFFER_BIT);
  gl.bufferData(
      RenderingContext.ARRAY_BUFFER,
      meshVertices,
      RenderingContext.DYNAMIC_DRAW);
  gl.drawArrays(RenderingContext.TRIANGLES, 0, quads * 6);
}







