class window.DisplayView extends Backbone.View
  template: JST['console/templates/display']
  className: 'display-view'

  initialize: =>
    @webgl_view = new DisplayWebGLView()
    window.socket.on 'display', @display_event

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    @webgl_view.set_canvas @$ 'canvas'
    _.delay =>
      @webgl_view.run()
    , 500
    @$el

  # Event Handlers
  display_event: (event={}) =>
    @webgl_view.go event.direction if event.direction?

