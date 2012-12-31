class window.Catalog
  constructor: ->
    _.extend @, Backbone.Events

  mesh_paths:
    box: 'meshes/box.json'

  meshes: {}

  fetch: =>
    @meshes = {}
    _.each @mesh_paths, (path, name) =>
      $.getJSON path, (json) =>
        @meshes[name] = json
        @check_if_loading_is_done()

  check_if_loading_is_done: =>
    @is_loaded = _.size(@mesh_paths) == _.size(@meshes)
    @trigger 'reset' if @is_loaded
