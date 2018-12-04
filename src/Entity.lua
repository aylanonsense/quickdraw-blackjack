local createClass = require 'src/util/createClass'

-- This is the base class for all game entities
local Entity = createClass({
  isAlive = true,
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  vxPrev = nil,
  vyPrev = nil,
  frameRateIndependent = false,
  timeToDeath = 0,
  constructor = function(self) end,
  update = function(self, dt)
    self:applyVelocity(dt)
  end,
  draw = function(self) end,
  setVelocity = function(self, vx, y)
    self.vx = vx
    self.vy = vy
    self.vxPrev = vx
    self.vyPrev = vy
  end,
  applyVelocity = function(self, dt)
    if self.frameRateIndependent and self.vxPrev ~= nil and self.vyPrev ~= nil then
      self.x = self.x + (self.vx + self.vxPrev) / 2 * dt
      self.y = self.y + (self.vy + self.vyPrev) / 2 * dt
    else
      self.x = self.x + self.vx * dt
      self.y = self.y + self.vy * dt
    end
    self.vxPrev = self.vx
    self.vyPrev = self.vy
  end,
  countDownToDeath = function(self, dt)
    if self.timeToDeath > 0 then
      self.timeToDeath = self.timeToDeath - dt
      if self.timeToDeath <= 0 then
        self:die()
        return true
      end
    end
    return false
  end,
  die = function(self)
    if self.isAlive then
      self.isAlive = false
      self:onDeath()
    end
  end,
  onDeath = function(self) end
})

return Entity
