import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';

import '../lib/glh.dart' as glh;

CanvasElement canvas;
RenderingContext gl;
glh.Model model;

main() {
  var img;
  
  canvas = querySelector('#canvas');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  

  
  gl = glh.getContext(canvas);
  
  model = glh.loadProgram(gl, 
      querySelector('#vshader').text,
      querySelector('#fshader').text  
    );
  
  createBuffers();
  
  // create texture and image
  model.data('texture', gl.createTexture());
  
  img = new ImageElement();
  img.onLoad.listen(onImageLoaded);
  img.src = 'dart-logo.png';
  model.data('img', img);
  
  model.data('startTime', new DateTime.now().millisecondsSinceEpoch);
}

createBuffers() {
  var vertices, buffer, program;
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
    
    program = model.data('program');
    
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, buffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, vertices, RenderingContext.STATIC_DRAW);
    
    model.data('a_Position', gl.getAttribLocation(program, 'a_Position'));
    gl.vertexAttribPointer(model.data('a_Position'), 2, RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(model.data('a_Position'));

    // Retreive uniforms
    model.data('u_Sampler', gl.getUniformLocation(program, 'u_Sampler'));

    model.data('u_Resolution', gl.getUniformLocation(program, 'u_Resolution'));
    gl.uniform2f(model.data('u_Resolution'), canvas.width, canvas.height);
    
    model.data('u_Time', gl.getUniformLocation(program, 'u_Time'));
     
    model.data('u_Angle', gl.getUniformLocation(program, 'u_Angle'));
    model.data('angle', 0.04);
    gl.uniform1f(model.data('u_Angle'), model.data('angle'));
    
    model.data('numItems', 4);
    model.data('itemSize', 2);
}

onImageLoaded(Event e) {
  update();
}

updateTexture() {
  gl.activeTexture(RenderingContext.TEXTURE0);
  gl.bindTexture(RenderingContext.TEXTURE_2D, model.data('texture'));
  gl.pixelStorei(RenderingContext.UNPACK_FLIP_Y_WEBGL, RenderingContext.BOOL);
  gl.texImage2D(
      RenderingContext.TEXTURE_2D, 
      0, 
      RenderingContext.RGBA, 
      RenderingContext.RGBA, 
      RenderingContext.UNSIGNED_BYTE, 
      model.data('img'));
  
  gl.texParameteri(RenderingContext.TEXTURE_2D, 
      RenderingContext.TEXTURE_MAG_FILTER, 
      RenderingContext.LINEAR);
  
  gl.texParameteri(RenderingContext.TEXTURE_2D, 
      RenderingContext.TEXTURE_MIN_FILTER, 
      RenderingContext.LINEAR);
  
  gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
  gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE); 
  
  gl.uniform1i(model.data('u_Sampler'), 0);
  gl.drawArrays(RenderingContext.TRIANGLE_STRIP, 0, model.data('numItems'));
}

update([num highResTime]) {
  var diff, angle;
  
  window.requestAnimationFrame(update);

  diff = new DateTime.now().millisecondsSinceEpoch - model.data('startTime');
  
  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
  gl.enable(RenderingContext.DEPTH_TEST);
  gl.viewport(0, 0, canvas.width, canvas.height);
  
  gl.uniform1f(model.data('u_Time'), diff / 1000.0); 
  updateTexture();
}