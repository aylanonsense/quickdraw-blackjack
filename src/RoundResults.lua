local constants = require 'src/constants'
local Entity = require 'src/Entity'

local RoundResults = Entity.extend({
  x = constants.GAME_WIDTH / 2,
  y = constants.GAME_HEIGHT / 2,
  draw = function(self)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle('line', self.x - 30 / 2, self.y - 30 / 2, 30, 30)
  end
})

return RoundResults
