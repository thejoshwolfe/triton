Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'

root = exports ? this
class root.Body extends Backbone.Model
  defaults: =>
    timestamp: new Date().getTime()
    rotation:         [0,0,0]
    angular_velocity: [0,0,0.01]
    velocity:         [0,0,0]
    position: [
      (Math.random() - 0.5) * 40
      (Math.random() - 0.5) * 40
      (Math.random() - 0.5) * 10
    ]

  # Public Methods
  accelerate: (acceleration) =>
    velocity = _.clone @get 'velocity'
    for i in [0..2]
      velocity[i] += acceleration[i]
    @set_physics
      velocity: velocity

  go_toward_at_speed: (point, speed) =>
    @set_physics
      position: point

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

  set_physics: (props) =>
    @set
      timestamp:        new Date().getTime()
      position:         props.position         ? @position()
      velocity:         props.velocity         ? @get 'velocity'
      rotation:         props.rotation         ? @rotation()
      angular_velocity: props.angular_velocity ? @get 'angular_velocity'
