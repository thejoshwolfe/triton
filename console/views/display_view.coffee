class window.DisplayView extends Backbone.View
  template: JST['console/templates/display']
  className: 'display-view'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    console.log @template @context()
    @$el

