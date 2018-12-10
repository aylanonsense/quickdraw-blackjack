local constants = require 'src/constants'
local listHelpers = require 'src/util/list'

local function generateRoundDifficulty(roundNumber)
  local allowAces = (roundNumber > 4)
  local launchDuration = 3 + (33 / (10 + roundNumber))
  -- Figure out cards in play
  local minValueInPlay = 2
  local maxValueInPlay = math.min(4 + roundNumber, 20)
  local valueInPlay = math.random(minValueInPlay, maxValueInPlay)
  local numCardsInPlay
  if valueInPlay <= 5 then
    -- 2 to 5  points in play
    numCardsInPlay = roundNumber < 8 and 1 or math.random(1, 2)
  elseif valueInPlay <= 10 then
    -- 5 to 10 points in play
    if roundNumber < 3 then
      numCardsInPlay = 1
    elseif roundNumber < 7 then
      numCardsInPlay = math.random(1, 2)
    else
      numCardsInPlay = math.random(1, 3)
    end
  elseif valueInPlay <= 15 then
    -- 11 to 15 points in play
    if roundNumber < 5 then
      numCardsInPlay = 2
    elseif roundNumber < 10 then
      numCardsInPlay = math.random(2, 3)
    else
      numCardsInPlay = math.random(2, 4)
    end
  else
    -- 16 to 20 ponts in play
    if roundNumber < 10 then
      numCardsInPlay = math.random(2, 3)
    else
      numCardsInPlay = math.random(2, 4)
    end
  end
  -- Figure out cards in hand
  local valueInHand = 21 - valueInPlay
  local numCardsInHand
  if valueInHand <= 3 then
    -- 1 to 3 points in hand
    numCardsInHand = 1
  elseif valueInHand <= 8 then
    -- 4 to 8 points in hand
    numCardsInHand = math.random(1, 2)
  elseif valueInHand <= 10 then
    -- 9 to 10 points in hand
    if roundNumber < 15 then
      numCardsInHand = math.random(1, 3)
    else
      numCardsInHand = math.random(2, 3)
    end
  elseif valueInHand <= 13 then
    -- 11 to 13 points in hand
    numCardsInHand = math.random(2, 3)
  else
    -- 14 to 19 points in hand
    if roundNumber < 6 then
      numCardsInHand = 2
    elseif roundNumber < 10 then
      numCardsInHand = math.random(2, 3)
    elseif roundNumber < 15 then
      numCardsInHand = math.random(2, 4)
    else
      numCardsInHand = math.random(3, 4)
    end
  end
  -- Figure out extra cards
  local numExtraCards
  if roundNumber == 1 then
    numExtraCards = 1
  elseif roundNumber <= 3 then
    numExtraCards = 2
  elseif roundNumber <= 8 then
    numExtraCards = math.random(2, 3)
  elseif roundNumber <= 12 then
    numExtraCards = math.random(2, 4)
  elseif roundNumber <= 16 then
    numExtraCards = math.random(3, 5)
  elseif roundNumber <= 20 then
    numExtraCards = math.random(4, 6)
  else
    numExtraCards = math.random(4, 7)
  end
  -- Return the difficulty properties
  return {
    allowAces = allowAces,
    launchDuration = launchDuration,
    numCardsInHand = numCardsInHand,
    valueInHand = valueInHand,
    numCardsInPlay = numCardsInPlay,
    numExtraCards = numExtraCards,
    valueInPlay = valueInPlay
  }
end

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

local function generateRound(roundNumber)
  local difficulty = generateRoundDifficulty(roundNumber)
  -- Figure out how many cards are where
  local numCardsInPlay = difficulty.numCardsInPlay
  local valueInPlay = difficulty.valueInPlay
  local numExtraCards = difficulty.numExtraCards
  local numCardsInHand = difficulty.numCardsInHand
  local valueInHand = difficulty.valueInHand
  local launchDuration = difficulty.launchDuration
  local allowAces = difficulty.allowAces
  -- Figure out the exact card values
  local cardValuesInPlay = generateCardValueBundle(numCardsInPlay, valueInPlay, allowAces)
  local cardValuesInHand = generateCardValueBundle(numCardsInHand, valueInHand, allowAces)
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
  -- TODO shuffle cards
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
