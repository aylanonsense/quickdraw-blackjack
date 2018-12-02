local Entity = require 'src/Entity'
local Hand = require 'src/Hand'
local Card = require 'src/Card'
local Promise = require 'src/Promise'

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
  -- Silly promise debugging
  local promise1 = Promise.newActive(0.5)
    :andThen(spawnCard, {
      x = 50,
      y = 50,
      value = '4'
    })
  local promise2 = promise1
    :andThen(0.2)
  local promise3 = promise2
    :andThen(function()
      spawnCard({
        x = 70,
        y = 50,
        value = '4'
      })
      return 1
    end)
  local promise4 = promise3
    :andThen(function()
      spawnCard({
        x = 90,
        y = 50,
        value = '4'
      })
    end)
  promise2:andThen(promise1.deactivate, promise1, true)
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
