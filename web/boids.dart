import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';
import 'package:vector_math/vector_math.dart';
import 'package:dart_webgl/dart_webgl.dart';


String vertSrc = document.getElementById('vs').text;
String fragSrc = document.getElementById('fs').text;

CanvasElement canvas;
RenderingContext gl;
Program program;
Map<String, int> attribs;
Float32List vertices;
Buffer buffer;
int aVertexPosition, aPosition;
UniformLocation uPMatrix, uVMatrix;
Matrix4 perspective, viewMatrix;
Float32List boidModel;
Buffer modelBuffer;
Flock flock;
num vWidth, vHeight;
AngleInstancedArrays ext;
num lastJump;

void main() {

  vWidth = window.innerWidth;
  vHeight = window.innerHeight;

  canvas = querySelector('#canvas');
  canvas.width = vWidth;
  canvas.height = vHeight;

  gl = canvas.getContext('webgl');
  gl.canvas.width = gl.canvas.clientWidth;
  gl.canvas.height = gl.canvas.clientHeight;

  var shaders = [
      compileShader(gl, vertSrc, VERTEX_SHADER),
      compileShader(gl, fragSrc, FRAGMENT_SHADER)];

  program = linkProgram(gl, shaders);
  gl.useProgram(program);

  gl.enable(DEPTH_TEST);
  gl.depthFunc(LEQUAL);
  gl.clearColor(0.0, 0.1, 0.1, 1);

  flock = new Flock(200);
  flock.scatter(max(vWidth, vHeight), [0, 0, 0], 1);

  var tmp = [],
      i = 0,
      l = flock.boids.length * 6;
  for (i = 0; i < l; i++) {
    tmp.add(0.0);
  }
  vertices = new Float32List.fromList(tmp);
  buffer = gl.createBuffer();

  gl.enable(DEPTH_TEST);
  gl.depthFunc(LEQUAL);
  gl.clearColor(0.8, 0.8, 0.8, 1);

  aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
  aPosition = gl.getAttribLocation(program, 'aPosition');
  uPMatrix = gl.getUniformLocation(program, 'uPMatrix');
  uVMatrix = gl.getUniformLocation(program, 'uVMatrix');

  gl.enableVertexAttribArray(aVertexPosition);
  gl.enableVertexAttribArray(aPosition);

  perspective = makePerspectiveMatrix(PI * .75, vWidth / vHeight, .1, 200.0);
  gl.uniformMatrix4fv(uPMatrix, false, perspective.storage);

  viewMatrix = new Matrix4.identity();
  viewMatrix.translate(-0.5, 0.0, -100.0);
  viewMatrix.rotateY(PI);
  gl.uniformMatrix4fv(uVMatrix, false, viewMatrix.storage);

  boidModel = new Float32List.fromList(
      [
          0.0,
          0.0,
          -1.0,
          -1.0,
          -1.0,
          1.0,
          1.0,
          -1.0,
          1.0,
          1.0,
          1.0,
          1.0,
          -1.0,
          1.0,
          1.0]);

  modelBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, modelBuffer);
  gl.bufferData(ARRAY_BUFFER, boidModel, STATIC_DRAW);

  ext = gl.getExtension('ANGLE_instanced_arrays') as AngleInstancedArrays;
  if (ext == null) throw 'WebGL extension ANGLE_instanced_arrays not loaded';

  lastJump = 0;
  update();
}


void update([num time]) {
  window.requestAnimationFrame(update);

  if (time == null) {
    time = lastJump;
  }

  flock.update(time);

  var i = 0,
      l = flock.boids.length;
  for (i = 0; i < l; i++) {
    vertices[i * 3 + 0] = flock.boids[i].pos[0];
    vertices[i * 3 + 1] = flock.boids[i].pos[1];
    vertices[i * 3 + 2] = flock.boids[i].pos[2];
  }

  if (time - lastJump > 2000) {
    lastJump = time;

    flock.goal[0] = new Random().nextDouble() * 100 - 25;
    flock.goal[1] = new Random().nextDouble() * 100 - 25;
    flock.goal[2] = new Random().nextDouble() * 100 - 25;
  }

  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);

  gl.bindBuffer(ARRAY_BUFFER, buffer);
  gl.bufferData(ARRAY_BUFFER, vertices, DYNAMIC_DRAW);
  gl.vertexAttribPointer(aPosition, 3, FLOAT, false, 0, 0);
  ext.vertexAttribDivisorAngle(aPosition, 1);

  gl.bindBuffer(ARRAY_BUFFER, modelBuffer);
  gl.vertexAttribPointer(aVertexPosition, 3, FLOAT, false, 0, 0);
  ext.drawArraysInstancedAngle(
      TRIANGLE_FAN,
      0,
      boidModel.length ~/ 3,
      flock.boids.length);
}
