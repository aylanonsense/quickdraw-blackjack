local filterList = require 'src/util/filterList'
local constants = require 'src/constants'
local Entity = require 'src/Entity'
local Hand = require 'src/Hand'
local Card = require 'src/Card'
local Promise = require 'src/Promise'
local generateRound = require 'src/generateRound'

-- Entity vars
local entities
local hand
local cards

-- Entity methods
Entity.spawn = function(class, args)
  local entity = class.new(args)
  table.insert(entities, entity)
  return entity
end

local function spawnCard(args)
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

-- Main methods
local function load()
  -- Initialize game vars
  entities = {}
  cards = {}
  -- Spawn initial entities
  hand = Hand:spawn({
    x = constants.GAME_LEFT + constants.CARD_WIDTH * 0.5 + 1, -- constants.GAME_MIDDLE_X,
    y = constants.GAME_BOTTOM - constants.CARD_HEIGHT * 0.35
  })
  -- local round = generateRound()
  -- local index, cardProps
  -- for index, cardProps in ipairs(round.hand) do
  --   hand:addCard(spawnCard({
  --     rank = cardProps.rank,
  --     suit = cardProps.suit
  --   }))
  -- end
  -- for index, cardProps in ipairs(round.cards) do
  --   spawnCard({
  --     rank = cardProps.rank,
  --     suit = cardProps.suit,
  --     x = 20 * index,
  --     y = 30 * index
  --   })
  -- end
  local i
  for i = 0, 29 do
    spawnCard({
      x = 12 + 25 * (i%5),
      y = 20 + 35 * math.floor(i/5),
      rankIndex = 1 + i % 13,
      suitIndex = ({1,3,2,4})[1 + math.floor(i/13)]
    })
  end
end

local function update(dt)
  -- Update all promises
  Promise.updateActivePromises(dt)
  -- Update all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:update(dt)
    entity:countDownToDeath(dt)
  end
  -- Remove dead entities
  entities = removeDeadEntities(entities)
  cards = removeDeadEntities(cards)
end

local function draw()
  -- Draw all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:draw()
  end
end

local function onMousePressed(x, y)
  -- Shoot cards
  local index, card
  for index, card in ipairs(cards) do
    if not card.isHeld and card:containsPoint(x, y) then
      hand:addCard(card)
    end
  end
end

return {
  load = load,
  update = update,
  draw = draw,
  onMousePressed = onMousePressed
}
