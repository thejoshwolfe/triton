class window.Router extends Backbone.Router

  initialize: (@application_view) =>

  routes:
    '':        'root'
    'breasts':   'breasts'
    'cheat':   'cheat'
    'display': 'display'
    'helm':    'helm'
    'minimap': 'minimap'
    'science': 'science'

  root: (callback=->) =>
    @application_view.dismiss_children callback

  breasts: (callback=->) =>
    @root =>
      @application_view.navigate_to_breasts callback

  cheat: (callback=->) =>
    window.cheat = true
    @display callback

  display: (callback=->) =>
    @root =>
      @application_view.navigate_to_display callback

  helm: (callback=->) =>
    @root =>
      @application_view.navigate_to_helm callback

  minimap: (callback=->) =>
    @root =>
      @application_view.navigate_to_minimap callback

  science: (callback=->) =>
    @root =>
      @application_view.navigate_to_science callback
