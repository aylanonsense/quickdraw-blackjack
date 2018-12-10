local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/effects.png', {
  EXPLOSION = {
    function(frame)
      return { 54 * frame - 53, 69, 53, 55 }
    end,
    { 5 }
  },
})

local CardExplosion = Entity.extend({
  timeToDeath = 0.4,
  draw = function(self)
    local frame = ({ 1, 2, 3, 3, 4, 4, 5, 5 })[math.min(1 + math.floor(self.timeAlive / 0.05), 8)]
    SPRITESHEET:drawCentered({ 'EXPLOSION', frame }, self.x, self.y, self.rotation)
  end
})

return CardExplosion
