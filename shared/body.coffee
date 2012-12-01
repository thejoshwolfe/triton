Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'

class Body extends Backbone.Model
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
  position: =>
    position = _.clone @get 'position'
    velocity = _.clone @get 'velocity'
    elapsed  = new Date().getTime() - @get('timestamp')
    _.times 3, (i) =>
      position[i] += elapsed * velocity[i]
    position


  rotation: => @get 'rotation'

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


window?.Body = Body
module?.exports = Body
