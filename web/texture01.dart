import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';

import '../lib/glh.dart' as glh;

CanvasElement canvas;
ImageElement img;
RenderingContext gl;
Program program;

int a_Position,
    startTime;

UniformLocation u_Time,
                u_Angle,
                u_Resolution,
                u_Sampler;
Texture texture;
double angle;

main() {
  canvas = querySelector('#canvas');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  gl = glh.context(canvas);

  program = glh.createProgram(gl,
      querySelector('#vshader').text,
      querySelector('#fshader').text
    );
  gl.useProgram(program);
  
  createBuffers();

  // create texture and image
  texture = gl.createTexture();

  img = new ImageElement();
  img.onLoad.listen(onImageLoaded);
  img.src = 'webgl-logo.png';

 startTime = new DateTime.now().millisecondsSinceEpoch;
}

createBuffers() {
  var vertices, buffer;
/*
  2___3
  |\  |
  | \ |
  |__\|
  0   1
*/
  vertices = new Float32List.fromList([
    -1.0, -1.0,
     1.0, -1.0,
    -1.0,  1.0,
     1.0,  1.0 ]);

    buffer = gl.createBuffer();

    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, buffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, vertices, RenderingContext.STATIC_DRAW);

    a_Position = gl.getAttribLocation(program, 'a_Position');
    gl.vertexAttribPointer(a_Position, 2, RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(a_Position);

    // Retreive uniforms
    u_Sampler =  gl.getUniformLocation(program, 'u_Sampler');

    u_Resolution = gl.getUniformLocation(program, 'u_Resolution');
    gl.uniform2f(u_Resolution, canvas.width, canvas.height);

    u_Time = gl.getUniformLocation(program, 'u_Time');

    u_Angle = gl.getUniformLocation(program, 'u_Angle');
    angle = 0.04;
    gl.uniform1f(u_Angle, angle);
}

onImageLoaded(Event e) {
  update();
}

updateTexture() {
  gl.activeTexture(RenderingContext.TEXTURE0);
  gl.bindTexture(RenderingContext.TEXTURE_2D, texture);
  gl.pixelStorei(RenderingContext.UNPACK_FLIP_Y_WEBGL, RenderingContext.BOOL);
  gl.texImage2D(
      RenderingContext.TEXTURE_2D,
      0,
      RenderingContext.RGBA,
      RenderingContext.RGBA,
      RenderingContext.UNSIGNED_BYTE,
      img);

  gl.texParameteri(RenderingContext.TEXTURE_2D,
      RenderingContext.TEXTURE_MAG_FILTER,
      RenderingContext.LINEAR);

  gl.texParameteri(RenderingContext.TEXTURE_2D,
      RenderingContext.TEXTURE_MIN_FILTER,
      RenderingContext.LINEAR);

  gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
  gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE);

  gl.uniform1i(u_Sampler, 0);
  gl.drawArrays(RenderingContext.TRIANGLE_STRIP, 0, 4);
}

update([num highResTime]) {
  var diff, angle;

  window.requestAnimationFrame(update);

  diff = new DateTime.now().millisecondsSinceEpoch - startTime;

  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
  gl.enable(RenderingContext.DEPTH_TEST);
  gl.viewport(0, 0, canvas.width, canvas.height);

  gl.uniform1f(u_Time, diff / 100.0);
  updateTexture();
}