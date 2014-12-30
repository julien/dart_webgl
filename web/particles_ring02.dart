import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';
import 'package:dart_webgl/dart_webgl.dart';

CanvasElement canvas;
RenderingContext gl;
num cw, ch, ratio;
Program program;
UniformLocation uTime;
DateTime now;
Float32List vertices, velocities;
final int totalLines = 10000;
int numLines = totalLines;
List<num> touches = new List<num>.filled(2, 0.0);

void main() {
  setup();

  window.onResize.listen(resize);
  window.onMouseMove.listen(mouseMove);
  resize();

  animate();
}

void resize([Event e]) {
  cw = window.innerWidth;
  ch = window.innerHeight;
}

void normalize(num px, num py) {
  touches[0] = (px / cw - 0.5) * 3.0;
  touches[1] = (py / ch - 0.5) * -2.0;
}

void mouseMove(MouseEvent e) {
  normalize(e.page.x, e.page.y);
}

void setup() {
  canvas = document.getElementById('canvas');
  gl = canvas.getContext('webgl');

  cw = window.innerWidth;
  ch = window.innerHeight;
  canvas.width =  cw;
  canvas.height = ch;

  gl.viewport(0, 0, canvas.width, canvas.height);

  var vs = document.getElementById('vs').text;
  var fs = document.getElementById('fs').text;

  var shaders = [compileShader(gl, vs, VERTEX_SHADER), compileShader(gl, fs, FRAGMENT_SHADER)];
  print('shaders[0]: ${shaders[0]}');

  program = linkProgram(gl, shaders);
  gl.useProgram(program);

  var aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
  gl.enableVertexAttribArray(aVertexPosition);

  now = new DateTime.now();
  uTime = gl.getUniformLocation(program, 'uTime');
  gl.uniform1f(uTime, now.millisecondsSinceEpoch);
  // print('now: ${now.millisecondsSinceEpoch}');

  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clearDepth(1.0);
  gl.enable(BLEND);
  gl.disable(DEPTH_TEST);
  gl.blendFunc(SRC_ALPHA, ONE);

  var vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);

  ratio = cw / ch;
  var i = 0,
      verts = [],
      vels =  [],
      rnd = new Random();

  for (var i = 0; i < totalLines; i++) {
    verts
      ..add(0.0)..add(0.0)..add(1.83);

    vels
      ..add(((rnd.nextDouble() * 2 - 1) * 0.005).abs())
      ..add(((rnd.nextDouble() * 2 - 1) * 0.005.abs()))
      ..add((0.9 * rnd.nextDouble() * 0.7).abs());

  }

  vertices =   new Float32List.fromList(verts);
  velocities = new Float32List.fromList(vels);
  gl.vertexAttribPointer(aVertexPosition, 3, FLOAT, false, 0, 0);

  var perspectiveMatrix = makePerspective(30, ratio, 1, 100);
  var modelViewMatrix = makeModeView();

  var uVMatrix = gl.getUniformLocation(program, 'uVMatrix');
  var uPMatrix = gl.getUniformLocation(program, 'uPMatrix');

  gl.uniformMatrix4fv(uVMatrix, false, perspectiveMatrix);
  gl.uniformMatrix4fv(uPMatrix, false, modelViewMatrix);
  gl.lineWidth(3);
}

void animate([num highResTime]) {
  window.requestAnimationFrame(animate);

  now = new DateTime.now();
  uTime = gl.getUniformLocation(program, 'uTime');
  gl.uniform1f(uTime, now.millisecondsSinceEpoch);

  var i, bp, p, j, dx, dy, d;

  var numTouches = touches.length;
  var rnd = new Random();

  // animate and attract particles
  for (i = 0; i  < numLines; i += 2) {
    bp = i * 3;

    // copy old positions
    vertices[bp] = vertices[bp+3];
    vertices[bp+1] = vertices[bp+4];

    // inertia
    velocities[bp]   *= velocities[bp+2];
    velocities[bp+1] *= velocities[bp+2];

    // horizontal
    p = vertices[bp+3];
    p += velocities[bp];
    if (p < -ratio) {
      p = -ratio;
      velocities[bp] =  -velocities[bp].abs();
    } else if (p > ratio) {
      p = ratio;
      velocities[bp] =  velocities[bp].abs();
    }
    vertices[bp+3] = p;

    // vertical
    p = vertices[bp+4];
    p += velocities[bp+1];
    if (p < -0.9) {
      p = -0.9;
      velocities[bp+1] = velocities[bp+1].abs();
    } else if (p > 0.9) {
      p = 0.9;
      velocities[bp+1] = -velocities[bp+1].abs();
    }
    vertices[bp+4] = p;

    // attraction on touch
    if (numTouches > 0) {
      for (j = 0; j < numTouches; j += 2) {
        dx = touches[j] - vertices[bp];
        dy = touches[j+1] - vertices[bp+1];
        d = sqrt(dx*dx + dy*dy);

        if (d < 2.0) {
          if (d < 0.03) {
            vertices[bp]   = (rnd.nextDouble() * 2 - 1) * ratio * 2.0;
            vertices[bp+1] = rnd.nextDouble() * 2 - 1;
            vertices[bp+3] = (vertices[bp+3] + vertices[bp]) * 0.5;
            vertices[bp+4] = (vertices[bp+4] + vertices[bp+1]) * 0.5;

            velocities[bp] =   rnd.nextDouble() * .4 - .2;
            velocities[bp+1] = rnd.nextDouble() * .4 - .2;
          } else {
            dx /= d;
            dy /= d;
            d = (2 - d) / 2;
            d *= d;
            velocities[bp]   += dx * d * 0.1;
            velocities[bp+1] += dy * d * 0.1;
          }
        }
      }
    }
  }

  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  gl.bufferData(ARRAY_BUFFER, vertices, DYNAMIC_DRAW);

  gl.drawArrays(POINTS, 0, numLines);
  gl.flush();
}
