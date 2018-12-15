local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  NUMBER = {
    function(numberIndex)
      return { 19 * numberIndex - 18, 118, 18, 21 }
    end,
    { 10 }
  }
})

local ScoreCalculation = Entity.extend({
  isShowingScore = false,
  renderLayer = 3,
  draw = function(self)
    if self.isShowingScore then
      local scoreText = ''..self.score
      local i
      for i = 1, #scoreText do
        local n = tonumber(scoreText:sub(i, i))
        SPRITESHEET:drawCentered({ 'NUMBER', n + 1 }, self.x + 18 * (i - #scoreText / 2 - 0.5), self.y)
      end
    else
      SPRITESHEET:drawCentered({ 'NUMBER', math.random(1, 10) }, self.x - 9, self.y)
      SPRITESHEET:drawCentered({ 'NUMBER', math.random(1, 10) }, self.x + 9, self.y)
    end
  end,
  showScore = function(self)
    self.isShowingScore = true
  end
})

return ScoreCalculation
