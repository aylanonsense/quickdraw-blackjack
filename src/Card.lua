local constants = require 'src/constants'
local createClass = require 'src/util/createClass'
local SpriteSheet = require 'src/SpriteSheet'
local Entity = require 'src/Entity'

local COLOR = { 1, 1, 1, 1 }
local FONT = love.graphics.newFont(28)

local SPRITESHEET = SpriteSheet.new('img/cards.png', {
  CARD_FRONT = { 1, 1, 23, 33 },
  SUIT_HEARTS = { 25, 27, 9, 11 },
  SUIT_DIAMONDS = { 35, 27, 9, 11 },
  SUIT_SPADES = { 45, 27, 9, 11 },
  SUIT_CLUBS = { 55, 27, 9, 11 },
  VALUE_2 = { 1, 39, 11, 9},
  VALUE_3 = { 13, 39, 11, 9},
  VALUE_4 = { 25, 39, 11, 9},
  VALUE_5 = { 37, 39, 11, 9},
  VALUE_6 = { 49, 39, 11, 9},
  VALUE_7 = { 61, 39, 11, 9},
  VALUE_8 = { 73, 39, 11, 9},
  VALUE_9 = { 85, 39, 11, 9},
  VALUE_10 = { 97, 39, 11, 9},
  VALUE_J = { 109, 39, 11, 9},
  VALUE_Q = { 121, 39, 11, 9},
  VALUE_K = { 133, 39, 11, 9},
  VALUE_A = { 145, 39, 11, 9}
})

local Card = createClass({
  width = constants.CARD_WIDTH,
  height = constants.CARD_HEIGHT,
  rotation = 0, -- 0 is upright, increases clockwise to 360
  isHeld = false,
  vr = 0,
  gravity = 0,
  frameRateIndependent = true,
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
    SPRITESHEET:drawCentered('SUIT_'..self.suit, self.x, self.y, self.rotation)
    SPRITESHEET:draw('VALUE_'..self.value, self.x, self.y, self.rotation, -constants.CARD_WIDTH / 2 + 2, -constants.CARD_HEIGHT / 2 + 1)
    SPRITESHEET:draw('VALUE_'..self.value, self.x, self.y, self.rotation + 180, -constants.CARD_WIDTH / 2 + 2, -constants.CARD_HEIGHT / 2 + 1)
  end,
  -- Launch the card in an arc such that it travels dx pixels horizontally
  --  and reaches a height of y + dy within the specified number of frames
  launch = function(self, dx, dy, t)
    -- At time = t/2, the card is at peak height (v = 4 * h / t)
    self.vy = 4 * dy / t
    -- At time = t/2, the card is at velocity = 0 (a = -2v / t)
    self.gravity = -2 * self.vy / t
    -- The card moves linearly horizontally, without acceleration (v = x / t)
    self.vx = dx / t
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
