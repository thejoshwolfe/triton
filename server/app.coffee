require './date'
Http     = require 'http'
Path     = require 'path'
SocketIO = require 'socket.io'
express  = require 'express'
{World}  = require './world'
{Vec3d}  = require './vec3d'

module.exports = class App
  constructor: (args={}) ->
    @reset()

  run: (port) =>
    app = express()

    app.configure ->
      app.use express.static Path.join __dirname, '../console'

    server = Http.createServer app
    server.listen port
    console.log "Serving at http://0.0.0.0:#{port}/"

    @io = SocketIO.listen(server)
    @io.set 'log level', 2 # 0: error, 1: warn, 2: info, 3: debug
    @io.sockets.on 'connection', @events 

  events: (socket) =>
    socket.on 'accept_mission', =>
      @io.sockets.emit 'mission_blurb', @mission_blurb ?= 'Cure diseases.'

    socket.on 'helm', (data) =>
      @world.helm_command data.command

    socket.on 'long_range_scan', =>
      @io.sockets.emit 'scan_results', @scan_success = false, @scan_message = 'Go to a planet.'

    socket.on 'new_course', (cursor_position) =>
      @world.set_new_course new Vec3d cursor_position

    socket.on 'request_world', =>
      socket.emit 'world', @world.toJSON()

    socket.on 'request_mission_blurb', =>
      socket.emit 'mission_blurb', @mission_blurb

    socket.on 'request_scan_results', =>
      socket.emit 'scan_results', @scan_success, @scan_message

    socket.on 'reset', @reset

    socket.on 'scan_planet', =>
      @scan_success = @world.is_ship_near_planet()
      @scan_message = if @scan_success then 'Life signs.' else 'No planets within range.'
      @io.sockets.emit 'scan_results', @scan_success, @scan_message

    socket.on 'time_check', (data) =>
      data.server_time = new Date().getTime()
      socket.emit 'time_update', data

  # Protected
  reset: =>
    @world = new World()
    @world.on 'all', @send_world
    @send_world()
    @io?.sockets.emit 'mission_blurb', @mission_blurb = null
    @io?.sockets.emit 'scan_results', @scan_success = null, @scan_message = null

  send_world: =>
    return unless @io?
    @io.sockets.emit 'world', @world.toJSON()

