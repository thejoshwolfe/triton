class window.MinimapView extends Backbone.View
  template: JST['console/templates/minimap']
  className: 'minimap-view'

  initialize: =>
    window.socket.on 'world', (world_json) =>
      @world = new World(world_json)
    window.socket.emit 'request_world'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    @$el

  run: =>
    @tick()

  tick: =>
    return if @destroyed

    requestAnimFrame @tick
    @drawScene() if @world?

  drawScene: =>
    @canvas ?= document.getElementById('minimap-canvas')
    @context2d ?= @canvas.getContext('2d')

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
    [x, y, z] = @world.camera.position()
    @context2d.fillRect(@worldToMapX(x), @worldToMapY(y), 6, 7)

  # -20 <= x <= 20
  worldToMapX: (world_x) => (world_x + 20) * @canvas.width / 40
  worldToMapY: (world_y) => (world_y + 20) * @canvas.height / 40
