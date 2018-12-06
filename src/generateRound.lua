local constants = require 'src/constants'
local listHelpers = require 'src/util/list'

-- Generates a number of cards totaling the given value
local function generateCardValueBundle(numCards, totalValue)
  -- Start with the lowest values
  local cardValues = {}
  local i
  for i = 1, numCards do
    cardValues[i] = 1
  end
  -- Keep adding until we're done
  local valueSoFar = numCards
  while valueSoFar < totalValue or valueSoFar >= 11 * numCards do
    local index = math.random(1, numCards)
    local maxChange = math.min(totalValue - valueSoFar, 11 - cardValues[index])
    if maxChange > 0 then
      local change = math.random(0, math.max(1, math.floor(maxChange / 2)))
      cardValues[index] = cardValues[index] + change
      valueSoFar = valueSoFar + change
    end
  end
  -- Return the card values
  return cardValues
end

-- Creates card properties
local function generateCard(suitIndex, rankIndex, cardLookup)
  cardLookup[suitIndex][rankIndex] = true
  return {
    rank = constants.CARD_RANKS[rankIndex],
    suit = constants.CARD_SUITS[suitIndex]
  }
end

-- Given a card's value, generate its rank and suit
local function generateCardFromValue(value, cardLookup)
  local rankIndex
  if value == 1 or value == 11 then
    rankIndex = 13
  elseif value == 10 then
    rankIndex = math.random(10, 12)
  else
    rankIndex = value - 1
  end
  -- Find a suit without a duplicate
  local suitIndex = math.random(1, 4)
  local attemptsLeft = 4
  while cardLookup[suitIndex][rankIndex] and attemptsLeft > 0 do
    suitIndex = suitIndex % 4 + 1
    attemptsLeft = attemptsLeft - 1
  end
  -- Generate the card
  return generateCard(suitIndex, rankIndex, cardLookup)
end

local function generateRound()
  -- Figure out how many cards are where
  local numCards = 4
  local numCardsInPlay = 1
  local valueInPlay = 6
  local numExtraCards = 5
  local numCardsInHand = numCards - numCardsInPlay
  local valueInHand = 21 - valueInPlay
  -- Figure out the exact card values
  local cardValuesInPlay = generateCardValueBundle(numCardsInPlay, valueInPlay)
  local cardValuesInHand = generateCardValueBundle(numCardsInHand, valueInHand)
  -- Generate card suits, trying to avoid duplicates
  local cardLookup = { {}, {}, {}, {} }
  local cardsInPlay = listHelpers.map(cardValuesInPlay, function(value)
    return generateCardFromValue(value, cardLookup)
  end)
  local cardsInHand = listHelpers.map(cardValuesInHand, function(value)
    return generateCardFromValue(value, cardLookup)
  end)
  -- Generate extra cards to confuse the player
  local attemptsLeft = 999
  local numExtraCardsGenerated = 0
  while numExtraCardsGenerated < numExtraCards and attemptsLeft > 0 do
    local suitIndex = math.random(1, #constants.CARD_SUITS)
    local rankIndex = math.random(1, #constants.CARD_RANKS)
    if not cardLookup[suitIndex][rankIndex] then
      table.insert(cardsInPlay, generateCard(suitIndex, rankIndex, cardLookup))
      numExtraCardsGenerated = numExtraCardsGenerated + 1
    end
    attemptsLeft = attemptsLeft - 1
  end
  -- Return the round properties
  return {
    hand = cardsInHand,
    cards = cardsInPlay
  }
end

return generateRound
