class window.HelmView extends Backbone.View
  template: JST['console/templates/helm']
  className: 'helm-view'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    @$el

  events:
    'click .up'     : 'click_up'
    'click .down'   : 'click_down'
    'click .left'   : 'click_left'
    'click .right'  : 'click_right'
    'click .forward': 'click_forward'
    'click .back'   : 'click_back'
    'click .reset'  : 'click_reset'

  # Event Handlers

  click_up: =>
    @emit 'up'

  click_down: =>
    @emit 'down'

  click_left: =>
    @emit 'left'

  click_right: =>
    @emit 'right'

  click_forward: =>
    @emit 'forward'

  click_back: =>
    @emit 'back'

  click_reset: =>
    window.socket.emit 'reset'

  # Instance Methods
  emit: (command) =>
    window.socket.emit 'helm', command: command
