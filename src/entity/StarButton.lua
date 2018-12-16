local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local Gunshot = require 'src/entity/Gunshot'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  STAR = { 1, 163, 63, 67 },
  SHADOW = { 65, 163, 63, 67 },
  PLAY = { 129, 163, 33, 13 },
  DONE = { 129, 177, 33, 13 },
  NEXT = { 129, 191, 33, 13 }
})

local StarButton = Entity.extend({
  width = 41,
  height = 31,
  hasBeenClicked = false,
  gravity = 0.0,
  vr = 0.0,
  rotation = 0.0,
  renderLayer = 10,
  constructor = function(self)
    Entity.constructor(self)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
  end,
  update = function(self, dt)
    self.vy = self.vy + self.gravity * dt
    self.rotation = self.rotation + self.vr * dt
    Entity.update(self, dt)
    if self.y > constants.GAME_HEIGHT + 40 then
      self:die()
    end
  end,
  draw = function(self)
    SPRITESHEET:drawCentered('STAR', self.x, self.y, self.rotation)
    if self.text == 'play' then
      SPRITESHEET:drawCentered('PLAY', self.x, self.y, self.rotation)
    elseif self.text == 'done' then
      SPRITESHEET:drawCentered('DONE', self.x, self.y, self.rotation)
    elseif self.text == 'next' then
      SPRITESHEET:drawCentered('NEXT', self.x, self.y, self.rotation)
    end
  end,
  drawShadow = function(self)
    SPRITESHEET:drawCentered('SHADOW', self.x - 1, self.y + 2, self.rotation)
  end,
  -- Checks to see if the point x,y is contained within this button
  containsPoint = function(self, x, y)
    return self.shape:testPoint(self.x, self.y, 0, x, y)
  end,
  onMousePressed = function(self, x, y)
    if self:containsPoint(x, y) then
      if not self.hasBeenClicked  then
        self.hasBeenClicked = true
        self.renderLayer = 11 + math.random()
        self:onClicked(x, y)
      end
      local dx = x - self.x
      self.vx = -10 * dx + math.random(-50, 50)
      self.vy = math.random(-300, -200)
      self.gravity = 1000
      self.vr = math.random(500, 800) * (math.random() < 0.5 and -1 or 1)
      Gunshot:spawn({ x = x, y = y })
    end
  end,
  onClicked = function(self, x, y) end
})

return StarButton
