Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Blurbs} = window ? require './blurbs'

root = exports ? this
class root.Mission extends Backbone.Model
  defaults:
    accepted: false
    title:    null

  initialize: =>
    @blurbs = new Blurbs @get 'blurbs'

  toJSON: =>
    _.extend super,
      blurbs: @blurbs.toJSON()

  # Instance Methods

  accept: =>
    @set accepted: true, title: 'Got your baby.'
    @blurbs.reset
      message: 'Cure diseases, go to a planet to collect a life form.'
      status:  ''
      type:    'Objective'

  is_accepted: =>
    @get 'accepted'
