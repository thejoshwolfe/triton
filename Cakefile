eco         = require 'eco'
fs          = require 'fs'
mkdirp      = require 'mkdirp'
path        = require 'path'
{watchTree} = require 'watch'
which       = require('which').sync
{spawn}     = require 'child_process'
{walk}      = require 'walk'

exec = (cmd, args=[], cb=(->), stdout=process.stdout.write) ->
  bin = spawn(which(cmd), args)
  bin.stdout.on 'data', stdout
  bin.stderr.on 'data', process.stderr.write
  bin.on 'exit', cb

eco_compile = (input_path) ->
  fs.readFile input_path, (err, data) ->
    output_path = input_path.replace(/\.eco$/, '.js')
    backslash   = new RegExp('\\\\', 'g') # Avoid syntax highlighting problem in Sublime 2
    jst_path    = input_path.replace(/\.eco$/, '').replace(backslash, '/')
    source = "window.JST['#{jst_path}'] = "
    source += eco.precompile data.toString()
    fs.writeFile output_path, source, ->
      console.log "compiled: '#{input_path}' -> '#{output_path}'"

json_compile = (input_path) ->
  output_path = input_path.replace(/\.cson$/, '.json')

  output = ''
  exec 'coffee', ['-bp', input_path], -> # On exit
    fs.writeFile output_path, output[1...-3], ->
      console.log "compiled: '#{input_path}' -> '#{output_path}'"
  , (stdout) -> # On stdout
    output += stdout

build = (watch)->
  mkdirp 'public', ->
    args = if watch then ['-w'] else []
    exec 'coffee', args.concat(['-co', 'lib/', 'server/'])
    exec 'coffee', args.concat(['-co', 'lib/', 'shared/'])
    exec 'coffee', args.concat(['-co', 'console/shared/', 'shared/'])
    exec 'coffee', args.concat(['-c', 'console/', 'console/views/'])

    if watch
      watchTree 'console/templates', {ignoreDotFiles: true}, (file_path, curr) ->
        return unless curr?.nlink # file was removed
        return unless /\.eco$/.exec(file_path)? # return if this isn't an eco file
        eco_compile file_path
      watchTree 'console/meshes', {ignoreDotFiles: true}, (file_path, curr) ->
        return unless curr?.nlink # file was removed
        return unless /\.cson$/.exec(file_path)? # return if this isn't an cson file
        json_compile file_path

    walk('console/templates').on 'file', (root, fileStats, next) ->
      file_path = path.join root, fileStats.name
      eco_compile file_path if /\.eco$/.exec(file_path)?
      next()

    walk('console/meshes').on 'file', (root, fileStats, next) ->
      file_path = path.join root, fileStats.name
      json_compile file_path if /\.cson$/.exec(file_path)?
      next()

watch = -> build('w')

task "build", -> build()
task "watch", -> watch()

task "dev", ->
  watch()
  runServer = -> exec "node-dev", ["server.js"]
  setTimeout runServer, 1000

