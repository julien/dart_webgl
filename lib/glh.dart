// WebGL Helper

library glh;

import 'dart:html';
import 'dart:web_gl';

class Model {
  
  Map _attributes = {};
  
  Model([Map<String, dynamic> attributes]) {
    if (attributes != null) {
      _attributes = new Map.from(attributes)
        ..forEach((k, v) => data(k, v));
    }
  }
  
  data(String key, [val]) {
    if (val != null) {
      _attributes[key] = val;  
    }
    return _attributes[key];
  }
  
  operator [](String key) => data(key);
}

RenderingContext getContext(CanvasElement canvas) {
  var gl;
  try {
    gl = canvas.getContext('webgl');
  } catch (err) {
    throw err;
  }
  return gl;
}

Shader createShader(RenderingContext gl, int type, String source) {
  var shader;
  shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, RenderingContext.COMPILE_STATUS)) {
    gl.deleteShader(shader);
  }
  return shader;
}

Map<String, dynamic> createProgram(RenderingContext gl, String vshader, String fshader) {
  
  var vertexShader, fragmentShader, program;


  vertexShader   = createShader(gl, RenderingContext.VERTEX_SHADER, vshader);
  fragmentShader = createShader(gl, RenderingContext.FRAGMENT_SHADER, fshader);

  program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, RenderingContext.LINK_STATUS)) {
    gl.deleteProgram(program);
    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);
  }
  
  
  return {
    'program': program,
    'vertexShader': vertexShader,
    'fragmentShader': fragmentShader,
    'cache': {}
  };
}

Model loadProgram(RenderingContext gl, String vshader, String fshader) {
  var model;  
  
  model = new Model(createProgram(gl, vshader, fshader));
  if (model['program'] != null) {
    gl.useProgram(model['program']);
  }  
  return model;
}

