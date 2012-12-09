class window.ApplicationView extends Backbone.View
  initialize: =>
    window.time_offset = 0
    current_time = new Date().getTime()
    window.socket.on 'time_update', @time_update
    @time_update client_time: current_time, server_time: current_time

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
    @child_view.run()
    callback()

  navigate_to_helm: (callback=->) =>
    $('.nav-collapse li.helm').addClass('active')
    @child_view = new HelmView()
    @render()
    callback()

  navigate_to_minimap: (callback=->) =>
    $('.nav-collapse li.minimap').addClass('active')
    @child_view = new MinimapView()
    @render()
    @child_view.run()
    callback()

  navigate_to_science: (callback=->) =>
    $('.nav-collapse li.science').addClass('active')
    @child_view = new ScienceView()
    @render()
    @child_view.run()
    callback()

  time_update: (data) =>
    window.time_offset = (window.time_offset + data.server_time - data.client_time) / 2
    _.delay =>
      window.socket.emit 'time_check', client_time: new Date().getTime()
    , 500
