local constants = require 'src/constants'
local listHelpers = require 'src/util/list'

-- Generates a number of cards totaling the given value
local function generateCardValueBundle(numCards, totalValue, allowAces)
  -- Start with the lowest values
  local minValue = allowAces and 1 or 2
  local maxValue = allowAces and 11 or 10
  local cardValues = {}
  local i
  for i = 1, numCards do
    cardValues[i] = minValue
  end
  -- Keep adding until we're done
  local valueSoFar = minValue * numCards
  while valueSoFar < totalValue or valueSoFar == maxValue * numCards do
    local index = math.random(1, numCards)
    local maxChange = math.min(totalValue - valueSoFar, maxValue - cardValues[index])
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
    rankIndex = rankIndex,
    suitIndex = suitIndex
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
  local numExtraCards = 3
  local numCardsInHand = numCards - numCardsInPlay
  local valueInHand = 21 - valueInPlay
  local launchDuration = 5
  -- Figure out the exact card values
  local cardValuesInPlay = generateCardValueBundle(numCardsInPlay, valueInPlay, true)
  local cardValuesInHand = generateCardValueBundle(numCardsInHand, valueInHand, true)
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
  -- Set start points and apexes for each card
  local index, cardProps
  for index, cardProps in ipairs(cardsInPlay) do
    cardProps.x = 20 * index
    cardProps.y = constants.GAME_BOTTOM + 0.7 * constants.CARD_HEIGHT
    cardProps.apexX = math.random(constants.CARD_APEX_LEFT, constants.CARD_APEX_RIGHT)
    cardProps.apexY = math.random(constants.CARD_APEX_TOP, constants.CARD_APEX_BOTTOM)
    cardProps.launchDelay = 0.3 * (index - 1)
    cardProps.launchDuration = launchDuration - cardProps.launchDelay
  end
  -- Return the round properties
  return {
    hand = cardsInHand,
    cards = cardsInPlay,
    launchDuration = launchDuration
  }
end

return generateRound
