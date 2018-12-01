local Entity = require 'src/Entity'
local Hand = require 'src/Hand'
local Card = require 'src/Card'

-- Entity vars
local entities
local hand
local cards

-- Add a spawn function to the Entity class
Entity.spawn = function(class, args)
  local entity = class.new(args)
  table.insert(entities, entity)
  return entity
end

function spawnCard(args)
  local card = Card:spawn(args)
  table.insert(cards, card)
  return card
end

function removeDeadEntities(list)
  local livingEntities = {}
  for index, entity in ipairs(list) do
    if entity.isAlive then
      table.insert(livingEntities, entity)
    end
  end
  return livingEntities
end

function load()
  -- Initialize game vars
  entities = {}
  cards = {}
  -- Spawn initial entities
  hand = Hand:spawn({
    x = 50,
    y = 150
  })
  spawnCard({
    x = 0,
    y = 0,
    value = '9'
  })
  spawnCard({
    x = 100,
    y = 140,
    value = 'Q'
  })
end

function update(dt)
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

function draw()
  -- Draw all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:draw()
  end
end

function onMousePressed(x, y)
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
