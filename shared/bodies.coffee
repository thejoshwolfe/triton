Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Body}   = window ? require './body'

root = exports ? this
class root.Bodies extends Backbone.Collection
  model: Body

  find_within: (distance, of: position) =>
    @find (body) =>
      body.position().distance(position) < distance
