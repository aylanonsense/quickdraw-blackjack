local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  ROUND = { 54, 1, 34, 6 },
  NUMBER = {
    function(numberIndex)
      return { 83 + 6 * numberIndex, 1, 5, 6 }
    end,
    { 10 }
  }
})

local RoundIndicator = Entity.extend({
  x = constants.GAME_MIDDLE_X,
  y = constants.GAME_TOP + 2,
  renderLayer = 3,
  draw = function(self)
    SPRITESHEET:draw('ROUND', self.x - 23, self.y)
    local roundText = ''..self.roundNumber
    local i
    for i = 1, #roundText do
      local n = tonumber(roundText:sub(i, i))
      SPRITESHEET:draw({ 'NUMBER', n + 1 }, self.x + 9 + 6 * i, self.y)
    end
  end
})

return RoundIndicator
