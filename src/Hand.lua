local createClass = require 'src/createClass'
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
  end,
  addCard = function(self, card)
    local x = self.x + 100 * #self.cards
    local y = self.y
    table.insert(self.cards, card)
    card:becomeHeld(self, x, y)
  end
}, Entity)

return Hand
