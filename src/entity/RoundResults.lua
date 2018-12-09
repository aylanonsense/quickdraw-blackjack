local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  BUST = { 1, 95, 59, 22 }
})

local RoundResults = Entity.extend({
  x = constants.GAME_WIDTH / 2,
  y = constants.GAME_HEIGHT / 2,
  draw = function(self)
    SPRITESHEET:drawCentered('BUST', self.x, self.y)
  end
})

return RoundResults
