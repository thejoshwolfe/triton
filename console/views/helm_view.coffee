class window.HelmView extends Backbone.View
  template: JST['console/templates/helm']
  className: 'helm-view'

  context: =>
    {}

  render: =>
    @$el.html @template @context()
    this
