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

function love.load()
  -- Initialize game vars
  entities = {}
  cards = {}
  -- Spawn initial entities
  hand = Hand:spawn({
    x = 200,
    y = 600
  })
  spawnCard({
    x = 200,
    y = 600,
    value = '9'
  })
  spawnCard({
    x = 100,
    y = 700,
    value = 'Q'
  })
end

function love.update(dt)
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

function love.draw()
  -- Draw all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:draw()
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    local index, card
    for index, card in ipairs(cards) do
      if not card.isHeld and card:containsPoint(x, y) then
        hand:addCard(card)
      end
    end
  end
end
