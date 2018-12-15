local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/effects.png', {
  GUNSHOT = {
    function(frame)
      return { 97 * frame - 96, 1, 96, 67 }
    end,
    { 2 }
  },
})

local Gunshot = Entity.extend({
  timeToDeath = 0.1,
  renderLayer = 8,
  constructor = function(self)
    Entity.constructor(self)
    self.rotation = math.random(0, 360)
  end,
  draw = function(self)
    local frame = math.min(1 + math.floor(self.timeAlive / 0.05), 2)
    SPRITESHEET:drawCentered({ 'GUNSHOT', frame }, self.x, self.y, self.rotation)
  end
})

return Gunshot
