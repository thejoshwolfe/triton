class window.DisplayView extends Backbone.View
  template: JST['console/templates/display']
  className: 'display-view'

  initialize: =>
    @webgl_view = new DisplayWebGLView()
    window.socket.on 'world', @update_world
    window.socket.emit 'request_world'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    if window.cheat?
      @$el.append new HelmView().render()
      @$el.append new ScienceView().render()
    @$el

  run: =>
    $canvas = @$ 'canvas'

    @webgl_view.set_canvas $canvas
    $canvas.attr 'width', $(window).width() - 40
    $canvas.attr 'height', $(window).height() - 120
    @webgl_view.run()

  # Instance Methods
  update_world: (world_json) =>
    @webgl_view.update_world new World world_json

