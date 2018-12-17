local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  FULL_HEART = { 121, 101, 11, 10 },
  EMPTY_HEART = { 133, 101, 11, 10 }
})

local Lives = Entity.extend({
  x = constants.GAME_RIGHT - 19,
  y = constants.GAME_TOP + 6,
  renderLayer = 3,
  numHearts = 3,
  isBlinking = false,
  scenes = { 'round' },
  draw = function(self)
    local i
    for i = 1, 3 do
      local sprite
      if i < self.numHearts then
        sprite = 'FULL_HEART'
      elseif i == self.numHearts and (not self.isBlinking or self.timeAlive % 0.6 < 0.3) then
        sprite = 'FULL_HEART'
      else
        sprite = 'EMPTY_HEART'
      end
      SPRITESHEET:drawCentered(sprite, self.x + 24 - 12 * i, self.y)
    end
  end
})

return Lives
