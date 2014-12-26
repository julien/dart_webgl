part of dart_webgl;

Shader compileShader(RenderingContext gl, String source, int type) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, COMPILE_STATUS)) {
    var err = gl.getShaderInfoLog(shader);
    gl.deleteShader(shader);
    throw err;
  }
  return shader;
}

Program linkProgram(RenderingContext gl, List<Shader> shaders,
    [List<String> attribs, List<int> locations]) {
  var p = gl.createProgram();

  var i = 0,
      l = shaders.length;
  for (i; i < l; i++) {
    gl.attachShader(p, shaders[i]);
  }

  if (attribs != null) {
    i = 0;
    l = attribs.length;
    for (i; i < l; i++) {
      gl.bindAttribLocation(
          p,
          locations != null ? locations[i] : i,
          attribs[i]);
    }
  }

  gl.linkProgram(p);
  if (!gl.getProgramParameter(p, LINK_STATUS)) {
    var err = gl.getProgramInfoLog(p);
    gl.deleteProgram(p);
    throw err;
  }

  return p;
}

Float32List makePerspective(num fov, num aspectRatio, num near, num far) {

  var top = near * tan(fov * PI / 360);
  var bottom = -top;
  var right = top * aspectRatio;
  var left = -right;

  var a = ((right + left) / (right - left)).toDouble();
  var b = ((top + bottom) / (top - bottom)).toDouble();
  var c = ((far + near) / (far - near)).toDouble();
  var d = ((2 * far * near) / (far - near)).toDouble();
  var x = ((2 * near) / (right - left)).toDouble();
  var y = ((2 * near) / (top - bottom)).toDouble();

  return new Float32List.fromList([
    x, 0.0, a, 0.0,
    0.0, y, b, 0.0,
    0.0, 0.0, c, d,
    0.0, 0.0, -1.0, 0.0]);
}

List<num> makeModeView() {
  return new Float32List.fromList([
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0]);
}


