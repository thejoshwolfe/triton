Backbone = require 'backbone'
_        = require 'underscore'

module.exports = class Camera extends Backbone.Model
  defaults:
    position: [0.0,0.0,0.0]
    velocity: [0.0,0.0,0.0]

  go: (direction) =>
    @update_position silent: true
    velocity = _.clone @get 'velocity'
    switch direction
      when 'up'      then velocity[1]--
      when 'down'    then velocity[1]++
      when 'left'    then velocity[0]++
      when 'right'   then velocity[0]--
      when 'forward' then velocity[2]++
      when 'back'    then velocity[2]--
      else console?.log 'DisplayWebGLView.go: Invalid direction name'
    @set 'velocity', velocity

  toJSON: (options={}) =>
    @update_position silent: true, time: options.time
    super

  update_position: (options={}) =>
    current_time = options.time ? new Date().getTime()

    if @last_position_update?
      elapsed = current_time - @last_position_update
      position = _.clone @get 'position'
      velocity = @get 'velocity'
      position[0] += velocity[0] * elapsed / 1000.0
      position[1] += velocity[1] * elapsed / 1000.0
      position[2] += velocity[2] * elapsed / 1000.0
      @set {position: position}, silent: options.silent

    @last_position_update = current_time

