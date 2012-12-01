Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
Body     = window?.Body     ? require './body'

class Camera extends Body
  defaults: =>
    _.extend super,
      position:         [0,0,0]
      angular_velocity: [0,0,0]

  go: (direction) =>
    @update_position silent: true
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
    @set 'velocity', velocity

  update_position: (options={}) =>
    current_time = options.time ? new Date().getTime()

    if @last_position_update?
      elapsed = current_time - @last_position_update
      position = _.clone @get 'position'
      velocity = @get 'velocity'
      position[0] += velocity[0] * elapsed
      position[1] += velocity[1] * elapsed
      position[2] += velocity[2] * elapsed
      @set {position: position}, silent: options.silent

    @last_position_update = current_time

window?.Camera  = Camera
module?.exports = Camera
