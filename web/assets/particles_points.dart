import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:dart_webgl/dart_webgl.dart';
import 'package:vector_math/vector_math.dart';

final String vertSrc = '''precision mediump float; 
attribute vec4 aVertexPosition;
attribute vec4 aVertexVelocity;

uniform mat4 uPMatrix;
uniform mat4 uMVMatrix;

uniform float uTime;

varying float vParametricTime;

void main() {
  vParametricTime = (aVertexPosition.w / 30.0);

  vec3 currentPosition = vec3(
    aVertexPosition.x + (aVertexVelocity.x * vParametricTime * 3.0),
    aVertexPosition.y + (aVertexVelocity.y * vParametricTime),
    aVertexPosition.z + (aVertexVelocity.z * vParametricTime)
  );
  currentPosition.y -= 3.0 * vParametricTime * vParametricTime;

  gl_Position = uPMatrix * uMVMatrix * vec4(currentPosition.xyz, 1.0);
  gl_PointSize = aVertexVelocity.z * 4.0;
}
''';

final String fragSrc = '''precision mediump float;
varying float vParametricTime;

void main() {
  gl_FragColor = vec4(vParametricTime * 0.8, vParametricTime * 0.8, 1.0, 0.9 - (vParametricTime * 0.4));
}
''';

CanvasElement canvas;
RenderingContext gl;
Program program;
List<Shader> shaders = [];
Map<String, int> attribs;
Map<String, UniformLocation> uniforms;
Matrix4 pMatrix;
Matrix4 mvMatrix;
Buffer pointBuffer;

final int maxParticles = 10000;
final int maxSpawnPerFrame = 80;
final int lifeSpan = 140;
final int particleComponents = 7;
final int starty = 5;
List<num> particles = [];
num numParticles = 0;

main() {
  canvas = querySelector('#canvas');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  // setup webgl
  gl = canvas.getContext('webgl');
  gl.canvas.width = gl.canvas.clientWidth;
  gl.canvas.height = gl.canvas.clientHeight;

  // compile shaders
  shaders.add(compileShader(gl, vertSrc, VERTEX_SHADER));
  shaders.add(compileShader(gl, fragSrc, FRAGMENT_SHADER));

  // link program
  program = linkProgram(gl, shaders);

  gl.useProgram(program);

  // get attribs and uniforms
  attribs  = getAttribs(gl, program);
  uniforms = getUniforms(gl, program);

  gl.enableVertexAttribArray(attribs['aVertexPosition']);
  gl.enableVertexAttribArray(attribs['aVertexVelocity']);


  // set viewport
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

  // matrices
  pMatrix = makePerspectiveMatrix(45, canvas.clientWidth / canvas.clientHeight, 0.1, 100.0);
  mvMatrix = new Matrix4.identity();
  mvMatrix.translate(0.0, -5.0, -50.0);

  setMatrixUniforms();

  gl.disable(DEPTH_TEST);
  gl.enable(BLEND);
  gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);

  adjustParticles();

  pointBuffer = gl.createBuffer();

  animLoop();
}

void animLoop([num dt]) {
  clearContext();
  resize();
  drawScene();
  adjustParticles();
  window.requestAnimationFrame(animLoop);
}

void clearContext() {
  gl.clearColor(0.1, 0.1, 0.1, 1.0);
  gl.clear(COLOR_BUFFER_BIT);
}

void setMatrixUniforms() {
  gl.uniformMatrix4fv(uniforms['uPMatrix'], false,  pMatrix.storage);
  gl.uniformMatrix4fv(uniforms['uMVMatrix'], false, mvMatrix.storage);
}

void adjustParticles() {

  var cloned = new List.from(particles);
  var i = 0;
  var l = cloned.length;
  var old;
  var direction;

  particles = [];

  for (i; i < l; i += particleComponents) {

    if (cloned[i+3] < lifeSpan && cloned[i+1] > starty - 0.001) {
      old = new List.from(cloned.getRange(i, i + particleComponents));
      old[3] += 1.0;
      particles.addAll(old);
    }
  }

  numParticles = particles.length / particleComponents;

  if (numParticles +  maxSpawnPerFrame < maxParticles) {
    for (i = 0; i < maxSpawnPerFrame; i++) {

      direction = new Random().nextDouble() < 0.5 ? 20.0 : -20.0;

      // particle components: x, y, z, life, velx, vely, size
      particles.add(2.5 * new Random().nextDouble() - 0.75);
      particles.add(starty + new Random().nextDouble() * 2);
      particles.add(new Random().nextDouble() * 0.5);
      particles.add(0.0);
      particles.add((15.0 * new Random().nextDouble() - 10.0) * direction * 2.0);
      particles.add((3.0 + 12.0 * new Random().nextDouble()) * direction * 0.5);
      particles.add(5.0 + new Random().nextDouble() * 5.0);

      ++numParticles;
    }
  }
}

void resize() {
  var width = gl.canvas.clientWidth
    , height = gl.canvas.clientHeight;

  if (gl.canvas.width != width || gl.canvas.height != height) {
    gl.canvas.width = width;
    gl.canvas.height = height;
  }
}

void drawScene() {
  gl.bindBuffer(ARRAY_BUFFER, pointBuffer);
  gl.bufferData(ARRAY_BUFFER, new Float32List.fromList(particles), STATIC_DRAW);

  gl.vertexAttribPointer(attribs['aVertexPosition'], 4, FLOAT, false, particleComponents * Float32List.BYTES_PER_ELEMENT, 0 * Float32List.BYTES_PER_ELEMENT);
  gl.vertexAttribPointer(attribs['aVertexVelocity'], 3, FLOAT, false, particleComponents * Float32List.BYTES_PER_ELEMENT, 0 * Float32List.BYTES_PER_ELEMENT);

  gl.drawArrays(POINTS, 0, numParticles.toInt());
}
