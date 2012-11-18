http     = require 'http'
express  = require 'express'
net      = require 'net'
path     = require 'path'
socketio = require 'socket.io'

module.exports = class App
  run: (port) =>
    @web_server port

  web_server: (port) =>
    app = express()

    app.configure ->
      app.use express.static path.join __dirname, '../console'  

    server = http.createServer app
    server.listen port 
    console.log "Serving at http://0.0.0.0:#{port}/"

    @io = socketio.listen(server)
    @io.set 'log level', 2 # 0: error, 1: warn, 2: info, 3: debug
    @io.sockets.on 'connection', (socket) =>
      socket.on 'helm', (data) =>
        console.log "helm says: #{data.command}!"
        @move data.command

  # Protected
  move: (direction) =>
    @io.sockets.emit 'display', direction: direction

