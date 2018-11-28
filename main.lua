local Entity = require 'src/Entity'
local Card = require 'src/Card'

-- Entity vars
local entities
local card

-- Add a spawn function to the Entity class
Entity.spawn = function(class, args)
  local entity = class.new(args)
  table.insert(entities, entity)
  return entity
end

function love.load()
  -- Initialize game vars
  entities = {}
  -- Spawn initial entities
  card = Card:spawn({
    x = 400,
    y = 400
  })
end

function love.update(dt)
  -- Update all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:update(dt)
  end
  -- Remove dead entities
  local remainingEntities = {}
  for index, entity in ipairs(entities) do
    if entity.isAlive then
      table.insert(remainingEntities, entity)
    end
  end
  entities = remainingEntities
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
    if card:containsPoint(x, y) then
      card.color = { 0, 1, 0, 1 }
    else
      card.color = { 1, 0, 0, 1 }
    end
  end
end
