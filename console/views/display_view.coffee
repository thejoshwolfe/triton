class window.DisplayView extends Backbone.View
  template: JST['console/templates/display']
  className: 'display-view'

  initialize: =>
    @webgl_view = new DisplayWebGLView()
    window.socket.on 'world', @webgl_view.update_world
    window.socket.emit 'request_world'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    $canvas = @$ 'canvas'

    @webgl_view.set_canvas $canvas
    _.delay =>
      $canvas.attr 'width', $(window).width() - 40
      $canvas.attr 'height', $(window).height() - 120
      @webgl_view.run()
    , 500
    @$el

