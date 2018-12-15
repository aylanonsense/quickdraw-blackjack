local constants = require 'src/constants'
local listHelpers = require 'src/util/list'
local randBucket = require 'src/util/randBucket'

local function generateRoundDifficulty(roundNumber)
  local allowAces = roundNumber >= 9

  -- The time the cards spend in mid-air is stable at first and then begins to drop
  local launchDuration = 3.0
  if roundNumber == 5 then
    launchDuration = 5.5
  elseif roundNumber <= 9 then
    launchDuration = 5.0
  elseif roundNumber <= 14 then
    launchDuration = 5.5
  else
    launchDuration = math.max(5.5 - 0.05 * (roundNumber - 14), 3.0)
  end

  -- As rounds go on, the player is asked to shoot more and more cards (1 to 4)
  local numCardsToShoot
  if roundNumber <= 2 then
    numCardsToShoot = 1
  elseif roundNumber <= 4 then
    numCardsToShoot = 2
  elseif roundNumber <= 8 then
    numCardsToShoot = randBucket({ 50, 50 })
  elseif roundNumber <= 10 then
    numCardsToShoot = randBucket({ 25, 75 })
  elseif roundNumber <= 14 then
    numCardsToShoot = randBucket({ 25, 50, 25 })
  elseif roundNumber <= 19 then
    numCardsToShoot = randBucket({ 10, 50, 35 })
  else
    numCardsToShoot = randBucket({ 5, 40, 40, 15 })
  end

  -- As rounds go on, the number of cards launched into the air goes up (2 to ...)
  local numLaunchedCards
  if roundNumber <= 1 then
    numLaunchedCards = 2
  elseif roundNumber <= 3 then
    numLaunchedCards = 3
  elseif roundNumber <= 4 then
    numLaunchedCards = 4
  elseif roundNumber <= 9 then
    numLaunchedCards = 5
  elseif roundNumber <= 11 then
    numLaunchedCards = 6
  elseif roundNumber <= 17 then
    numLaunchedCards = 7
  elseif roundNumber <= 23 then
    numLaunchedCards = 8
  elseif roundNumber <= 29 then
    numLaunchedCards = 9
  else
    numLaunchedCards = 10
  end
  numLaunchedCards = math.max(numLaunchedCards, numCardsToShoot)
  local numExtraCards = numLaunchedCards - numCardsToShoot

  -- The total value of cards the player must shoot tends to increase (1 to 20)
  local valueToShoot
  local minValueToShoot = numCardsToShoot * (allowAces and 1 or 2)
  local maxValueToShoot = math.max(math.min(math.floor(5 + 1.3 * roundNumber), numCardsToShoot * (allowAces and 11 or 10), allowAces and 20 or 19), minValueToShoot)
  local valueToShoot = math.random(minValueToShoot, maxValueToShoot)
  if valueToShoot < (maxValueToShoot + minValueToShoot) / 2 then
    valueToShoot = math.random(minValueToShoot, maxValueToShoot)
  end
  local valueInHand = 21 - valueToShoot

  -- The number of cards in the player's hand goes up as rounds go on (2 to 5)
  local numCardsInHand
  if roundNumber <= 4 then
    numCardsInHand = 2
  elseif roundNumber <= 5 then
    numCardsInHand = 3
  elseif roundNumber <= 7 then
    numCardsInHand = randBucket({ 70, 30 }, { 2, 3 })
  elseif roundNumber <= 9 then
    numCardsInHand = randBucket({ 50, 50 }, { 2, 3 })
  elseif roundNumber <= 11 then
    numCardsInHand = randBucket({ 35, 65 }, { 2, 3 })
  elseif roundNumber <= 19 then
    numCardsInHand = randBucket({ 10, 40, 40, 10 }, { 1, 2, 3, 4 })
  elseif roundNumber <= 24 then
    numCardsInHand = randBucket({ 10, 30, 30, 30 }, { 1, 2, 3, 4 })
  else
    numCardsInHand = randBucket({ 5, 25, 35, 30, 5 }, { 1, 2, 3, 4, 5 })
  end
  local minCardsInHand = math.ceil(valueInHand / (allowAces and 11 or 21))
  local maxCardsInHand = math.floor(valueInHand / (allowAces and 1 or 2))
  numCardsInHand = math.max(minCardsInHand, math.min(numCardsInHand, maxCardsInHand))

  return {
    allowAces = allowAces,
    launchDuration = launchDuration,
    numCardsInHand = numCardsInHand,
    valueInHand = valueInHand,
    numCardsToShoot = numCardsToShoot,
    valueToShoot = valueToShoot,
    numExtraCards = numExtraCards
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
  local attemptsLeft = 999
  local valueSoFar = minValue * numCards
  while valueSoFar < totalValue and valueSoFar < maxValue * numCards and attemptsLeft > 0 do
    local index = math.random(1, numCards)
    local maxChange = math.min(totalValue - valueSoFar, maxValue - cardValues[index])
    if maxChange > 0 then
      local change = math.random(0, math.max(1, math.floor(maxChange / 2)))
      cardValues[index] = cardValues[index] + change
      valueSoFar = valueSoFar + change
    end
    attemptsLeft = attemptsLeft - 1
  end
  -- Return the card values
  if attemptsLeft <= 0 then
    print('Failed to generate card bundle after 999 attempts!')
    return nil
  else
    return cardValues
  end
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

local generateRound
generateRound = function(roundNumber)
  print('Generating round '..roundNumber)
  local difficulty = generateRoundDifficulty(roundNumber)
  -- Figure out how many cards are where
  local numCardsToShoot = difficulty.numCardsToShoot
  local valueToShoot = difficulty.valueToShoot
  local numExtraCards = difficulty.numExtraCards
  local numCardsInHand = difficulty.numCardsInHand
  local valueInHand = difficulty.valueInHand
  local launchDuration = difficulty.launchDuration
  local allowAces = difficulty.allowAces
  print('  numCardsToShoot = '..numCardsToShoot)
  print('  valueToShoot = '..valueToShoot)
  print('  numExtraCards = '..numExtraCards)
  print('  numCardsInHand = '..numCardsInHand)
  print('  valueInHand = '..valueInHand)
  print('  launchDuration = '..launchDuration)
  print('  allowAces = '..(allowAces and 'true' or 'false'))
  -- Figure out the exact card values
  print('Generating card bundles...')
  local cardValuesToShoot = generateCardValueBundle(numCardsToShoot, valueToShoot, allowAces)
  if cardValuesToShoot then
    print('  Cards to shoot: '..listHelpers.join(cardValuesToShoot, ', '))
  end
  local cardValuesInHand = generateCardValueBundle(numCardsInHand, valueInHand, allowAces)
  if cardValuesInHand then
    print('  Cards in hand: '..listHelpers.join(cardValuesInHand, ', '))
  end
  if not cardValuesToShoot or not cardValuesInHand then
    print('Failed to generate card bundles! Restarting round generation...')
    return generateRound(roundNumber)
  end
  -- Generate card suits, trying to avoid duplicates
  print('Generating cards...')
  local cardLookup = { {}, {}, {}, {} }
  local cardsToShoot = listHelpers.map(cardValuesToShoot, function(value)
    return generateCardFromValue(value, cardLookup)
  end)
  local cardsInHand = listHelpers.map(cardValuesInHand, function(value)
    return generateCardFromValue(value, cardLookup)
  end)
  -- Generate extra cards to confuse the player
  print('Generating extra cards...')
  local attemptsLeft = 999
  local numExtraCardsGenerated = 0
  while numExtraCardsGenerated < numExtraCards and attemptsLeft > 0 do
    local suitIndex = math.random(1, #constants.CARD_SUITS)
    local rankIndex = math.random(1, #constants.CARD_RANKS)
    if not cardLookup[suitIndex][rankIndex] then
      table.insert(cardsToShoot, generateCard(suitIndex, rankIndex, cardLookup))
      numExtraCardsGenerated = numExtraCardsGenerated + 1
    end
    attemptsLeft = attemptsLeft - 1
  end
  if attemptsLeft <= 0 then
    print('Failed to generate enough extra cards after 999 attempts!')
  end
  -- Set start points and apexes for each card
  print('Choosing apex points...')
  local index, cardProps
  local apexAreaWidth = constants.CARD_APEX_RIGHT - constants.CARD_APEX_LEFT
  local apexOffsetX = math.random(0, apexAreaWidth)
  for index, cardProps in ipairs(cardsToShoot) do
    apexOffsetX = apexOffsetX + apexAreaWidth * (0.35 + 0.3 * math.random())
    apexOffsetX = apexOffsetX % apexAreaWidth
    cardProps.apexX = constants.CARD_APEX_LEFT + apexOffsetX -- math.random(constants.CARD_APEX_LEFT, constants.CARD_APEX_RIGHT)
    cardProps.apexY = constants.CARD_APEX_TOP + index / (#cardsToShoot + 1) * (constants.CARD_APEX_BOTTOM - constants.CARD_APEX_TOP) --  math.random(constants.CARD_APEX_TOP, constants.CARD_APEX_BOTTOM)
    cardProps.x = math.random(math.max(cardProps.apexX - apexAreaWidth / 2, constants.GAME_LEFT), math.min(cardProps.apexX + apexAreaWidth / 2, constants.GAME_RIGHT))
    cardProps.y = constants.GAME_BOTTOM + 0.7 * constants.CARD_HEIGHT
  end
  -- Shuffle the cards
  print('Shuffling cards...')
  local launchDelayPerCard = math.max(0.35 - 0.027 * #cardsToShoot, 0.05)
  for index = 1, #cardsToShoot do
    local swapIndex = math.random(index, #cardsToShoot)
    local temp = cardsToShoot[index]
    cardsToShoot[index] = cardsToShoot[swapIndex]
    cardsToShoot[swapIndex] = temp
    cardsToShoot[index].launchDelay = launchDelayPerCard * (index - 1)
    cardsToShoot[index].launchDuration = launchDuration
  end
  -- Return the round properties
  print('Done generating round '..roundNumber)
  return {
    hand = cardsInHand,
    cards = cardsToShoot,
    launchDuration = launchDuration
  }
end

return generateRound
