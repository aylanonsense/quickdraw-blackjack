local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  BLACKJACK = { 110, 22, 89, 16 },
  BUST = { 1, 95, 59, 22 },
  MISS = { 61, 95, 59, 22 }
})

local RoundResults = Entity.extend({
  x = constants.GAME_WIDTH / 2,
  y = constants.GAME_HEIGHT / 2,
  draw = function(self)
    if self.result == 'blackjack' then
      SPRITESHEET:drawCentered('BLACKJACK', self.x, self.y)
    elseif self.result == 'bust' then
      SPRITESHEET:drawCentered('BUST', self.x, self.y)
    elseif self.result == 'miss' then
      SPRITESHEET:drawCentered('MISS', self.x, self.y)
    end
  end
})

return RoundResults
