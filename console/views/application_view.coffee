class window.ApplicationView extends Backbone.View
  render: =>
    $("#application-view").html @child_view.render().$el
    this

  # Instance Methods

  dismiss_children: =>
    @child_view?.remove()
    $('.nav-collapse li').removeClass('active')

  navigate_to_helm: =>
    @dismiss_children()
    $('.nav-collapse li.helm').addClass('active')
    @child_view = new HelmView()
    @render()
