class window.DisplayWebGLView

  set_canvas: (@$canvas) =>
    @canvas = @$canvas.get 0

  run: =>
    @gl = @_initGL()
    @_initShaders()
    @_initBuffers()

    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable     @gl.DEPTH_TEST

    @_drawScene()

  # Protected

  _drawScene: =>
    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
    mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix
    mat4.identity  @mvMatrix

    mat4.translate @mvMatrix, [-1.5, 0.0, -7.0]
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @triangleVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @_setMatrixUniforms()
    @gl.drawArrays @gl.TRIANGLES, 0, @triangleVertexPositionBuffer.numItems

    mat4.translate @mvMatrix, [3.0, 0.0, 0.0]
    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @squareVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexColorBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @squareVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @_setMatrixUniforms()
    @gl.drawArrays @gl.TRIANGLE_STRIP, 0, @squareVertexPositionBuffer.numItems

  _getShader: ($el) =>
    shaderScript = $el[0]
    return unless shaderScript?

    str = ""
    k = shaderScript.firstChild
    while k
      str += k.textContent if k.nodeType == 3
      k = k.nextSibling

    shader = switch shaderScript.type
      when "x-shader/x-fragment" then @gl.createShader @gl.FRAGMENT_SHADER
      when "x-shader/x-vertex"   then @gl.createShader @gl.VERTEX_SHADER

    return unless shader?

    @gl.shaderSource shader, str
    @gl.compileShader shader

    unless @gl.getShaderParameter shader, @gl.COMPILE_STATUS
      alert @gl.getShaderInfoLog(shader) 
      return null

    shader

  _initBuffers: =>
    @_initTriangle()
    @_initSquare()

  _initGL: =>
    try
      gl = @canvas.getContext "experimental-webgl"
      gl.viewportWidth  = @canvas.width
      gl.viewportHeight = @canvas.height
    catch e
      alert "Could not initialise WebGL"
    gl

  _initSquare: =>
    @squareVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexPositionBuffer

    vertices = [
       1.0,  1.0,  0.0
      -1.0,  1.0,  0.0
       1.0, -1.0,  0.0
      -1.0, -1.0,  0.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
    @squareVertexPositionBuffer.itemSize = 3
    @squareVertexPositionBuffer.numItems = 4

    @squareVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexColorBuffer
    colors = _.flatten _.map [0..3], => [0.5, 0.5, 1.0, 1.0]
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(colors), @gl.STATIC_DRAW
    @squareVertexColorBuffer.itemSize = 4
    @squareVertexColorBuffer.numItems = 4

  _initShaders: =>
    @mvMatrix = mat4.create()
    @pMatrix  = mat4.create()

    fragmentShader = @_getShader $("#shader-fs")
    vertexShader   = @_getShader $("#shader-vs")

    @shaderProgram = @gl.createProgram()
    @gl.attachShader @shaderProgram, fragmentShader
    @gl.attachShader @shaderProgram, vertexShader
    @gl.linkProgram  @shaderProgram
    alert "Could not initialise shaders" unless @gl.getProgramParameter @shaderProgram, @gl.LINK_STATUS

    @gl.useProgram @shaderProgram
    @shaderProgram.vertexPositionAttribute = @gl.getAttribLocation @shaderProgram, "aVertexPosition"
    @gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute

    @shaderProgram.vertexColorAttribute = @gl.getAttribLocation @shaderProgram, "aVertexColor"
    @gl.enableVertexAttribArray @shaderProgram.vertexColorAttribute

    @shaderProgram.pMatrixUniform  = @gl.getUniformLocation @shaderProgram, "uPMatrix"
    @shaderProgram.mvMatrixUniform = @gl.getUniformLocation @shaderProgram, "uMVMatrix"

  _initTriangle: =>
    @triangleVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer

    vertices = [
       0.0,  1.0,  0.0
      -1.0, -1.0,  0.0
       1.0, -1.0,  0.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
    @triangleVertexPositionBuffer.itemSize = 3
    @triangleVertexPositionBuffer.numItems = 3

    @triangleVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
    colors = [
      1.0, 0.0, 0.0, 1.0
      0.0, 1.0, 0.0, 1.0
      0.0, 0.0, 1.0, 1.0
    ]
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(colors), @gl.STATIC_DRAW
    @triangleVertexColorBuffer.itemSize = 4
    @triangleVertexColorBuffer.numItems = 3

  _setMatrixUniforms: =>
    @gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, @pMatrix
    @gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, @mvMatrix
