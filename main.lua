if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'main.lua',
    'img/cards.png',
    'img/effects.png',
    'img/ui.png',
    'snd/card_slide.mp3',
    'snd/deal_card.mp3',
    'snd/game_music_loop_verb.mp3',
    'snd/game_over.mp3',
    'snd/gun_trigger_empty.wav',
    'snd/gun_unholster.mp3',
    'snd/gunshot.mp3',
    'snd/honky-tonk-round-start.wav',
    'snd/impact.mp3',
    'snd/launch.mp3',
    'snd/lose_round.mp3',
    'snd/new_personal_best.mp3',
    'snd/pew1.wav',
    'snd/pew10.wav',
    'snd/pew11.wav',
    'snd/pew12.wav',
    'snd/pew2.wav',
    'snd/pew3.wav',
    'snd/pew4.wav',
    'snd/pew5.wav',
    'snd/pew6.wav',
    'snd/pew7.wav',
    'snd/pew8.wav',
    'snd/pew9.wav',
    'snd/past_game_over_no_personal_best.mp3',
    'snd/score_counter.mp3',
    'snd/title_loop.mp3',
    'snd/title_loop.ogg',
    'src/entity/Card.lua',
    'src/entity/CardExplosion.lua',
    'src/entity/Entity.lua',
    'src/entity/Gunshot.lua',
    'src/entity/Hand.lua',
    'src/entity/Lives.lua',
    'src/entity/RoundIndicator.lua',
    'src/entity/RoundResults.lua',
    'src/entity/ScoreCalculation.lua',
    'src/entity/StarButton.lua',
    'src/entity/Title.lua',
    'src/entity/TutorialScreen.lua',
    'src/util/createClass.lua',
    'src/util/easing.lua',
    'src/util/list.lua',
    'src/util/Promise.lua',
    'src/util/randBucket.lua',
    'src/util/saveFile.lua',
    'src/util/SpriteSheet.lua',
    'src/constants.lua',
    'src/game.lua',
    'src/generateRound.lua',
    'src/Sound.lua',
    'src/Sounds.lua'
  })
end

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
  -- Apply camera transformations
  love.graphics.translate(constants.RENDER_X, constants.RENDER_Y)
  love.graphics.scale(constants.RENDER_SCALE, constants.RENDER_SCALE)
  -- Draw card apex area
  -- love.graphics.setColor(0, 0, 1, 1)
  -- love.graphics.rectangle('line', constants.CARD_APEX_LEFT - 0.5 * constants.CARD_HEIGHT, constants.CARD_APEX_TOP - 0.5 * constants.CARD_HEIGHT, constants.CARD_APEX_RIGHT - constants.CARD_APEX_LEFT + constants.CARD_HEIGHT, constants.CARD_APEX_BOTTOM - constants.CARD_APEX_TOP + constants.CARD_HEIGHT)
  -- Draw background color
  love.graphics.setColor(223 / 255, 113 / 255, 38 / 255, 1)
  love.graphics.rectangle('fill', constants.GAME_LEFT, constants.GAME_TOP, constants.GAME_WIDTH, constants.GAME_HEIGHT)
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
