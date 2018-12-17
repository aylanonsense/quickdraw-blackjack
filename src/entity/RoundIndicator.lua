local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  ROUND = { 54, 1, 34, 6 },
  BEST = { 24, 1, 29, 6 },
  NEW_BEST = { 1, 1, 50, 6 },
  NUMBER = {
    function(numberIndex)
      return { 83 + 6 * numberIndex, 1, 5, 6 }
    end,
    { 10 }
  }
})

local RoundIndicator = Entity.extend({
  x = constants.GAME_MIDDLE_X,
  y = constants.GAME_TOP + 3,
  renderLayer = 3,
  displayBest = false,
  isNewHighScore = false,
  draw = function(self)
    local x = self.x
    if self.displayBest then
      SPRITESHEET:draw('BEST', x - 40, self.y)
      x = x + 18
    end
    if self.isNewHighScore and self.timeAlive%0.8 < 0.5 then
      SPRITESHEET:drawCentered('NEW_BEST', self.x + 2, self.y + 14)
    end
    SPRITESHEET:draw('ROUND', x - 23, self.y)
    local roundText = ''..self.roundNumber
    local i
    for i = 1, #roundText do
      local n = tonumber(roundText:sub(i, i))
      SPRITESHEET:draw({ 'NUMBER', n + 1 }, x + 9 + 6 * i, self.y)
    end
  end
})

return RoundIndicator
