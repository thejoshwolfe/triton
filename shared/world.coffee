Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Bodies} = window ? require './bodies'
{Body}   = window ? require './body'

root = exports ? this
class root.World extends Backbone.Model
  defaults:
    camera:
      position: [0,0,0]
      angular_velocity: [0,0,0]
    light_direction:   [-0.25, -0.25, -1.0]
    ambient_color:     [ 0.2,   0.2,   0.2]
    directional_color: [ 0.8,   0.8,   0.8]
    planets: []

  initialize: (options={}) =>
    @camera = new Body @get 'camera'
    @camera.on 'all', (event, args...) =>
      @trigger "camera:#{event}", args...

    @planets = new Bodies options.planets
    unless @planets.size()
      _.times 10, => @planets.add()

  make_planet: (position) =>
    return {}=
      position: position

  toJSON: =>
    _.extend super,
      camera:  @camera.toJSON()
      planets: @planets.toJSON()

  # Instance Methods
  helm_command: (command) =>
    acceleration = 0.001
    switch command
      # x
      when 'left'    then @camera.accelerate [-acceleration,0,0]
      when 'right'   then @camera.accelerate [+acceleration,0,0]
      # y
      when 'back'    then @camera.accelerate [0,-acceleration,0]
      when 'forward' then @camera.accelerate [0,+acceleration,0]
      # z
      when 'down'    then @camera.accelerate [0,0,-acceleration]
      when 'up'      then @camera.accelerate [0,0,+acceleration]
      # course
      when 'engage'  then @engage()
      else new Error("invalid helm command")

  engage: =>
    return unless (cursor_position = @get 'cursor_position')?
    @set {cursor_position: null}, silent: true
    @camera.go_toward_at_speed cursor_position, 0.01

  set_new_course: (cursor_position) =>
    @set 'cursor_position', cursor_position
