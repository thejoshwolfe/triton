class window.ApplicationView extends Backbone.View
  render: =>
    $("#application-view").html @child_view?.render()
    this

  # Instance Methods

  dismiss_children: (callback=->) =>
    @child_view?.remove()
    @child_view = null
    $('.nav-collapse li').removeClass('active')
    callback()
    
  navigate_to_display: (callback=->) =>
    $('.nav-collapse li.display').addClass('active')
    @child_view = new DisplayView()
    @render()
    callback()
    

  navigate_to_helm: (callback=->) =>
    $('.nav-collapse li.helm').addClass('active')
    @child_view = new HelmView()
    @render()
    callback()
