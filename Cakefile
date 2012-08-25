mkdirp = require("mkdirp")

{spawn} = require("child_process")
exec = (cmd, args=[], cb=->) ->
  bin = spawn(cmd, args)
  bin.stdout.on 'data', (data) ->
    process.stdout.write data
  bin.stderr.on 'data', (data) ->
    process.stderr.write data
  bin.on 'exit', cb

build = (watch)->
  mkdirp 'public', ->
    args = if watch then ['-w'] else []
    exec 'coffee', args.concat(['-cbo', 'lib/', 'server/'])
    exec 'jspackage', args.concat([
      'console', 'console/console.js'
    ])

watch = -> build('w')

task "watch", -> watch()

task "dev", ->
  watch()
  runServer = -> exec "node-dev", ["lib/server.js"]
  setTimeout runServer, 1000

