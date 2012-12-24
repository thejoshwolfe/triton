require './date'
Http     = require 'http'
Path     = require 'path'
SocketIO = require 'socket.io'
express  = require 'express'
{World}  = require './world'
{Blurbs} = require './blurbs'
{Vec3d}  = require './vec3d'

module.exports = class App
  constructor: (args={}) ->
    @mission_blurbs = new Blurbs
    @mission_blurbs.on 'all', @send_mission_blurbs
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
      unless @mission_blurbs.any()
        @mission_blurbs.reset
          message: 'Cure diseases, go to a planet to collect a life form.'
          status:  ''
          type:    'Objective'

    socket.on 'beam_aboard', =>
      if @mission_blurbs.any() and @mission_blurbs.size() < 3 and @scan_success
        @teleport_success = @world.is_ship_near_planet()
        @teleport_message = if @teleport_success then 'Life form is aboard.' else 'No planets within range.'

        @mission_blurbs.add [
            message: 'Life form aboard'
            status:  'success'
            type:    'Objective Complete'
          ,
            message: 'Do science on the life form.'
            status:  ''
            type:    'Objective'
          ]
      else
        @teleport_success = false
        @teleport_message = 'Nothing to beam aboard.'

      @io.sockets.emit 'teleport_results', @teleport_success, @teleport_message

    socket.on 'helm', (data) =>
      @world.helm_command data.command

    socket.on 'long_range_scan', =>
      @io.sockets.emit 'scan_results', @scan_success = false, @scan_message = 'Go to a planet.'

    socket.on 'new_course', (cursor_position) =>
      @world.set_new_course new Vec3d cursor_position

    socket.on 'request_world', =>
      socket.emit 'world', @world.toJSON()

    socket.on 'request_mission_blurbs', => 
      socket.emit 'mission_blurbs', @mission_blurbs.toJSON()

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
    @mission_blurbs.reset()
    @io?.sockets.emit 'scan_results', @scan_success = null, @scan_message = null

  send_mission_blurbs: =>
    @io?.sockets.emit 'mission_blurbs', @mission_blurbs.toJSON()

  send_world: =>
    return unless @io?
    @io.sockets.emit 'world', @world.toJSON()

