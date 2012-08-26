http    = require 'http'
express = require 'express'
path    = require 'path'
io      = require 'socket.io'

app = express()

app.configure ->
  app.use express.static path.join __dirname, '../console'

server = http.createServer app
server.listen port = 24139
console.log "Serving at http://0.0.0.0:#{port}/"

io.listen(server).sockets.on 'connection', (socket) ->
  socket.on 'helm', (data) ->
    console.log "helm says: #{data.command}!"
