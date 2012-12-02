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
    @drawScene()

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
      # -20 <= x <= 20
      x = (x + 20) * @canvas.width / 40
      z = (z + 20) * @canvas.height / 40
      @context2d.fillRect(x, z, 1, 1)
