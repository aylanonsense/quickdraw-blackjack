local createClass = require 'src/createClass'
local SpriteSheet = require 'src/SpriteSheet'
local Entity = require 'src/Entity'

local COLOR = { 1, 1, 1, 1 }
local FONT = love.graphics.newFont(28)

local SPRITESHEET = SpriteSheet.new('img/cards.png', {
  CARD_FRONT = { 1, 1, 23, 33 },
  SUIT_HEART = { 25, 27, 9, 11 }
})

local Card = createClass({
  width = 23,
  height = 33,
  rotation = 30, -- 0 is upright, increases clockwise to 360
  isHeld = false,
  vx = 0,
  vy = 0,
  vr = 30,
  gravity = 0,
  constructor = function(self)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
  end,
  update = function(self, dt)
    if not self.isHeld then
      -- Rotate
      self.rotation = self.rotation + self.vr * dt
      -- Accelerate downwards
      self.vy = self.vy + self.gravity * dt
      self:applyVelocity(dt)
    end
  end,
  draw = function(self)
    local x = self.x
    local y = self.y
    local w = self.width / 2
    local h = self.height / 2
    local radians = self.rotation * math.pi / 180
    local c = math.cos(radians)
    local s = math.sin(radians)
    SPRITESHEET:drawCentered('CARD_FRONT', self.x, self.y, self.rotation)
    SPRITESHEET:drawCentered('SUIT_HEART', self.x, self.y, self.rotation)
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
