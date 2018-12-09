local filterList = require 'src/util/filterList'
local constants = require 'src/constants'
local Entity = require 'src/Entity'
local PlayButton = require 'src/PlayButton'
local Hand = require 'src/Hand'
local Card = require 'src/Card'
local RoundResults = require 'src/RoundResults'
local Promise = require 'src/Promise'
local generateRound = require 'src/generateRound'

-- Scene vars
local scene
local isTransitioningScenes
local initTitleScreen
local transitionToGameplay
local initGameplay
local transitionToRoundEnd
local initRoundEnd

-- Entity vars
local entities
local hand
local cards
local playButton
local roundResults

-- Entity methods
Entity.spawn = function(class, args)
  local entity = class.new(args)
  table.insert(entities, entity)
  return entity
end

local function spawnCard(args)
  args.hand = hand
  local card = Card:spawn(args)
  table.insert(cards, card)
  return card
end

local function launchCard()
  local startX = love.math.random(constants.GAME_LEFT, constants.GAME_RIGHT)
  local minX = (startX < constants.GAME_LEFT + 0.2 * constants.GAME_WIDTH and 0.3 or 0.0) * constants.GAME_WIDTH + constants.GAME_LEFT
  local maxX = (startX > constants.GAME_LEFT + 0.8 * constants.GAME_WIDTH and 0.7 or 1.0) * constants.GAME_WIDTH + constants.GAME_LEFT
  local finalX = love.math.random(minX, maxX)
  local launchHeight = (0.3 + 0.61 * love.math.random()) * constants.GAME_HEIGHT + 0.7 * constants.CARD_HEIGHT
  local launchTime = 7.0 + 2.0 * love.math.random()
  local card = spawnCard({
    x = startX,
    y = constants.GAME_BOTTOM + 0.7 * constants.CARD_HEIGHT,
    vr = love.math.random(-300,300),
    rank = constants.CARD_RANKS[love.math.random(1, #constants.CARD_RANKS)],
    suit = constants.CARD_SUITS[love.math.random(1, #constants.CARD_SUITS)],
  })
  card:launch(finalX - startX, -launchHeight, launchTime)
end

local function removeDeadEntities(list)
  return filterList(list, function(entity)
    return entity.isAlive
  end)
end

-- Scene methods
initTitleScreen = function()
  scene = 'title'
  playButton = PlayButton:spawn({
    x = constants.GAME_WIDTH / 2,
    y = constants.GAME_HEIGHT * 0.7,
    onClicked = function(self)
      transitionToGameplay()
    end
  })
end

transitionToGameplay = function()
  if not isTransitioningScenes then
    isTransitioningScenes = true
    Promise.newActive(0)
      :andThen(function()
        isTransitioningScenes = false
        initGameplay()
      end)
    end
end

initGameplay = function()
  scene = 'gameplay'
  hand = Hand:spawn({
    x = constants.GAME_LEFT + constants.CARD_WIDTH * 0.5 + 1, -- constants.GAME_MIDDLE_X,
    y = constants.GAME_BOTTOM - constants.CARD_HEIGHT * 0.35
  })
  local round = generateRound()
  local index, cardProps
  for index, cardProps in ipairs(round.hand) do
    hand:addCard(spawnCard({
      rankIndex = cardProps.rankIndex,
      suitIndex = cardProps.suitIndex
    }))
  end
  local maxLaunchDuration = 5
  local cards = {}
  for index, cardProps in ipairs(round.cards) do
    local card = spawnCard({
      rankIndex = cardProps.rankIndex,
      suitIndex = cardProps.suitIndex,
      x = cardProps.x,
      y = cardProps.y,
      vr = math.random(-80, 80)
    })
    local launchDuration = maxLaunchDuration - 0.3 * index
    table.insert(cards, card)
    Promise.newActive(1 + 0.3 * index):andThen(
      function()
        card:launch(cardProps.apexX - card.x, cardProps.apexY - card.y, launchDuration)
      end)
  end
end

transitionToRoundEnd = function()
  if not isTransitioningScenes then
    isTransitioningScenes = true
    Promise.newActive(1)
      :andThen(function()
        isTransitioningScenes = false
        initRoundEnd()
      end)
  end
end

initRoundEnd = function()
  scene = 'round-end'
  local handValue = hand:getSumValue()
  local isWinningHand = (handValue == 21)
  local result
  if handValue == 21 and #hand.cards == 2 then
    result = 'blackjack'
  elseif handValue == 21 then
    result = 'win'
  elseif handValue > 21 then
    result = 'bust'
  else
    result = 'miss'
  end
  roundResults = RoundResults:spawn({
    result = result
  })
  Promise.newActive(1)
    :andThen(function()
      entities = {}
      if isWinningHand then
        initGameplay()
      else
        initTitleScreen()
      end
    end)
end

-- Main methods
local function load()
  scene = nil
  isTransitioningScenes = false
  -- Initialize game vars
  entities = {}
  cards = {}
  -- Start at the title screen
  initTitleScreen()
end

local function update(dt)
  -- Update all promises
  Promise.updateActivePromises(dt)
  -- Update all entities
  local index, entity
  for index, entity in ipairs(entities) do
    if entity:checkScene(scene) then
      entity:update(dt)
      entity:countDownToDeath(dt)
    end
  end
  -- Remove dead entities
  entities = removeDeadEntities(entities)
  cards = removeDeadEntities(cards)
  -- Check for end of gameplay
  local allCardsInHand = true
  local card
  for index, card in ipairs(cards) do
    if not card.isHeld then
      allCardsInHand = false
    end
  end
  if allCardsInHand and scene == 'gameplay' then
    transitionToRoundEnd()
  end
end

local function draw()
  -- Draw all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:draw()
  end
end

local function onMousePressed(x, y)
  local index, entity
  for index, entity in ipairs(entities) do
    entity:onMousePressed(x, y)
  end
end

return {
  load = load,
  update = update,
  draw = draw,
  onMousePressed = onMousePressed
}
