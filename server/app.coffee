require './date'
Http      = require 'http'
Path      = require 'path'
SocketIO  = require 'socket.io'
express   = require 'express'
{World}   = require './world'
{Mission} = require './mission'

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
    socket.on 'accept_mission',  @world.accept_mission
    socket.on 'beam_aboard',     @world.beam_aboard
    socket.on 'do_science',      @world.do_science
    socket.on 'helm',            @world.helm_command
    socket.on 'long_range_scan', @world.long_range_scan
    socket.on 'reset',           @reset
    socket.on 'scan_planet',     @world.scan_planet
    socket.on 'set_new_course',  @world.set_new_course

    socket.on 'request_world', =>
      socket.emit 'world', @world.toJSON()

    socket.on 'time_check', (data) =>
      data.server_time = new Date().getTime()
      socket.emit 'time_update', data

  # Protected
  reset: =>
    @world = new World()
    @world.on 'all', @send_world
    @send_world()
    @io?.sockets.emit 'scan_results', @scan_success = null, @scan_message = null

  send_world: =>
    @io?.sockets.emit 'world', @world.toJSON()

