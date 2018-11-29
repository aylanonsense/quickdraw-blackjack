local createClass = require 'src/createClass'
local Entity = require 'src/Entity'

local COLOR = { 1, 1, 1, 1 }
local FONT = love.graphics.newFont(28)

-- This is the base class for all game entities
local Card = createClass({
  width = 80,
  height = 120,
  rotation = 0, -- 0 is upright, increases clockwise to 360
  isHeld = false,
  vx = 50,
  vy = -400,
  vr = 60,
  constructor = function(self)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
  end,
  update = function(self, dt)
    if not self.isHeld then
      -- Rotate
      self.rotation = self.rotation + self.vr * dt
      -- Accelerate downwards
      self.vy = self.vy + 200 * dt
      self:applyVelocity(dt)
    end
  end,
  draw = function(self)
    local x = self.x
    local y = self.y
    local w = self.width / 2
    local h = self.height / 2
    local c = math.cos(self.rotation * math.pi / 180)
    local s = math.sin(self.rotation * math.pi / 180)
    love.graphics.setColor(COLOR)
    love.graphics.polygon('line', x+w*c+h*s, y-h*c+w*s, x-w*c+h*s, y-h*c-w*s, x-w*c-h*s, y+h*c-w*s, x+w*c-h*s, y+h*c+w*s)
    love.graphics.setFont(FONT)
    love.graphics.print(self.value, x - 10, y - 15)
  end,
  -- Checks to see if the point x,y is contained within this card
  containsPoint = function(self, x, y)
    return self.shape:testPoint(self.x, self.y, self.rotation * math.pi / 180, x, y)
  end,
  becomeHeld = function(self, hand, x, y)
    self.x = x
    self.y = y
    self.rotation = 0
    self.isHeld = true
  end
}, Entity)

return Card
