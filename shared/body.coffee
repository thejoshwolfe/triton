Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'

root = exports ? this
class root.Body extends Backbone.Model
  defaults: =>
    timestamp: new Date().getTime()
    rotation:         [0,0,0]
    angular_velocity: [0,0.01,0]
    velocity:         [0,0,0]
    position: [
      (Math.random() - 0.5) * 40
      (Math.random() - 0.5) * 40
      (Math.random() - 1)   * 40
    ]

  # Public Methods
  go: (direction) =>
    velocity = _.clone @get 'velocity'
    acceleration = 0.001
    switch direction
      when 'up'      then velocity[1] -= acceleration
      when 'down'    then velocity[1] += acceleration
      when 'left'    then velocity[0] += acceleration
      when 'right'   then velocity[0] -= acceleration
      when 'forward' then velocity[2] += acceleration
      when 'back'    then velocity[2] -= acceleration
      else console?.log 'DisplayWebGLView.go: Invalid direction name'
    @set
      timestamp: new Date().getTime()
      position: @position()
      rotation: @rotation()
      velocity: velocity

  position: =>
    @extrapolate 'position', 'velocity'

  rotation: =>
    @extrapolate 'rotation', 'angular_velocity'

  # private methods
  extrapolate: (position_attribute_name, velocity_attribute_name) =>
    position = _.clone @get position_attribute_name
    velocity = _.clone @get velocity_attribute_name
    elapsed  = new Date().getTime() - @get('timestamp')

    _.times 3, (i) =>
      position[i] += elapsed * velocity[i]
    position
