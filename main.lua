local constants = require 'src/constants'
local game = require 'src/game'

local translateScreenToCenterDx = 0
local translateScreenToCenterDy = 0

function love.load()
  game.load()
end

function love.update(dt)
  game.update(dt)
end

function love.draw()
  -- Center everything within Castle window
  love.graphics.push() -- center screen
  translateScreenToCenterDx = 0.5 * (love.graphics.getWidth() - constants.SCREEN_WIDTH)
  translateScreenToCenterDy = 0.5 * (love.graphics.getHeight() - constants.SCREEN_HEIGHT)
  love.graphics.translate(translateScreenToCenterDx, translateScreenToCenterDy)
  -- Set Filter
  love.graphics.setDefaultFilter('nearest', 'nearest')
  -- Draw screen bounds
  -- love.graphics.setColor(0, 1, 0, 1)
  -- love.graphics.rectangle('line', 0, 0, constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', constants.RENDER_X, constants.RENDER_Y, constants.RENDER_WIDTH, constants.RENDER_HEIGHT)
  -- Apply camera transformations
  love.graphics.translate(constants.RENDER_X, constants.RENDER_Y)
  love.graphics.scale(constants.RENDER_SCALE, constants.RENDER_SCALE)
  -- Draw card apex area
  -- love.graphics.setColor(0, 0, 1, 1)
  -- love.graphics.rectangle('line', constants.CARD_APEX_LEFT - 0.5 * constants.CARD_HEIGHT, constants.CARD_APEX_TOP - 0.5 * constants.CARD_HEIGHT, constants.CARD_APEX_RIGHT - constants.CARD_APEX_LEFT + constants.CARD_HEIGHT, constants.CARD_APEX_BOTTOM - constants.CARD_APEX_TOP + constants.CARD_HEIGHT)
  -- Draw the game
  love.graphics.setColor(1, 1, 1, 1)
  game.draw()
  -- Draw blinders
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', constants.GAME_RIGHT, constants.GAME_TOP - 1000, 1000, constants.GAME_HEIGHT + 2000)
  love.graphics.rectangle('fill', constants.GAME_LEFT - 1000, constants.GAME_TOP - 1000, 1000, constants.GAME_HEIGHT + 2000)
  love.graphics.rectangle('fill', constants.GAME_LEFT - 1000, constants.GAME_TOP - 1000, constants.GAME_WIDTH + 2000, 1000)
  love.graphics.rectangle('fill', constants.GAME_LEFT - 1000, constants.GAME_BOTTOM, constants.GAME_WIDTH + 2000, 1000)
  -- Pop centering within Castle window
  love.graphics.pop()
end

function love.mousepressed(x, y, button)
  if button == 1 then
    game.onMousePressed(((x - translateScreenToCenterDx) - constants.RENDER_X) / constants.RENDER_SCALE, ((y - translateScreenToCenterDy) - constants.RENDER_Y) / constants.RENDER_SCALE)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'm' or key == 'M' then
    local vol = love.audio.getVolume()
    if vol < 0.01 then
      vol = 1.0
    else
      vol = 0.0
    end
    love.audio.setVolume(vol)
  end
end
