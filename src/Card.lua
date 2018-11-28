local createClass = require 'src/createClass'
local Entity = require 'src/Entity'

-- This is the base class for all game entities
local Card = createClass({
  isAlive = true,
  width = 160,
  height = 240,
  rotation = 0, -- 0 is upright, increases clockwise to 360
  color = { 1, 1, 1, 1 },
  constructor = function(self)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
  end,
  update = function(self, dt)
    self.x = self.x + math.sin(self.rotation / 10)
    self.rotation = self.rotation + 10 * dt
    self:applyVelocity(dt)
  end,
  draw = function(self)
    local x = self.x
    local y = self.y
    local w = self.width / 2
    local h = self.height / 2
    local c = math.cos(self.rotation * math.pi / 180)
    local s = math.sin(self.rotation * math.pi / 180)
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', x, y, 4)
    love.graphics.polygon('line', x+w*c+h*s, y-h*c+w*s, x-w*c+h*s, y-h*c-w*s, x-w*c-h*s, y+h*c-w*s, x+w*c-h*s, y+h*c+w*s)
  end,
  die = function(self)
    self.isAlive = false
  end,
  -- Checks to see if the point x,y is contained within this card
  containsPoint = function(self, x, y)
    return self.shape:testPoint(self.x, self.y, self.rotation * math.pi / 180, x, y)
  end
}, Entity)

return Card
