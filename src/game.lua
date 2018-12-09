local constants = require 'src/constants'
local generateRound = require 'src/generateRound'
local listHelpers = require 'src/util/list'
local Promise = require 'src/util/Promise'
local Entity = require 'src/entity/Entity'
local PlayButton = require 'src/entity/PlayButton'
local Title = require 'src/entity/Title'
local Hand = require 'src/entity/Hand'
local Card = require 'src/entity/Card'
local RoundResults = require 'src/entity/RoundResults'
local ScoreCalculation = require 'src/entity/ScoreCalculation'

-- Scene vars
local scene
local isTransitioningScenes
local initTitleScreen
local transitionToGameplay
local initRoundStart
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

local function removeDeadEntities(list)
  return listHelpers.filter(list, function(entity)
    return entity.isAlive
  end)
end

-- Scene methods
initTitleScreen = function()
  scene = 'title'
  Title:spawn({
    x = constants.GAME_MIDDLE_X,
    y = constants.GAME_HEIGHT * 0.35
  })
  playButton = PlayButton:spawn({
    x = constants.GAME_MIDDLE_X,
    y = constants.GAME_HEIGHT * 0.75,
    onClicked = function(self)
      transitionToGameplay()
    end
  })
  -- Debug
  if constants.TURBO_MODE then
    transitionToGameplay()
  end
end

transitionToGameplay = function()
  if not isTransitioningScenes then
    isTransitioningScenes = true
    Promise.newActive(0)
      :andThen(function()
        isTransitioningScenes = false
        initRoundStart()
      end)
    end
end

initRoundStart = function()
  scene = 'round-start'
  -- Generate a new round
  local round = generateRound()
  -- Create hand of cards
  local cardsInHand = {}
  local index, cardProps
  for index, cardProps in ipairs(round.hand) do
    table.insert(cardsInHand, spawnCard({
      rankIndex = cardProps.rankIndex,
      suitIndex = cardProps.suitIndex,
      x = constants.GAME_MIDDLE_X,
      y = constants.GAME_TOP - 0.6 * constants.CARD_HEIGHT,
      rotation = math.random(0, 360)
    }))
  end
  hand = Hand:spawn({
    cards = cardsInHand
  })
  -- Create cards that'll be launched into the air
  local cardsInPlay = {}
  for index, cardProps in ipairs(round.cards) do
    table.insert(cardsInPlay, spawnCard({
      rankIndex = cardProps.rankIndex,
      suitIndex = cardProps.suitIndex,
      x = cardProps.x,
      y = cardProps.y,
      vr = math.random(-80, 80),
      hand = hand
    }))
  end
  -- Deal hand cards and then launch remaining cards
  Promise.newActive(function()
      return hand:dealCards()
    end)
    :andThen(0.7)
    :andThen(function()
      return hand:moveToBottom()
    end)
    :andThen(function()
      local launchMult = constants.TURBO_MODE and 0.4 or 1.0
      local index, card
      for index, cardProps in ipairs(round.cards) do
        local card = cardsInPlay[index]
        Promise.newActive(launchMult * cardProps.launchDelay):andThen(
          function()
            card.canBeShot = true
            card:launch(cardProps.apexX - card.x, cardProps.apexY - card.y, launchMult * cardProps.launchDuration)
          end)
      end
      return launchMult * round.launchDuration
    end)
    :andThen(function()
      return hand:moveToCenter()
    end)
    :andThen(function()
      return hand:showShotCards()
    end)
    :andThen(function()
      local scoreCalculation = ScoreCalculation:spawn({
        score = hand:getSumValue(),
        x = constants.GAME_MIDDLE_X,
        y = constants.GAME_MIDDLE_Y - constants.CARD_HEIGHT / 2 - 17
      })
      return Promise.newActive(1.0)
        :andThen(function()
          scoreCalculation:showScore()
        end)
    end)
    :andThen(function()
      RoundResults:spawn({})
      return hand:explode()
    end)
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
        -- TODO
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
    if entity.isAlive and (isTransitioningScenes or entity:checkScene(scene)) then
      entity.timeAlive = entity.timeAlive + dt
      entity:update(dt)
      entity:countDownToDeath(dt)
    end
  end
  -- Remove dead entities
  entities = removeDeadEntities(entities)
  cards = removeDeadEntities(cards)
end

local function draw()
  -- Draw all entities
  local index, entity
  for index, entity in ipairs(entities) do
    love.graphics.setColor(1, 1, 1, 1)
    entity:draw()
  end
end

local function onMousePressed(x, y)
  local index, entity
  for index, entity in ipairs(entities) do
    if entity.isAlive then
      entity:onMousePressed(x, y)
    end
  end
end

return {
  load = load,
  update = update,
  draw = draw,
  onMousePressed = onMousePressed
}
