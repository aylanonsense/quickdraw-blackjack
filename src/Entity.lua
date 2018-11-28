local createClass = require 'src/createClass'

-- This is the base class for all game entities
local Entity = createClass({
  isAlive = true,
  constructor = function(self) end,
  update = function(self, dt) end,
  draw = function(self) end,
  die = function(self)
    self.isAlive = false
  end
})

return Entity
