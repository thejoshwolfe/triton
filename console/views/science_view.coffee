class window.ScienceView extends Backbone.View
  template: JST['console/templates/science']
  className: 'science-view'

  initialize: =>
    window.socket.on 'mission_blurb', (blurb) =>
      $('#mission_blurb').text blurb ? ''
    window.socket.emit 'request_mission_blurb'

  run: =>

  context: => {}

  events:
    'click .accept_mission' : 'click_accept'
  click_accept: =>
    window.socket.emit 'accept_mission'

  render: =>
    @$el.html @template @context()
    @$el

