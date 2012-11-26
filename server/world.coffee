Backbone = require 'backbone'
Camera = require './camera'
_ = require 'underscore'

module.exports = class World extends Backbone.Model
  defaults:
    light_direction:   [-0.25, -0.25, -1.0]
    ambient_color:     [ 0.2,   0.2,   0.2]
    directional_color: [ 0.8,   0.8,   0.8]
    cube:
      rotation: [0,0,0]
      angular_velocity: [0,0.01,0]

  initialize: (options={}) =>
    @camera = new Camera()
    @camera.on 'all', (event, args...) =>
      @trigger "camera:#{event}", args...

  toJSON: =>
    timestamp = new Date().getTime()
    @update_cube silent: true, time: timestamp
    _.extend super,
      camera: @camera.toJSON(time: timestamp)
      timestamp: timestamp

  # Instance Methods
  helm_command: (command) =>
    @camera.go command

  # private methods
  update_cube: (options={}) =>
    current_time = options.time ? new Date().getTime()

    if @last_cube_update?
      elapsed = current_time - @last_cube_update
      cube = _.clone @get 'cube'
      for i in [0..2]
        cube.rotation[i] += cube.angular_velocity[i] * elapsed
      @set {cube: cube}, silent: options.silent

    @last_cube_update = current_time

