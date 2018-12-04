local filterList = require 'src/util/filterList'
local constants = require 'src/constants'
local Entity = require 'src/Entity'
local Hand = require 'src/Hand'
local Card = require 'src/Card'
local Promise = require 'src/Promise'

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
  hand:addCard(spawnCard({ value = 'Q', suit = 'CLUBS' }))
  spawnCard({
    x = 100,
    y = 100,
    value = '2',
    suit = 'SPADES'
  })
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
