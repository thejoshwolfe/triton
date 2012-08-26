class window.Router extends Backbone.Router

  initialize: (@application_view) =>

  routes:
    "":     'root'
    "helm": 'helm'

  root: =>
    @application_view.dismiss_children()

  helm: =>
    @application_view.navigate_to_helm()
