import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';

const Duration VIDEO_CHECK_DURATION = const Duration(milliseconds: 100);

CanvasElement canvas;
VideoElement video;
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
  var vs, fs;
  canvas = querySelector('#canvas');
  canvas.width = window.innerWidth;
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
  
  createBuffers();

  // create texture and video
  texture = gl.createTexture();
 
  video = new VideoElement()
    ..autoplay = true;
  
  window.navigator.getUserMedia(audio: false, video: true)
    .then(userMediaSuccess)
    .catchError(userMediaError);
  
  startTime = new DateTime.now().millisecondsSinceEpoch;
}

checkVideoState(Timer timer) {  
  if (video.readyState == MediaElement.HAVE_ENOUGH_DATA) {
    timer.cancel();
    
    update();
  }
}

userMediaError(error) {
  throw 'Sorry, can\'t detect user media';
}

userMediaSuccess(MediaStream stream) {
  var timer = new Timer.periodic(VIDEO_CHECK_DURATION, checkVideoState);
  video.src = Url.createObjectUrlFromStream(stream);
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
      video);

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