class window.Catalog
  constructor: ->
    _.extend @, Backbone.Events

  mesh_paths:
    box: 'meshes/box.json'

  meshes: {}
  is_fetched: false

  fetch: =>
    @meshes = {}
    @is_fetched = false
    _.each @mesh_paths, (path, name) =>
      $.getJSON path, (json) =>
        @meshes[name] = json
        @check_if_fetching_is_done()

  check_if_fetching_is_done: =>
    @is_fetched = _.size(@mesh_paths) == _.size(@meshes)
    @trigger 'reset' if @is_fetched
