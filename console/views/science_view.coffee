class window.ScienceView extends Backbone.View
  template: JST['console/templates/science']
  className: 'science-view'

  initialize: =>
    window.socket.on 'mission_blurb', (blurb) =>
      $('.accept_mission')[if blurb? then 'addClass' else 'removeClass'] 'disabled'
      $('#mission_blurb').text blurb ? ''
    window.socket.emit 'request_mission_blurb'

    window.socket.on 'scan_results', (text) =>
      $('#scan_results').text text ? ''
    window.socket.emit 'request_scan_results'

  run: =>

  context: => {}

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

