class window.ScienceView extends Backbone.View
  template: JST['console/templates/science']
  className: 'science-view'

  initialize: =>
    window.socket.on 'mission_blurb', (@mission_blurb) => @render()
    window.socket.emit 'request_mission_blurb'

    window.socket.on 'scan_results', (@scan_success, @scan_message) => @render()
    window.socket.emit 'request_scan_results'

  run: =>

  context: =>
    mission_blurb: @mission_blurb
    scan_message: @scan_message
    scan_success: @scan_success

  events:
    'click .accept_mission': =>
      window.socket.emit 'accept_mission'
    'click .long_range_scan': =>
      window.socket.emit 'long_range_scan'
    'click .scan_planet': =>
      window.socket.emit 'scan_planet'

  render: =>
    @$el.html @template @context()
    @$el

