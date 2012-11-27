class window.MinimapView extends Backbone.View
  template: JST['console/templates/minimap']
  className: 'minimap-view'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    @$el
