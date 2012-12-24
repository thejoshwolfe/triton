Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
{Blurb}   = window ? require './blurb'

root = exports ? this
class root.Blurbs extends Backbone.Collection
  model: Blurb
