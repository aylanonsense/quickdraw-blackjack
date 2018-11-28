local Entity = require 'src/Entity'

-- Entity vars
local entities

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
  -- TODO
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
    -- TODO
  end
end
