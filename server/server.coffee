
http = require 'http'
express = require 'express'
path = require 'path'

app = express()
app.configure ->
  app.use express.static path.join __dirname, '../console'

app_server = http.createServer app
port = 24139
app_server.listen port
console.log "Serving at http://0.0.0.0:#{port}/"

