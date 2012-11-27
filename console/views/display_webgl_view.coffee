class window.DisplayWebGLView
  destroy: =>
    @destroyed = true

  run: =>
    @gl = @initGL()
    window.gl = @gl
    @initShaders()
    @initBuffers()
    @initTexture()

    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable     @gl.DEPTH_TEST

    @tick()

  set_canvas: (@$canvas) =>
    @canvas = @$canvas.get 0

  update_world: (@world) =>
    @world.timestamp = new Date().getTime()

  # Protected

  animate: =>
    timeNow = new Date().getTime()

    elapsed = timeNow - @world.timestamp

    for planet in @world.planets
      for i in [0..2]
        planet.rotation[i] += planet.angular_velocity[i] * elapsed
    for i in [0..2]
      @world.camera.position[i] += @world.camera.velocity[i] * elapsed

    @world.timestamp = timeNow

  degToRad: (degrees) =>
    degrees * Math.PI / 180

  drawScene: =>
    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
    mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix
    mat4.identity @mvMatrix

    # Camera Movement
    mat4.translate @mvMatrix, @world.camera.position
    @mvPushMatrix()

    # Planets
    mat4.translate @mvMatrix, [0.0, 0.0, -5.0]
    for planet in @world.planets
      @mvPushMatrix()
      mat4.translate @mvMatrix, planet.position
      mat4.rotate @mvMatrix, @degToRad(planet.rotation[0]), [1, 0, 0]
      mat4.rotate @mvMatrix, @degToRad(planet.rotation[1]), [0, 1, 0]
      mat4.rotate @mvMatrix, @degToRad(planet.rotation[2]), [0, 0, 1]

      @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexPositionBuffer
      @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @cubeVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

      @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexNormalBuffer
      @gl.vertexAttribPointer @shaderProgram.vertexNormalAttribute, @cubeVertexNormalBuffer.itemSize, @gl.FLOAT, false, 0, 0

      @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexTextureCoordBuffer
      @gl.vertexAttribPointer @shaderProgram.textureCoordAttribute, @cubeVertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0

      @gl.activeTexture @gl.TEXTURE0
      @gl.bindTexture @gl.TEXTURE_2D, @crateTexture
      @gl.uniform1i @shaderProgram.samplerUniform, 0

      @gl.uniform3f @shaderProgram.ambientColorUniform, @world.ambient_color...
      adjustedLD = vec3.create()
      vec3.normalize @world.light_direction, adjustedLD
      vec3.scale adjustedLD, -1
      @gl.uniform3fv @shaderProgram.lightingDirectionUniform, adjustedLD

      @gl.uniform3f @shaderProgram.directionalColorUniform, @world.directional_color...

      @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @cubeVertexIndexBuffer
      @setMatrixUniforms()
      @gl.drawElements @gl.TRIANGLES, @cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0

      @mvPopMatrix()

    @mvPopMatrix() # End drawScene

  getShader: ($el) =>
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

  handleLoadedTexture: (texture) =>
    @textureLoaded = true
    @gl.bindTexture @gl.TEXTURE_2D, texture
    @gl.pixelStorei @gl.UNPACK_FLIP_Y_WEBGL, true
    @gl.texImage2D @gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, texture.image
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST
    @gl.generateMipmap @gl.TEXTURE_2D
    @gl.bindTexture @gl.TEXTURE_2D, null

  initBuffers: =>
    @initCube()

  initCube: =>
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

    @cubeVertexTextureCoordBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexTextureCoordBuffer
    textureCoords = [
      # Front Face
      0.0, 0.0
      1.0, 0.0
      1.0, 1.0
      0.0, 1.0

      # Back Face
      1.0, 0.0
      1.0, 1.0
      0.0, 1.0
      0.0, 0.0

      # Top Face
      0.0, 1.0
      0.0, 0.0
      1.0, 0.0
      1.0, 1.0

      # Bottom Face
      1.0, 1.0
      0.0, 1.0
      0.0, 0.0
      1.0, 0.0

      # Right Face
      1.0, 0.0
      1.0, 1.0
      0.0, 1.0
      0.0, 0.0

      # Left Face
      0.0, 0.0
      1.0, 0.0
      1.0, 1.0
      0.0, 1.0
    ]
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(textureCoords), @gl.STATIC_DRAW
    @cubeVertexTextureCoordBuffer.itemSize = 2
    @cubeVertexTextureCoordBuffer.numItems = 24

    @cubeVertexNormalBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexNormalBuffer
    vertexNomals = [
      # Front face
       0.0,  0.0,  1.0
       0.0,  0.0,  1.0
       0.0,  0.0,  1.0
       0.0,  0.0,  1.0

      # Back face
       0.0,  0.0, -1.0
       0.0,  0.0, -1.0
       0.0,  0.0, -1.0
       0.0,  0.0, -1.0

      # Top face
       0.0,  1.0,  0.0
       0.0,  1.0,  0.0
       0.0,  1.0,  0.0
       0.0,  1.0,  0.0

      # Bottom face
       0.0, -1.0,  0.0
       0.0, -1.0,  0.0
       0.0, -1.0,  0.0
       0.0, -1.0,  0.0

      # Right face
       1.0,  0.0,  0.0
       1.0,  0.0,  0.0
       1.0,  0.0,  0.0
       1.0,  0.0,  0.0

      # Left face
      -1.0,  0.0,  0.0
      -1.0,  0.0,  0.0
      -1.0,  0.0,  0.0
      -1.0,  0.0,  0.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertexNomals), @gl.STATIC_DRAW
    @cubeVertexNormalBuffer.itemSize = 3
    @cubeVertexNormalBuffer.numItems = 24

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

  initGL: =>
    try
      gl = @canvas.getContext "experimental-webgl"
      gl.viewportWidth  = @canvas.width
      gl.viewportHeight = @canvas.height
    catch e
      alert "Could not initialise WebGL"
    gl

  initShaders: =>
    @mvMatrix = mat4.create()
    @pMatrix  = mat4.create()
    @mvMatrixStack = []

    fragmentShader = @getShader $("#shader-fs")
    vertexShader   = @getShader $("#shader-vs")

    @shaderProgram = @gl.createProgram()
    @gl.attachShader @shaderProgram, fragmentShader
    @gl.attachShader @shaderProgram, vertexShader
    @gl.linkProgram  @shaderProgram
    alert "Could not initialise shaders" unless @gl.getProgramParameter @shaderProgram, @gl.LINK_STATUS

    @gl.useProgram @shaderProgram
    
    @shaderProgram.vertexPositionAttribute = @gl.getAttribLocation @shaderProgram, "aVertexPosition"
    @gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute

    @shaderProgram.vertexNormalAttribute = @gl.getAttribLocation @shaderProgram, "aVertexNormal"
    @gl.enableVertexAttribArray @shaderProgram.vertexNormalAttribute

    @shaderProgram.textureCoordAttribute = @gl.getAttribLocation @shaderProgram, "aTextureCoord"
    @gl.enableVertexAttribArray @shaderProgram.textureCoordAttribute

    @shaderProgram.pMatrixUniform           = @gl.getUniformLocation @shaderProgram, "uPMatrix"
    @shaderProgram.mvMatrixUniform          = @gl.getUniformLocation @shaderProgram, "uMVMatrix"
    @shaderProgram.nMatrixUniform           = @gl.getUniformLocation @shaderProgram, "uNMatrix"
    @shaderProgram.samplerUniform           = @gl.getUniformLocation @shaderProgram, "uSampler"
    @shaderProgram.ambientColorUniform      = @gl.getUniformLocation @shaderProgram, "uAmbientColor"
    @shaderProgram.lightingDirectionUniform = @gl.getUniformLocation @shaderProgram, "uLightingDirection"
    @shaderProgram.directionalColorUniform  = @gl.getUniformLocation @shaderProgram, "uDirectionalColor"


  initTexture: =>
    @crateTexture = @gl.createTexture()
    @crateTexture.image = new Image()
    @crateTexture.image.onload = =>
      @handleLoadedTexture @crateTexture
    @crateTexture.image.src = "img/crate.gif"

  mvPopMatrix: =>
    throw 'Invalid popMatrix' unless @mvMatrixStack
    @mvMatrix = @mvMatrixStack.pop()

  mvPushMatrix: =>
    copy = mat4.create()
    mat4.set @mvMatrix, copy
    @mvMatrixStack.push copy

  setMatrixUniforms: =>
    @gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, @pMatrix
    @gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, @mvMatrix

    normalMatrix = mat3.create()
    mat4.toInverseMat3 @mvMatrix, normalMatrix
    mat3.transpose normalMatrix
    @gl.uniformMatrix3fv @shaderProgram.nMatrixUniform, false, normalMatrix

  tick: =>
    return if @destroyed

    requestAnimFrame @tick
    return unless @world? and @textureLoaded
    @drawScene()
    @animate()

