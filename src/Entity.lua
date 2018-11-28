local createClass = require 'src/createClass'

-- This is the base class for all game entities
local Entity = createClass({
  isAlive = true,
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  constructor = function(self) end,
  update = function(self, dt)
    self:applyVelocity(dt)
  end,
  draw = function(self) end,
  applyVelocity = function(self, dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
  end,
  die = function(self)
    self.isAlive = false
  end
})

return Entity
