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

  go_to_point: (destination, acceleration_magnitude) =>
    # stopped  burn->  cruise  <-burn  stopped
    #        0========--------========0
    now = @now()
    here = @position()
    total_delta = destination.minus here
    total_distance = total_delta.length()
    acceleration = total_delta.normalized().scale acceleration_magnitude

    third_distance = total_distance / 3
    burn_inverval = Math.sqrt 2 * third_distance / acceleration_magnitude

    cruising_velocity = acceleration.scaled burn_inverval
    cruising_inverval = third_distance / cruising_velocity.length()

    @set_physics [
      {
        acceleration: acceleration
        velocity: new Vec3d
      }
      {
        timestamp: now + burn_inverval
        position: here.plus total_delta.scaled 1/3
        velocity: cruising_velocity
      }
      {
        timestamp: now + burn_inverval + cruising_inverval
        position: here.plus total_delta.scaled 2/3
        acceleration: acceleration.scaled -1
        velocity: cruising_velocity
      }
      {
        timestamp: now + burn_inverval + cruising_inverval + burn_inverval
        position: destination
        velocity: new Vec3d
      }
    ]

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
