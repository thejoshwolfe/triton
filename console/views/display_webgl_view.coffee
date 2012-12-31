class window.DisplayWebGLView
  constructor: ->
    @catalog = new Catalog()
    @catalog.fetch()

  destroy: =>
    @destroyed = true

  run: =>
    return @catalog.once 'reset', @run unless @catalog.is_fetched

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

  # Protected
  degToRad: (degrees) =>
    degrees * Math.PI / 180

  drawScene: =>
    box = @catalog.meshes.box

    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
    mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix
    mat4.identity @mvMatrix

    # Camera Movement
    mat4.rotate @mvMatrix, @degToRad(-90), [1,0,0]
    mat4.scale @mvMatrix, [-1,-1,-1]
    mat4.translate @mvMatrix, @world.camera.position().toArray()
    mat4.scale @mvMatrix, [-1,-1,-1]

    @mvPushMatrix()

    # Planets
    @world.planets.each (planet) =>
      @mvPushMatrix()
      mat4.translate @mvMatrix, planet.position().toArray()

      _.each planet.rotation().toArray(), (axis, i) =>
        a = [0,0,0]
        a[i] = 1
        mat4.rotate @mvMatrix, @degToRad(axis), a

      @gl.bindBuffer @gl.ARRAY_BUFFER, box.vertices.buffer
      @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, box.vertices.item_size, @gl.FLOAT, false, 0, 0

      @gl.bindBuffer @gl.ARRAY_BUFFER, box.vertex_normals.buffer
      @gl.vertexAttribPointer @shaderProgram.vertexNormalAttribute, box.vertex_normals.item_size, @gl.FLOAT, false, 0, 0

      @gl.bindBuffer @gl.ARRAY_BUFFER, box.texture.buffer
      @gl.vertexAttribPointer @shaderProgram.textureCoordAttribute, box.texture.item_size, @gl.FLOAT, false, 0, 0

      @gl.activeTexture @gl.TEXTURE0
      @gl.bindTexture @gl.TEXTURE_2D, box.texture.gl_texture
      @gl.uniform1i @shaderProgram.samplerUniform, 0

      world_json = @world.toJSON()
      @gl.uniform3f @shaderProgram.ambientColorUniform, world_json.ambient_color...
      adjustedLD = vec3.create()
      vec3.normalize world_json.light_direction, adjustedLD
      vec3.scale adjustedLD, -1
      @gl.uniform3fv @shaderProgram.lightingDirectionUniform, adjustedLD

      @gl.uniform3f @shaderProgram.directionalColorUniform, world_json.directional_color...

      @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, box.vertex_indeces.buffer
      @setMatrixUniforms()
      @gl.drawElements @gl.TRIANGLES, box.vertex_indeces.number_of_items, @gl.UNSIGNED_SHORT, 0

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
    box = @catalog.meshes.box

    box.vertices.buffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, box.vertices.buffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(box.vertices.points), @gl.STATIC_DRAW

    box.vertex_normals.buffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, box.vertex_normals.buffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(box.vertex_normals.points), @gl.STATIC_DRAW

    box.texture.buffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, box.texture.buffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(box.texture.points), @gl.STATIC_DRAW

    box.vertex_indeces.buffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, box.vertex_indeces.buffer
    @gl.bufferData @gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(box.vertex_indeces.points), @gl.STATIC_DRAW

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
    box = @catalog.meshes.box

    box.texture.gl_texture = @gl.createTexture()
    box.texture.gl_texture.image = new Image()
    box.texture.gl_texture.image.onload = =>
      @handleLoadedTexture box.texture.gl_texture

    box.texture.gl_texture.image.src = box.texture.image

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
