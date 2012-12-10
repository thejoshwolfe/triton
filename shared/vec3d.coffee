# based on https://github.com/superjoe30/chem/blob/master/src/shared/chem/vec2d.co
root = exports ? this
root.Vec3d = class Vec3d
  constructor: (x_or_something, y, z) ->
    if y?
      @x = x_or_something
      @y = y
      @z = z
    else if x_or_something?
      if x_or_something instanceof Array
        [@x, @y, @z] = x_or_something
      else
        {@x, @y, @z} = x_or_something
    else
      @x = 0
      @y = 0
      @z = 0

  add: (other) =>
    @x += other.x
    @y += other.y
    @z += other.z
    this
  sub: (other) =>
    @x -= other.x
    @y -= other.y
    @z -= other.z
    this
  plus: (other) => @clone().add(other)
  minus: (other) => @clone().sub(other)
  neg: =>
    @x = -@x
    @y = -@y
    @z = -@z
    this
  mult: (other) =>
    @x *= other.x
    @y *= other.y
    @z *= other.z
    this
  times: (other) => @clone().mult(other)
  scale: (scalar) =>
    @x *= scalar
    @y *= scalar
    @z *= scalar
    this
  scaled: (scalar) => @clone().scale(scalar)
  clone: => new Vec3d this
  apply: (func) =>
    @x = func(@x)
    @y = func(@y)
    @z = func(@z)
    this
  applied: (func) => @clone().apply(func)
  equals: (other) => @x is other.x and @y is other.y and @z is other.z
  toString: => "(#{@x}, #{@y}, #{@z})"
  toArray: => [@x, @y, @z]
  dot: (other) => @x*other.x + @y*other.y + @z*other.z
  lengthSqrd: => @dot this
  length: => Math.sqrt(@lengthSqrd())
  distanceSqrd: (other) => @minus(other).lengthSqrd()
  distance: (other) => Math.sqrt(@distanceSqrd(other))
  normalize: =>
    length = @length()
    if length is 0
      this
    else
      @scale(1 / length)
  normalized: => @clone().normalize()
  boundMin: (other) =>
    if @x < other.x then @x = other.x
    if @y < other.y then @y = other.y
    if @z < other.z then @z = other.z
  boundMax: (other) =>
    if @x > other.x then @x = other.x
    if @y > other.y then @y = other.y
    if @z > other.z then @z = other.z
  floor: => @apply(Math.floor)
  floored: => @applied(Math.floor)
  project: (other) =>
    @scale(@dot(other) / other.lengthSqrd())
    this

