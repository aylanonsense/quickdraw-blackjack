local constants = require 'src/constants'
local game = require 'src/game'

function love.load()
  game.load()
end

function love.update(dt)
  game.update(dt)
end

function love.draw()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  -- Draw screen bounds
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.rectangle('line', 0, 0, constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', constants.RENDER_X, constants.RENDER_Y, constants.RENDER_WIDTH, constants.RENDER_HEIGHT)
  -- Apply camera transformations
  love.graphics.translate(constants.RENDER_X, constants.RENDER_Y)
  love.graphics.scale(constants.RENDER_SCALE, constants.RENDER_SCALE)
  -- Draw the game
  game.draw()
end

function love.mousepressed(x, y, button)
  if button == 1 then
    game.onMousePressed((x - constants.RENDER_X) / constants.RENDER_SCALE, (y - constants.RENDER_Y) / constants.RENDER_SCALE)
  end
end
