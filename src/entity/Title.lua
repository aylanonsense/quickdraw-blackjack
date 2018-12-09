local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  TITLE = { 1, 8, 108, 86 }
})

local Title = Entity.extend({
  width = 108,
  height = 86,
  scenes = { 'title' },
  draw = function(self)
    SPRITESHEET:drawCentered('TITLE', self.x, self.y)
  end
})

return Title
