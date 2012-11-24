Backbone = require 'backbone'
Camera = require './camera'
_ = require 'underscore'

module.exports = class World extends Backbone.Model
  initialize: (options={}) =>
    @camera = new Camera()
    @camera.on 'all', (event, args...) =>
      @trigger "camera:#{event}", args...

  toJSON: =>
    _.extend super,
      camera: @camera.toJSON()

  # Instance Methods
  helm_command: (command) =>
    @camera.go command
