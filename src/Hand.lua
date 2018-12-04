local constants = require 'src/constants'
local createClass = require 'src/util/createClass'
local Entity = require 'src/Entity'

local COLOR = { 1, 1, 1, 1 }
local FONT = love.graphics.newFont(28)

local Hand = createClass({
  constructor = function(self)
    self.cards = {}
  end,
  update = function(self, dt)
  end,
  draw = function(self)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('fill', self.x, self.y, 1)
  end,
  addCard = function(self, card)
    local x = self.x + (constants.CARD_WIDTH + 1) * #self.cards
    local y = self.y
    table.insert(self.cards, card)
    card:becomeHeld(self, x, y)
  end
}, Entity)

return Hand
