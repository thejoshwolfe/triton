Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Vec3d}  = window ? require './vec3d'

root = exports ? this
class root.Body extends Backbone.Model
  defaults: =>
    trajectory: [{timestamp: @now()}]

  # Public Methods
  accelerate: (x, y, z) =>
    @set_physics
      velocity: @velocity().add new Vec3d(x, y, z)

  go_to_point: (point, acceleration_magnitude) =>
    delta = point.minus @position()
    acceleration = delta.normalized().scale acceleration_magnitude
    distance = delta.length()
    travel_time = Math.sqrt(2 * distance / acceleration_magnitude)
    arrival_time = @now() + travel_time
    velocity = new Vec3d
    trajectory = [
      {acceleration, velocity}
      {
        timestamp: arrival_time
        position: point
        velocity
      }
    ]
    @set_physics trajectory

  position: =>
    @extrapolate 'position', 'velocity', 'acceleration'
  velocity: =>
    @extrapolate 'velocity', 'acceleration'

  rotation: =>
    @extrapolate 'rotation', 'angular_velocity'
  angular_velocity: =>
    @extrapolate 'angular_velocity'

  # private methods
  extrapolate: (position_attribute_name, velocity_attribute_name, acceleration_attribute_name) =>
    now = @now()
    trajectory = @trajectory now
    # x = x0 + v0 t + 1/2 a t^2
    position     = new Vec3d(trajectory[position_attribute_name]     ? [0,0,0])
    velocity     = new Vec3d(trajectory[velocity_attribute_name]     ? [0,0,0])
    acceleration = new Vec3d(trajectory[acceleration_attribute_name] ? [0,0,0])
    elapsed      = now - trajectory.timestamp
    # x += v_0 * t
    position.add velocity.scaled elapsed
    # x += 1/2 * a * t^2
    position.add acceleration.scaled elapsed * elapsed * 0.5

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
    trajectory = []
    for segment_props in props
      segment = {}
      segment.timestamp = segment_props.timestamp ? @now()
      segment.position          = (segment_props.position         ? @position()        ).toArray()
      segment.velocity          = (segment_props.velocity         ? @velocity()        ).toArray()
      segment.acceleration      = (segment_props.acceleration     ? new Vec3d          ).toArray()
      segment.rotation          = (segment_props.rotation         ? @rotation()        ).toArray()
      segment.angular_velocity  = (segment_props.angular_velocity ? @angular_velocity()).toArray()
      trajectory.push segment
    @set trajectory: trajectory
