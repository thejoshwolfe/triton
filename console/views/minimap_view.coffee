class window.MinimapView extends Backbone.View
  template: JST['console/templates/minimap']
  className: 'minimap-view'
  scale: 20

  initialize: =>
    window.socket.on 'world', (world_json) =>
      @world = new World(world_json)
      @update_engage_button_state()
    window.socket.emit 'request_world'

  context: => {}

  render: =>
    @$el.html @template @context()
    @$el.on 'contextmenu', 'canvas', => false
    @update_engage_button_state()
    @$el

  events:
    'click .engage' : =>
      window.socket.emit 'helm', command: 'engage'

  run: =>
    @canvas = document.getElementById('minimap-canvas')
    $(@canvas).attr 'width', $(window).width() - 40
    $(@canvas).attr 'height', $(window).height() - 220
    @context2d = @canvas.getContext('2d')
    @canvas.addEventListener 'mousedown', @mouse_click, false
    @canvas.addEventListener 'mousewheel', @mouse_wheel, false
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
      position = @worldToMap planet.position()
      @context2d.fillRect(position.x, position.y, 1, 1)

    # camera
    @context2d.fillStyle = '#6A89FD'
    ship_position = @worldToMap @world.camera.position()
    @context2d.fillRect(ship_position.x-3, ship_position.y-3, 6, 6)

    return unless (cursor_position = @world.get('cursor_position'))?
    cursor_position = @worldToMap new Vec3d cursor_position

    # cursor
    @context2d.strokeStyle = '#00FF00'
    @context2d.strokeRect cursor_position.x-5, cursor_position.y-5, 10, 10

    # course
    @context2d.strokeStyle = '#666'
    @context2d.beginPath()
    @context2d.moveTo ship_position.x, ship_position.y
    @context2d.lineTo cursor_position.x, cursor_position.y
    @context2d.closePath()
    @context2d.stroke()

  mouse_click: (event) =>
    return window.socket.emit 'new_course', null if event.which == 3

    x = event.offsetX ? (event.pageX - event.target.offsetLeft)
    y = event.offsetY ? (event.pageY - event.target.offsetTop)

    cursor_position = @mapToWorld new Vec3d(x,y,0)
    window.socket.emit 'new_course', cursor_position.toArray()
    @world.set_new_course cursor_position

  mouse_wheel: (event) =>
    event.preventDefault()
    @scale *= 1 + (event.wheelDelta / 1000)

  update_engage_button_state: =>
    if @world?.get('cursor_position')?
      @$('button.engage').removeClass('disabled btn-inverse').addClass('btn-danger')
    else
      @$('button.engage').removeClass('btn-danger').addClass('disabled btn-inverse')

  flip_y: new Vec3d(1,-1,0)
  center: => new Vec3d(@canvas.width/2, @canvas.height/2, 0)
  mapToWorld: (position) => position.minus(@center()).mult(@flip_y).scale(1/@scale)
  worldToMap: (position) => position.scale(@scale).mult(@flip_y).add(@center())
