class window.ScienceView extends Backbone.View
  template: JST['console/templates/science']
  className: 'science-view'

  initialize: =>
    window.socket.on   'mission_blurbs', (mission_blurbs_json) => 
      @mission_blurbs = new Blurbs mission_blurbs_json
      @render()
    window.socket.emit 'request_mission_blurbs'

    window.socket.on   'scan_results',     (@scan_success, @scan_message) => @render()
    window.socket.on   'teleport_results', (@teleport_success, @teleport_message) => @render()

  run: =>

  context: =>
    mission_blurbs:   @mission_blurbs?.toJSON()
    scan_message:     @scan_message
    scan_success:     @scan_success
    teleport_message: @teleport_message
    teleport_success: @teleport_success

  events:
    'click .accept_mission':  'accept_mission'
    'click .beam_aboard':     'beam_aboard'
    'click .long_range_scan': 'long_range_scan'
    'click .scan_planet':     'scan_planet'

  render: =>
    @$el.html @template @context()
    @$el

  # Event Handlers
  accept_mission: ($event) =>
    $event.preventDefault()
    return if @mission_blurbs.any()
    window.socket.emit 'accept_mission'

  beam_aboard: ($event) =>
    $event.preventDefault()
    window.socket.emit 'beam_aboard'

  long_range_scan: ($event) =>
    $event.preventDefault()
    window.socket.emit 'long_range_scan'

  scan_planet: ($event) =>
    $event.preventDefault()
    window.socket.emit 'scan_planet'

