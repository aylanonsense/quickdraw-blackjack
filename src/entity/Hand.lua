local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local Promise = require 'src/util/Promise'
local Sounds = require 'src/Sounds'

local COLOR = { 1, 1, 1, 1 }
local FONT = love.graphics.newFont(28)

local Hand = Entity.extend({
  constructor = function(self)
    Entity.constructor(self)
    local index, card
    for index, card in ipairs(self.cards) do
      card.hand = self
      card.renderLayer = 9 + math.random()
    end
    self.shotCards = {}
  end,
  dealCards = function(self)
    local index, card
    for index, card in ipairs(self.cards) do
      local i = (index - #self.cards / 2 - 0.5)
      Promise.newActive(0.1 * index)
        :andThen(function()
          card:throw(constants.GAME_MIDDLE_X + (constants.CARD_WIDTH + 2) * i, 0.6 * constants.GAME_HEIGHT)
          Sounds.dealCard:play()
        end)
    end
    return constants.TURBO_MODE and 0.1 or 1.5
  end,
  moveToBottom = function(self)
    local duration = constants.TURBO_MODE and 0.1 or 1.75
    local index, card
    for index, card in ipairs(self.cards) do
      card:animate({
        y = { value = constants.GAME_BOTTOM - 0.35 * constants.CARD_HEIGHT, easing = 'easeIn' }
      }, duration)
    end
    return duration
  end,
  moveToCenter = function(self)
    local duration = constants.TURBO_MODE and 0.1 or 1.75
    local index, card
    for index, card in ipairs(self.cards) do
      card:animate({
        y = { value = constants.GAME_MIDDLE_Y - constants.CARD_HEIGHT / 2, easing = 'easeIn' }
      }, duration)
    end
    return duration
  end,
  addShotCard = function(self, card)
    table.insert(self.shotCards, card)
    card.vx = 0
    card.vy = 0
    card.vr = 0
    card.gravity = 0
    card.renderLayer = 9 + math.random()
    card.x = constants.GAME_MIDDLE_X
    card.y = constants.GAME_BOTTOM + 0.6 * constants.CARD_HEIGHT
  end,
  showShotCards = function(self)
    local numCardsPerRow = 5
    local numRows = math.ceil(#self.shotCards / numCardsPerRow)
    local row
    for row = 1, numRows do
      local numCols
      if row == numRows and #self.shotCards % numCardsPerRow > 0 then
        numCols = #self.shotCards % numCardsPerRow
      else
        numCols = numCardsPerRow
      end
      local col
      for col = 1, numCols do
        local index = (row - 1) * numCardsPerRow + col
        local card = self.shotCards[index]
        local i = (col - numCols / 2 - 0.5)
        Promise.newActive(0.2 * index)
          :andThen(function()
            Sounds.dealCard:play()
            card:throw(constants.GAME_MIDDLE_X + (constants.CARD_WIDTH + 2) * i, constants.GAME_MIDDLE_Y - constants.CARD_HEIGHT / 2 + row * (constants.CARD_HEIGHT + 2))
          end)
      end
    end
    return constants.TURBO_MODE and 0.1 or 1.2
  end,
  explode = function(self, force)
    local index, card
    for index, card in ipairs(self.cards) do
      self:explodeCard(card, force)
    end
    for index, card in ipairs(self.shotCards) do
      self:explodeCard(card, force)
    end
    return 2.0
  end,
  explodeCard = function(self, card, force)
    local dx = card.x - constants.GAME_MIDDLE_X + math.random(-10, 10)
    local dy = card.y - constants.GAME_MIDDLE_Y - constants.CARD_HEIGHT + math.random(-10, 10)
    local dist = math.max(1, math.sqrt(dx * dx + dy * dy))
    local speed = force * 100
    card.vx = speed / 2 * dx / dist
    card.vy = speed * dy / dist
    card.vr = math.random(-200, 200)
    card.gravity = 500
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
    for index, card in ipairs(self.shotCards) do
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
