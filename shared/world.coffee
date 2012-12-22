Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Bodies} = window ? require './bodies'
{Body}   = window ? require './body'
{Vec3d}  = window ? require './vec3d'

root = exports ? this
class root.World extends Backbone.Model
  defaults:
    ambient_color:     [ 0.2,   0.2,   0.2]
    directional_color: [ 0.8,   0.8,   0.8]
    light_direction:   [-0.25, -0.25, -1.0]
    planets: []

  initialize: (options={}) =>
    @camera = new Body @get 'camera'
    @camera.on 'all', (event, args...) =>
      @trigger "camera:#{event}", args...

    @planets = new Bodies options.planets
    unless @planets.size()
      # create a world
      _.times 10, =>
        planet = new Body
        planet.set_physics
          angular_velocity: new Vec3d(0,0,0.01)
          position: new Vec3d(
            (Math.random() - 0.5) * 40
            (Math.random() - 0.5) * 40
            (Math.random() - 0.5) * 10
          )
        @planets.add planet

  toJSON: =>
    _.extend super,
      camera:  @camera.toJSON()
      planets: @planets.toJSON()

  # Instance Methods
  engage: =>
    return unless (cursor_position = @get 'cursor_position')?
    cursor_position = new Vec3d cursor_position
    @set {cursor_position: null}, silent: true
    @camera.go_to_point cursor_position, 0.0001

  helm_command: (command) =>
    acceleration = 0.001
    switch command
      # x
      when 'left'    then @camera.accelerate(-acceleration,0,0)
      when 'right'   then @camera.accelerate(+acceleration,0,0)
      # y
      when 'back'    then @camera.accelerate(0,-acceleration,0)
      when 'forward' then @camera.accelerate(0,+acceleration,0)
      # z
      when 'down'    then @camera.accelerate(0,0,-acceleration)
      when 'up'      then @camera.accelerate(0,0,+acceleration)
      # course
      when 'engage'  then @engage()
      else new Error("invalid helm command")

  is_ship_near_planet: =>
    @planets.any_within 1, of: @camera.position()

  set_new_course: (cursor_position) =>
    @set 'cursor_position', cursor_position.toArray()
