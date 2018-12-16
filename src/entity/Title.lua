local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  TITLE = { 200, 1, 122, 106 },
  SHADOW = { 200, 108, 122, 106 }
})

local Title = Entity.extend({
  width = 108,
  height = 86,
  scenes = { 'title' },
  draw = function(self)
    SPRITESHEET:drawCentered('TITLE', self.x, self.y)
  end,
  drawShadow = function(self)
    SPRITESHEET:drawCentered('SHADOW', self.x - 1, self.y + 2)
  end
})

return Title
