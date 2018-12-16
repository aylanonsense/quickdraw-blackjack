local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  STAR = { 1, 163, 63, 67 },
  SHADOW = { 65, 163, 63, 67 },
  PLAY = { 129, 163, 33, 13 },
  DONE = { 129, 177, 33, 13 }
})

local PlayButton = Entity.extend({
  width = 41,
  height = 31,
  scenes = { 'title' },
  constructor = function(self)
    Entity.constructor(self)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
  end,
  draw = function(self)
    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.rectangle('line', self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    SPRITESHEET:drawCentered('STAR', self.x, self.y)
    SPRITESHEET:drawCentered('PLAY', self.x, self.y)
  end,
  drawShadow = function(self)
    SPRITESHEET:drawCentered('SHADOW', self.x - 1, self.y + 2)
  end,
  -- Checks to see if the point x,y is contained within this button
  containsPoint = function(self, x, y)
    return self.shape:testPoint(self.x, self.y, 0, x, y)
  end,
  onMousePressed = function(self, x, y)
    if self:containsPoint(x, y) then
      self:onClicked(x, y)
    end
  end,
  onClicked = function(self, x, y) end
})

return PlayButton
