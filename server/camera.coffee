Backbone = require 'backbone'
_        = require 'underscore'

module.exports = class Camera extends Backbone.Model
  defaults:
    position: [0,0,0]

  go: (direction) =>
    position = _.clone @get 'position'
    switch direction
      when 'up'      then position[1]--
      when 'down'    then position[1]++
      when 'left'    then position[0]++
      when 'right'   then position[0]--
      when 'forward' then position[2]++
      when 'back'    then position[2]--
      else console?.log 'DisplayWebGLView.go: Invalid direction name'
    @set 'position', position

