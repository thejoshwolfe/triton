class window.ScienceView extends Backbone.View
  template: JST['console/templates/science']
  className: 'science-view'

  context: => {}

  render: =>
    @$el.html @template @context()
    @$el

