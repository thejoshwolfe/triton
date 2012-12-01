Backbone = window?.Backbone ? require 'backbone'
_        = window?._        ? require 'underscore'
Body     = window?.Body     ? require './body'

class Bodies extends Backbone.Collection
  model: Body

window?.Bodies = Bodies
module?.exports = Bodies
