Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Body}   = window ? require './body'

root = exports ? this
class root.Bodies extends Backbone.Collection
  model: Body
