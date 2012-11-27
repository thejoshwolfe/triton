Backbone = require 'backbone'
Camera = require './camera'
_ = require 'underscore'

module.exports = class World extends Backbone.Model
  defaults:
    light_direction:   [-0.25, -0.25, -1.0]
    ambient_color:     [ 0.2,   0.2,   0.2]
    directional_color: [ 0.8,   0.8,   0.8]
    planets: []

  initialize: (options={}) =>
    @camera = new Camera()
    @camera.on 'all', (event, args...) =>
      @trigger "camera:#{event}", args...

    planets = _.clone @get 'planets'
    planet_count = 40
    for i in [1..planet_count]
      position = [
        (Math.random() - 0.5) * 40,
        (Math.random() - 0.5) * 40,
        (Math.random() - 1)   * 40,
      ]
      planets.push @make_planet position
    @set {planets}, silent: options.silent

  make_planet: (position) =>
    return {}=
      position: position
      rotation: [0,0,0]
      angular_velocity: [0,0.01,0]

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
      planets = _.clone @get 'planets'
      for planet in planets
        for i in [0..2]
          planet.rotation[i] += planet.angular_velocity[i] * elapsed
      @set {planets}, silent: options.silent

    @last_cube_update = current_time

