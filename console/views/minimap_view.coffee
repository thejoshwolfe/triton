class window.MinimapView extends Backbone.View
  template: JST['console/templates/minimap']
  className: 'minimap-view'
  scale: 20

  initialize: =>
    window.socket.on 'world', (world_json) =>
      @world = new World(world_json)
    window.socket.emit 'request_world'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    @$el.on 'contextmenu', 'canvas', => false
    @$el

  run: =>
    @canvas    = document.getElementById('minimap-canvas')
    $(@canvas).attr 'width', $(window).width() - 40
    $(@canvas).attr 'height', $(window).height() - 120
    @context2d = @canvas.getContext('2d')
    @canvas.addEventListener 'mousedown', @mouse_click, false
    @tick()

  tick: =>
    return if @destroyed

    requestAnimFrame @tick
    @drawScene() if @world?

  drawScene: =>
    # clear
    @context2d.fillStyle = '#000'
    @context2d.fillRect(0, 0, @canvas.width, @canvas.height)

    # planets
    @context2d.fillStyle = '#fff'
    @world.planets.each (planet) =>
      [x, y, z] = planet.position()
      @context2d.fillRect(@worldToMapX(x), @worldToMapY(y), 1, 1)

    # camera
    @context2d.fillStyle = '#6A89FD'
    [ship_x, ship_y, dont_care] = @world.camera.position()
    ship_x = @worldToMapX ship_x
    ship_y = @worldToMapY ship_y
    @context2d.fillRect(ship_x-3, ship_y-3, 6, 6)

    return unless (cursor_position = @world.get('cursor_position'))?

    # cursor
    @context2d.strokeStyle = '#00FF00'
    [cursor_x, cursor_y] = cursor_position
    cursor_x = @worldToMapX cursor_x
    cursor_y = @worldToMapY cursor_y
    @context2d.strokeRect cursor_x-5, cursor_y-5, 10, 10

    # course
    @context2d.strokeStyle = '#666'
    @context2d.beginPath()
    @context2d.moveTo ship_x, ship_y
    @context2d.lineTo cursor_x, cursor_y
    @context2d.closePath()
    @context2d.stroke()

  mouse_click: (event) =>
    return window.socket.emit 'new_course', null if event.which == 3

    x = event.offsetX ? (event.pageX - event.target.offsetLeft)
    x = @mapToWorldX x
    y = event.offsetY ? (event.pageY - event.target.offsetTop)
    y = @mapToWorldY y

    window.socket.emit 'new_course', [x, y]
    @world.set_new_course [x, y]

  # -20 <= x <= 20
  mapToWorldX: (map_x)   => (map_x - @canvas.width  / 2) / @scale
  mapToWorldY: (map_y)   => -1 * (map_y - @canvas.height / 2) / @scale
  worldToMapX: (world_x) => world_x * @scale + @canvas.width  / 2
  worldToMapY: (world_y) => -1 * world_y * @scale + @canvas.height / 2
