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
    
    io = socketio.listen(server)
    io.set 'log level', 2 # 0: error, 1: warn, 2: info, 3: debug
    io.sockets.on 'connection', (socket) ->
      socket.on 'helm', (data) ->
        console.log "helm says: #{data.command}!"
        #for _, socket of display_clients
          #socket.write data.command[0]
  
  display_server: =>
    display_clients = {}
    display_client_count = 0
    display_server = net.createServer (socket) ->
      id = display_client_count++
      display_clients[id] = socket
      socket.on 'close', ->
        delete display_clients[id]
    display_server.listen 26874
  
