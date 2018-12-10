local constants = require 'src/constants'
local SpriteSheet = require 'src/util/SpriteSheet'
local Promise = require 'src/util/Promise'
local Entity = require 'src/entity/Entity'
local CardExplosion = require 'src/entity/CardExplosion'
local Gunshot = require 'src/entity/Gunshot'

local COLOR = { 1, 1, 1, 1 }
local FONT = love.graphics.newFont(28)

local SPRITESHEET = SpriteSheet.new('img/cards.png', {
  CARD_FRONT = { 1, 1, 23, 33 },
  SUIT = {
    function(suitIndex)
      return { 6 * suitIndex + 19, 27, 5, 5 }
    end,
    { 4 }
  },
  RANK = {
    function(rankIndex, colorIndex)
      return { 12 * rankIndex - 11, 10 * colorIndex + 25, 11, 9 }
    end,
    { 13, 2 }
  },
  PIPS = {
    function(rankIndex, colorIndex)
      return { 12 * rankIndex - 11, 14 * colorIndex + 41, 11, 13 }
    end,
    { 9, 2 }
  },
  FACES = {
    function(rankIndex, suitIndex)
      return { 13 * rankIndex - 12, 17 * suitIndex + 65, 12, 16 }
    end,
    { 3, 4 }
  },
  ACES = {
    function(suitIndex)
      return { 20 * suitIndex + 5, 1, 19, 25 }
    end,
    { 4 }
  }
})

local Card = Entity.extend({
  width = constants.CARD_WIDTH,
  height = constants.CARD_HEIGHT,
  rotation = 0, -- 0 is upright, increases clockwise to 360
  vr = 0,
  gravity = 0,
  frameRateIndependent = true,
  rankIndex = 13,
  suitIndex = 2,
  canBeShot = false,
  constructor = function(self)
    Entity.constructor(self)
    self.colorIndex = self.suitIndex < 3 and 1 or 2
    self.shape = love.physics.newRectangleShape(self.width, self.height)
  end,
  update = function(self, dt)
    -- Rotate
    if not self:animationsInclude('rotation') then
      self.rotation = self.rotation + self.vr * dt
    end
    -- Accelerate downwards
    self.vy = self.vy + self.gravity * dt
    Entity.update(self, dt)
    -- Fall offscreen
    if self.y > constants.GAME_HEIGHT + constants.CARD_HEIGHT then
      self:die()
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
    if self.rankIndex == 13 then
      SPRITESHEET:drawCentered({ 'ACES', self.suitIndex }, self.x, self.y, self.rotation)
    else
      SPRITESHEET:draw({ 'RANK', self.rankIndex, self.colorIndex }, self.x, self.y, self.rotation, -constants.CARD_WIDTH / 2 + 2, -constants.CARD_HEIGHT / 2 + 1)
      SPRITESHEET:draw({ 'RANK', self.rankIndex, self.colorIndex }, self.x, self.y, self.rotation + 180, -constants.CARD_WIDTH / 2 + 2, -constants.CARD_HEIGHT / 2 + 1)
      SPRITESHEET:draw({ 'SUIT', self.suitIndex }, self.x, self.y, self.rotation, -constants.CARD_WIDTH / 2 + 3, -constants.CARD_HEIGHT / 2 + 11)
      SPRITESHEET:draw({ 'SUIT', self.suitIndex }, self.x, self.y, self.rotation + 180, -constants.CARD_WIDTH / 2 + 3, -constants.CARD_HEIGHT / 2 + 11)
      if self.rankIndex < 10 then
        SPRITESHEET:draw({ 'PIPS', self.rankIndex, self.colorIndex }, self.x, self.y, self.rotation, -1.5, -12.5)
        SPRITESHEET:draw({ 'PIPS', self.rankIndex, self.colorIndex }, self.x, self.y, self.rotation + 180, -1.5, -12.5)
      else
        SPRITESHEET:draw({ 'FACES', self.rankIndex - 9, self.suitIndex }, self.x, self.y, self.rotation, constants.CARD_WIDTH / 2 - 14, -constants.CARD_HEIGHT / 2)
        SPRITESHEET:draw({ 'FACES', self.rankIndex - 9, self.suitIndex }, self.x, self.y, self.rotation + 180, constants.CARD_WIDTH / 2 - 14, -constants.CARD_HEIGHT / 2)
      end
    end
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
  -- Throws a card to a specified point
  throw = function(self, x, y)
    local dx = x - self.x
    local dy = y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local startRotation = ((self.rotation % 360) + 360) % 360
    local dr = (startRotation < 180 and -startRotation or 360 - startRotation)
    local endRotation = self.rotation + dr
    local duration = constants.TURBO_MODE and 0.1 or dist / 125
    local slideDuration = 0.65 * duration
    self:animate({
      x = { change = 0.75 * dx },
      y = { change = 0.75 * dy },
      rotation = { change = 0.95 * dr }
    }, duration - slideDuration)
    Promise.newActive(duration - slideDuration)
      :andThen(function()
        self:animate({
          x = { value = x, easing = 'easeIn' },
          y = { value = y, easing = 'easeIn' },
          rotation = { value = endRotation, easing = 'easeIn' }
        }, slideDuration)
      end)
    return duration
  end,
  -- Checks to see if the point x,y is contained within this card
  containsPoint = function(self, x, y)
    return self.shape:testPoint(self.x, self.y, self.rotation * math.pi / 180, x, y)
  end,
  onMousePressed = function(self, x, y)
    if self.canBeShot and self:containsPoint(x, y) then
      self.canBeShot = false
      CardExplosion:spawn({
        x = self.x,
        y = self.y,
        rotation = self.rotation
      })
      Gunshot:spawn({
        x = x,
        y = y
      })
      self.hand:addShotCard(self)
    end
  end,
  getValue = function(self)
    if self.rankIndex < 10 then
      return self.rankIndex + 1
    elseif self.rankIndex == 13 then
      return 1
    else
      return 10
    end
  end
})

return Card
