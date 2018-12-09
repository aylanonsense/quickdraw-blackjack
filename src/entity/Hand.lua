local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'

local COLOR = { 1, 1, 1, 1 }
local FONT = love.graphics.newFont(28)

local Hand = Entity.extend({
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
  end,
  getSumValue = function(self)
    local sumValue = 0
    local numUnusedAces = 0
    local index, card
    for index, card in ipairs(self.cards) do
      if card.rankIndex == 13 then
        numUnusedAces = numUnusedAces + 1
      end
      sumValue = sumValue + card:getValue()
    end
    while sumValue <= 11 and numUnusedAces > 0 do
      numUnusedAces = numUnusedAces - 1
      sumValue = sumValue + 10
    end
    return sumValue
  end
})

return Hand
