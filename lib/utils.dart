part of glh;

// Utility methods
RenderingContext context(CanvasElement canvas) {
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

Program createProgram(RenderingContext gl, String vshader, String fshader) {
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
  return program;
}

