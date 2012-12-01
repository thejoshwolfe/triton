Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
Body     = window?.Body     ? require './body'

class Camera extends Body
  defaults: =>
    _.extend super,
      position:         [0,0,0]
      angular_velocity: [0,0,0]

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

window?.Camera  = Camera
module?.exports = Camera
