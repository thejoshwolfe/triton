Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Vec3d}  = window ? require './vec3d'

root = exports ? this
class root.Body extends Backbone.Model
  defaults: =>
    trajectory: [
      timestamp:        @now()
      rotation:         [0,0,0]
      angular_velocity: [0,0,0]
      velocity:         [0,0,0]
      position:         [0,0,0]
    ]

  # Public Methods
  accelerate: (x, y, z) =>
    @set_physics
      velocity: @velocity().add new Vec3d(x, y, z)

  go_toward_at_speed: (point, speed) =>
    delta = point.minus @position()
    velocity = delta.normalized().scale speed
    travel_time = delta.length() / speed
    arrival_time = @now() + travel_time
    trajectory = []
    trajectory.push
      velocity: velocity
    trajectory.push
      timestamp: arrival_time
      position: point
      velocity: new Vec3d
    @set_physics trajectory
    console.log @get 'trajectory'

  position: =>
    @extrapolate 'position', 'velocity'
  velocity: =>
    @get_vector 'velocity'

  rotation: =>
    @extrapolate 'rotation', 'angular_velocity'
  angular_velocity: =>
    @get_vector 'angular_velocity'

  # private methods
  extrapolate: (position_attribute_name, velocity_attribute_name) =>
    now = @now()
    trajectory = @trajectory now
    position = new Vec3d trajectory[position_attribute_name]
    velocity = new Vec3d trajectory[velocity_attribute_name]
    elapsed  = now - trajectory.timestamp
    position.add velocity.scaled elapsed

  get_vector: (name) =>
    new Vec3d @trajectory()[name]
  trajectory: (now) =>
    segments = @get 'trajectory'
    return segments[0] if segments.length is 1
    now ?= @now()
    for i in [segments.length-1..1] by -1
      segment = segments[i]
      return segment if segment.timestamp <= now
    return segments[0]

  now: => new Date().getAdjustedTime()

  set_physics: (props) =>
    unless props instanceof Array
      props = [props]
    for segment in props
      segment.timestamp        ?= @now()
      segment.position         ?= @position()
      segment.velocity         ?= @velocity()
      segment.rotation         ?= @rotation()
      segment.angular_velocity ?= @angular_velocity()
    @set
      trajectory: for segment in props
        timestamp:        segment.timestamp
        position:         segment.position.toArray()
        velocity:         segment.velocity.toArray()
        rotation:         segment.rotation.toArray()
        angular_velocity: segment.angular_velocity.toArray()
