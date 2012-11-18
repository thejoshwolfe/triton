class window.DisplayWebGLView

  constructor: ->
    @currentPosition = [0.0, 0.0, 0.0]

  go: (direction) =>
    switch direction
      when 'up'      then @currentPosition[1]--
      when 'down'    then @currentPosition[1]++
      when 'left'    then @currentPosition[0]++
      when 'right'   then @currentPosition[0]--
      when 'forward' then @currentPosition[2]++
      when 'back'    then @currentPosition[2]--
      else console?.log 'DisplayWebGLView.go: Invalid direction name'

  run: =>
    @gl = @_initGL()
    @_initShaders()
    @_initBuffers()

    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable     @gl.DEPTH_TEST

    @rPyramid = 0
    @rCube    = 0

    @_tick()

  set_canvas: (@$canvas) =>
    @canvas = @$canvas.get 0

  # Protected

  _animate: =>
    timeNow = new Date().getTime()
    if @lastTime
      elapsed = timeNow - @lastTime

      @rPyramid += (90 * elapsed) / 1000.0
      @rCube    += (75 * elapsed) / 1000.0

    @lastTime = timeNow

  _degToRad: (degrees) =>
    degrees * Math.PI / 180

  _drawScene: =>
    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
    mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix
    mat4.identity  @mvMatrix

    # Camera Movement
    mat4.translate @mvMatrix, @currentPosition
    @_mvPushMatrix()

    # Pyramid
    mat4.translate @mvMatrix, [-1.5, 0.0, -7.0]
    @_mvPushMatrix()
    mat4.rotate @mvMatrix, @_degToRad(@rPyramid), [0, 1, 0]

    @gl.bindBuffer @gl.ARRAY_BUFFER, @pyramidVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @pyramidVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ARRAY_BUFFER, @pyramidVertexColorBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @pyramidVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @_setMatrixUniforms()
    @gl.drawArrays @gl.TRIANGLES, 0, @pyramidVertexPositionBuffer.numItems
    @_mvPopMatrix()

    # Cube
    mat4.translate @mvMatrix, [3.0, 0.0, 0.0]
    @_mvPushMatrix()
    mat4.rotate @mvMatrix, @_degToRad(@rCube), [1, 1, 1]

    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @cubeVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexColorBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @cubeVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @cubeVertexIndexBuffer
    @_setMatrixUniforms()
    @gl.drawElements @gl.TRIANGLES, @cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0

    @_mvPopMatrix()

    @_mvPopMatrix() # End _drawScene


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
    @_initPyramid()
    @_initCube()

  _initCube: =>
    @cubeVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexPositionBuffer

    vertices = [
      # Front Face
      -1.0, -1.0,  1.0
       1.0, -1.0,  1.0
       1.0,  1.0,  1.0
      -1.0,  1.0,  1.0
      # Back Face
      -1.0, -1.0, -1.0
      -1.0,  1.0, -1.0
       1.0,  1.0, -1.0
       1.0, -1.0, -1.0
      # Top Face
      -1.0,  1.0, -1.0
      -1.0,  1.0,  1.0
       1.0,  1.0,  1.0
       1.0,  1.0, -1.0
      # Bottom Face
      -1.0, -1.0, -1.0
       1.0, -1.0, -1.0
       1.0, -1.0,  1.0
      -1.0, -1.0,  1.0
      # Right Face
       1.0, -1.0, -1.0
       1.0,  1.0, -1.0
       1.0,  1.0,  1.0
       1.0, -1.0,  1.0
      # Left Face
      -1.0, -1.0, -1.0
      -1.0, -1.0,  1.0
      -1.0,  1.0,  1.0
      -1.0,  1.0, -1.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
    @cubeVertexPositionBuffer.itemSize = 3
    @cubeVertexPositionBuffer.numItems = 24

    @cubeVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexColorBuffer

    colors = [
      [1.0, 0.0, 0.0, 1.0] # Front Face
      [1.0, 1.0, 0.0, 1.0] # Back Face
      [0.0, 1.0, 0.0, 1.0] # Top Face
      [1.0, 0.5, 0.5, 1.0] # Bottom Face
      [1.0, 0.0, 1.0, 1.0] # Right Face
      [0.0, 0.0, 1.0, 1.0] # Left Face
    ]
    unpacked_colors = _.flatten _.map colors, (color) => 
      _.map [0..3], => color

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(unpacked_colors), @gl.STATIC_DRAW
    @cubeVertexColorBuffer.itemSize = 4
    @cubeVertexColorBuffer.numItems = 24

    @cubeVertexIndexBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @cubeVertexIndexBuffer
    cubeVertexIndeces = [
      0,  1,  2,    0,  2,  3   # Front Face
      4,  5,  6,    4,  6,  7   # Back Face
      8,  9,  10,   8,  10, 11  # Top Face
      12, 13, 14,   12, 14, 15  # Botom Face
      16, 17, 18,   16, 18, 19  # Right Face
      20, 21, 22,   20, 22, 23  # Left Face
    ]
    @gl.bufferData @gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndeces), @gl.STATIC_DRAW
    @cubeVertexIndexBuffer.itemSize = 1
    @cubeVertexIndexBuffer.numItems = 36

  _initGL: =>
    try
      gl = @canvas.getContext "experimental-webgl"
      gl.viewportWidth  = @canvas.width
      gl.viewportHeight = @canvas.height
    catch e
      alert "Could not initialise WebGL"
    gl

  _initPyramid: =>
    @pyramidVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @pyramidVertexPositionBuffer

    vertices = [
      # Front Face
       0.0,  1.0,  0.0
      -1.0, -1.0,  1.0
       1.0, -1.0,  1.0
      # Right Face
       0.0,  1.0,  0.0
       1.0, -1.0,  1.0
       1.0, -1.0, -1.0
      # Back Face
       0.0,  1.0,  0.0
       1.0, -1.0, -1.0
      -1.0, -1.0, -1.0
      # Left Face
       0.0,  1.0,  0.0
      -1.0, -1.0, -1.0
      -1.0, -1.0,  1.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
    @pyramidVertexPositionBuffer.itemSize = 3
    @pyramidVertexPositionBuffer.numItems = 12

    @pyramidVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @pyramidVertexColorBuffer
    colors = [
      # Front Face
      1.0, 0.0, 0.0, 1.0
      0.0, 1.0, 0.0, 1.0
      0.0, 0.0, 1.0, 1.0
      # Right Face
      1.0, 0.0, 0.0, 1.0
      0.0, 0.0, 1.0, 1.0
      0.0, 1.0, 0.0, 1.0
      # Back Face
      1.0, 0.0, 0.0, 1.0
      0.0, 1.0, 0.0, 1.0
      0.0, 0.0, 1.0, 1.0
      # Left Face
      1.0, 0.0, 0.0, 1.0
      0.0, 0.0, 1.0, 1.0
      0.0, 1.0, 0.0, 1.0
    ]
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(colors), @gl.STATIC_DRAW
    @pyramidVertexColorBuffer.itemSize = 4
    @pyramidVertexColorBuffer.numItems = 12

  _initShaders: =>
    @mvMatrix = mat4.create()
    @pMatrix  = mat4.create()
    @mvMatrixStack = []

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

  _mvPopMatrix: =>
    throw 'Invalid popMatrix' unless @mvMatrixStack
    @mvMatrix = @mvMatrixStack.pop()

  _mvPushMatrix: =>
    copy = mat4.create()
    mat4.set @mvMatrix, copy
    @mvMatrixStack.push copy

  _setMatrixUniforms: =>
    @gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, @pMatrix
    @gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, @mvMatrix

  _tick: =>
    requestAnimFrame @_tick
    @_drawScene()
    @_animate()
