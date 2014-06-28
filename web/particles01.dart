import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';
import 'package:vector_math/vector_math.dart';

int MAX_NUMBER_OF_PARTICLES = 1000,
    MAX_SPAWN_PER_FRAME = 10,
    PARTICLE_COMPONENTS = 7,
    START_Y = -10;

double LIFESPAN = 120.0;

CanvasElement canvas;
RenderingContext gl;
Program program;

int aVertexPosition, 
    aVertexVelocity;

UniformLocation uPMatrix, uMVMatrix;

Buffer pointBuffer;

int numParticles;

Matrix4 mvMatrix = new Matrix4.identity(),
        pMatrix = new Matrix4.identity();

List<double> particles = new List<double>();

void main() {
  var vs, fs;
  
  canvas = querySelector('#canvas');
  canvas.width  = window.innerWidth;
  canvas.height = window.innerHeight;
  
  gl = canvas.getContext('webgl');
  if (gl == null) {
    throw 'Unable to create WebGL context';
  }
  
  vs = gl.createShader(RenderingContext.VERTEX_SHADER);
  gl.shaderSource(vs, querySelector('#vs').text);
  gl.compileShader(vs);
  if (!gl.getShaderParameter(vs, RenderingContext.COMPILE_STATUS)) {
    throw gl.getShaderInfoLog(vs);
  }
  
  fs = gl.createShader(RenderingContext.FRAGMENT_SHADER);
  gl.shaderSource(fs, querySelector('#fs').text);
  gl.compileShader(fs);
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
  
  aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
  aVertexVelocity = gl.getAttribLocation(program, 'aVertexVelocity');
  gl.enableVertexAttribArray(aVertexPosition);
  gl.enableVertexAttribArray(aVertexVelocity);
  
  gl.viewport(0, 0, canvas.width, canvas.height);
  
  uPMatrix =  gl.getUniformLocation(program, 'uPMatrix');
  uMVMatrix = gl.getUniformLocation(program, 'uMVMatrix');
  
  setPerspectiveMatrix(pMatrix, 45, canvas.width / canvas.height, 0.1, 100.0);
  mvMatrix.translate(0.0, -5.0, -50.0);
  
  gl.disable(RenderingContext.DEPTH_TEST);
  gl.enable(RenderingContext.BLEND);
  gl.blendFunc(RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_SRC_ALPHA);
  
  updateParticles();
  
  pointBuffer = gl.createBuffer();
  
  animLoop();
}

void animLoop([num delta]) {
  window.requestAnimationFrame(animLoop);
  
  gl.clearColor(0.1, 0.1, 0.1, 1.0);
  gl.clear(RenderingContext.COLOR_BUFFER_BIT);
  
  gl.uniformMatrix4fv(uPMatrix, false,  pMatrix.storage);
  gl.uniformMatrix4fv(uMVMatrix, false, mvMatrix.storage);
  
  draw();
  updateParticles();
}

void updateParticles() {
  var cloned = particles.toList(),
      l = cloned.length,
      rnd = new Random(),
      i,
      old;
  
  particles.clear();
  
  for (i = 0 ; i < l; i += PARTICLE_COMPONENTS) {
    if (cloned[i + 3] < LIFESPAN && cloned[i + 1] > START_Y - 0.001) {
      old =  cloned.sublist(i, i + PARTICLE_COMPONENTS);
      old[3] += 1.0;
      particles.addAll(old);
    }
  }
  
  numParticles = particles.length ~/ PARTICLE_COMPONENTS;
  
  if (numParticles + MAX_SPAWN_PER_FRAME < MAX_NUMBER_OF_PARTICLES) {
    
    
    for (i = 0; i < MAX_SPAWN_PER_FRAME; ++i) {
      particles.add(0.5 * rnd.nextDouble() - 0.25);   // x
      particles.add(START_Y.toDouble());              // y    
      particles.add(rnd.nextDouble() * 0.5);          // z
      particles.add(0.0);                             // life
      particles.add(5.0 * rnd.nextDouble() - 10.0);   // velx
      particles.add(14.0 + 12.0 * rnd.nextDouble());  // velx
      particles.add(0.5 + rnd.nextDouble() * 4.0);    // size
      
      ++numParticles;
    }
  }
}

void draw() {
  
  gl.bindBuffer(RenderingContext.ARRAY_BUFFER, pointBuffer);
  gl.bufferData(RenderingContext.ARRAY_BUFFER, new Float32List.fromList(particles), RenderingContext.STATIC_DRAW);
  
  gl.vertexAttribPointer(aVertexPosition, 4, RenderingContext.FLOAT, 
      false, PARTICLE_COMPONENTS * Float32List.BYTES_PER_ELEMENT, 
        0 * Float32List.BYTES_PER_ELEMENT);
  gl.vertexAttribPointer(aVertexPosition, 3, RenderingContext.FLOAT, 
        false, PARTICLE_COMPONENTS * Float32List.BYTES_PER_ELEMENT, 
        4 * Float32List.BYTES_PER_ELEMENT);
  
  gl.drawArrays(RenderingContext.POINTS, 0, numParticles);
}




