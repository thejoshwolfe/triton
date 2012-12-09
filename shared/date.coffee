root = exports ? this

Date.prototype.getAdjustedTime = -> @getTime() + (root.time_offset ? 0)
