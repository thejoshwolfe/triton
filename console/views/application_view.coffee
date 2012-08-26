class window.ApplicationView extends Backbone.View
  render: =>
    $("#application-view").html @child_view.render().$el
    this

  # Instance Methods

  dismiss_children: =>
    @child_view?.remove()

  navigate_to_helm: =>
    @dismiss_children()
    @child_view = new HelmView()
    @render()
