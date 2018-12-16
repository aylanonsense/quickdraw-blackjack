local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  BLACKJACK = { 110, 22, 89, 16 },
  BUST = { 1, 95, 59, 22 },
  MISS = { 61, 95, 59, 22 },
  BLAM = { 1, 231, 105, 50 },
  BLAM_SHADOW = { 107, 231, 105, 50 }
})

local RoundResults = Entity.extend({
  x = constants.GAME_WIDTH / 2,
  y = constants.GAME_HEIGHT / 2,
  renderLayer = 3,
  scale = 0.0,
  constructor = function(self)
    Entity.constructor(self)
    self:animate({
      scale = { value = 1.0, easing = 'easeIn' }
    }, 0.2)
  end,
  draw = function(self)
    if self.result == 'blackjack' then
      SPRITESHEET:drawCentered('BLACKJACK', self.x, self.y, 0, 0, 0, self.scale, self.scale)
    else
      SPRITESHEET:drawCentered('BLAM', self.x, self.y, 0, 0, 0, self.scale, self.scale)
      if self.result == 'bust' then
        SPRITESHEET:drawCentered('BUST', self.x, self.y, 0, 0, 0, self.scale, self.scale)
      elseif self.result == 'miss' then
        SPRITESHEET:drawCentered('MISS', self.x, self.y, 0, 0, 0, self.scale, self.scale)
      end
    end
  end,
  drawShadow = function(self)
    if self.result == 'blackjack' then
      -- TODO
    else
      SPRITESHEET:drawCentered('BLAM_SHADOW', self.x - 1, self.y + 2, 0, 0, 0, self.scale, self.scale)
    end
  end
})

return RoundResults
