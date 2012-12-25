Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Blurbs} = window ? require './blurbs'

root = exports ? this
class root.Mission extends Backbone.Model
  defaults:
    stage:    0
    title:    null

  initialize: =>
    @blurbs = new Blurbs @get 'blurbs'
    @blurbs.on 'all', (event, args...) =>
      @trigger "blurbs:#{event}", args...

  toJSON: =>
    _.extend super,
      accepted: @is_accepted()
      blurbs: @blurbs.toJSON()

  # Instance Methods

  accept: =>
    return if @is_accepted()
    @blurbs.reset
      message: 'Cure diseases, go to a planet to collect a life form.'
      status:  ''
      type:    'Objective'
    , silent: true
    @set stage: 1, title: 'Got your baby.'

  beam_aboard: (body) =>
    if body? and @get('stage') == 1
      @set {stage: 2}, silent: true
      @blurbs.add [
          message: 'Life form aboard'
          status:  'success'
          type:    'Teleport Result'
        ,
          message: 'Do science on the life form.'
          status:  ''
          type:    'Objective'
        ]
    else
      @blurbs.add
        message: 'Nothing to beam aboard.'
        status:  'error'
        type:    'Teleport Result'

  do_science: =>
    if @get('stage') == 2
      @set {stage: 3}, silent: true
      @blurbs.add [
        message: 'Science has been done.'
        status:  'success'
        type:    'Science Result'
      ,
        message: 'Return the life form back to the planet'
        status:  ''
        type:    'Objective'
      ]
    else
      @blurbs.add
        message: 'Nothing to do science on.'
        status:  'error'
        type:    'Science Result'

  is_accepted: =>
    @get('stage') > 0

  long_range_scan: =>
    if @is_accepted()
      @blurbs.add
        message: 'Go to a planet.'
        status:  ''
        type:    'Long Range Scan Result'
    else
      @blurbs.add
        message: 'There is nothing out there.'
        status:  'error'
        type:    'Long Range Scan Result'

  scan: (body) =>
    @blurbs.add @scan_result body

  scan_result: (body) =>
    if body?
      switch @get 'stage'
        when 0
          message: 'No life signs detected.'
          status:  'error'
          type:    'Scan Result'
        else
          message: 'Life signs detected.'
          status:  'success'
          type:    'Scan Result'
    else
      message: 'No planets within range'
      status:  'error'
      type:    'Scan Result'
