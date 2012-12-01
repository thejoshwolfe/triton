Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
Bodies   = window?.Bodies   ? require './bodies'
Camera   = window?.Camera   ? require './camera'

class World extends Backbone.Model
  defaults:
    light_direction:   [-0.25, -0.25, -1.0]
    ambient_color:     [ 0.2,   0.2,   0.2]
    directional_color: [ 0.8,   0.8,   0.8]
    planets: []

  initialize: (options={}) =>
    @camera = new Camera options.camera
    @camera.on 'all', (event, args...) =>
      @trigger "camera:#{event}", args...

    @planets = new Bodies options.planets
    unless @planets.size()
      _.times 40, => @planets.add()

  make_planet: (position) =>
    return {}=
      position: position

  toJSON: =>
    _.extend super,
      camera:  @camera.toJSON()
      planets: @planets.toJSON()

  # Instance Methods
  helm_command: (command) =>
    @camera.go command

window?.World = World
module?.exports = World
