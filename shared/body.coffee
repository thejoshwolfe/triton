Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Vec3d}  = window ? require './vec3d'

root = exports ? this
class root.Body extends Backbone.Model
  defaults: =>
    timestamp:        @now()
    rotation:         [0,0,0]
    angular_velocity: [0,0,0.01]
    velocity:         [0,0,0]
    position: [
      (Math.random() - 0.5) * 40
      (Math.random() - 0.5) * 40
      (Math.random() - 0.5) * 10
    ]

  # Public Methods
  accelerate: (x, y, z) =>
    @set_physics
      velocity: @get_vector('velocity').add new Vec3d(x, y, z)

  go_toward_at_speed: (point, speed) =>
    delta = point.minus @position()
    speed = delta.normalized().scale speed
    @set_physics
      velocity: speed

  position: =>
    @extrapolate 'position', 'velocity'

  rotation: =>
    @extrapolate 'rotation', 'angular_velocity'

  # private methods
  extrapolate: (position_attribute_name, velocity_attribute_name) =>
    position = @get_vector position_attribute_name
    velocity = @get_vector velocity_attribute_name
    elapsed  = @now() - @get 'timestamp'
    position.add velocity.scaled elapsed

  get_vector: (name) => new Vec3d @get name

  now: => new Date().getAdjustedTime()

  set_physics: (props) =>
    @set
      timestamp:        @now()
      position:         (props.position         ? @position()                   ).toArray()
      velocity:         (props.velocity         ? @get_vector 'velocity'        ).toArray()
      rotation:         (props.rotation         ? @rotation()                   ).toArray()
      angular_velocity: (props.angular_velocity ? @get_vector 'angular_velocity').toArray()
