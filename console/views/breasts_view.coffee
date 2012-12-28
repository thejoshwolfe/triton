class window.BreastsView extends View
  template: JST['console/templates/breasts']
  className: 'breasts-view'

  initialize: =>
    window.socket.on 'world', (world_json) =>
      @mission = new Mission world_json.mission
      @render()
    window.socket.emit 'request_world'

  context: =>
    mission: @mission?.toJSON()

  render: =>
    @$el.html @template @context()
    @$el
