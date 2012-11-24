Http     = require 'http'
Path     = require 'path'
SocketIO = require 'socket.io'
World    = require 'world'
express  = require 'express'

module.exports = class App
  constructor: (args={}) =>
    @world = new World()

  run: (port) =>
    @web_server port

  web_server: (port) =>
    app = express()

    app.configure ->
      app.use express.static Path.join __dirname, '../console'  

    server = Http.createServer app
    server.listen port 
    console.log "Serving at http://0.0.0.0:#{port}/"

    @io = SocketIO.listen(server)
    @io.set 'log level', 2 # 0: error, 1: warn, 2: info, 3: debug
    @io.sockets.on 'connection', (socket) =>
      socket.on 'helm', (data) =>
        console.log "helm says: #{data.command}!"
        @move data.command

  # Protected
  move: (direction) =>
    @io.sockets.emit 'display', direction: direction

