part of dart_webgl;

Shader compileShader(RenderingContext gl, String source, int type) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, COMPILE_STATUS)) {
    gl.deleteShader(shader);
    throw gl.getShaderInfoLog(shader);
  }
  return shader;
}

Program linkProgram(RenderingContext gl, List<Shader> shaders, [List<String> attribs, List<int> locations]) {
  var p = gl.createProgram();

  var i = 0, l = shaders.length;
  for (i; i < l; i++) {
    gl.attachShader(p, shaders[i]);
  }

  if (attribs != null) {
    i = 0;
    l = attribs.length;
    for (i; i < l; i++) {
      gl.bindAttribLocation(p, locations != null ? locations[i] : i, attribs[i]);
    }
  }

  gl.linkProgram(p);
  if (!gl.getProgramParameter(p, LINK_STATUS)) {
    gl.deleteProgram(p);
    throw gl.getProgramInfoLog(p);
  }

  return p;
}

Map<String, int> getAttribs(RenderingContext gl, Program program) {
  var total = gl.getProgramParameter(program, ACTIVE_ATTRIBUTES),
      i,
      info,
      out = {};

  for (i = 0; i < total; i++) {
    info = gl.getActiveAttrib(program, i);
    out[info.name] = gl.getAttribLocation(program, info.name);
  }
  return out;
}

Map<String, UniformLocation> getUniforms(RenderingContext gl, Program program) {
  var total = gl.getProgramParameter(program, ACTIVE_UNIFORMS),
      i,
      info,
      out = {};

  for (i = 0; i < total; i++) {
    info = gl.getActiveUniform(program, i);
    out[info.name] = gl.getUniformLocation(program, info.name);
  }
  return out;
}



