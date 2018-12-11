local constants = require 'src/constants'
local generateRound = require 'src/generateRound'
local listHelpers = require 'src/util/list'
local Promise = require 'src/util/Promise'
local Entity = require 'src/entity/Entity'
local PlayButton = require 'src/entity/PlayButton'
local Title = require 'src/entity/Title'
local Hand = require 'src/entity/Hand'
local Card = require 'src/entity/Card'
local Sounds = require 'src/Sounds'
local RoundResults = require 'src/entity/RoundResults'
local ScoreCalculation = require 'src/entity/ScoreCalculation'
local RoundIndicator = require 'src/entity/RoundIndicator'

-- Scene vars
local scene
local isTransitioningScenes
local initTitleScreen
local transitionToGameplay
local initRoundStart
local transitionToRoundEnd
local initRoundEnd

-- Entity vars
local entities
local hand
local playButton
local roundResults
local roundNumber

-- Entity methods
Entity.spawn = function(class, args)
  local entity = class.new(args)
  table.insert(entities, entity)
  return entity
end

local function removeDeadEntities(list)
  return listHelpers.filter(list, function(entity)
    return entity.isAlive
  end)
end

-- Scene methods
initTitleScreen = function()
  scene = 'title'
  roundNumber = 1
  Title:spawn({
    x = constants.GAME_MIDDLE_X,
    y = constants.GAME_HEIGHT * 0.35
  })
  playButton = PlayButton:spawn({
    x = constants.GAME_MIDDLE_X,
    y = constants.GAME_HEIGHT * 0.75,
    onClicked = function(self)
      transitionToGameplay()
    end
  })
  --Sounds.music:stop()
  Sounds.titleLoop:play()
  Sounds.gameMusicVerb:play()
  Sounds.gameMusicVerb:setVolume(0.0)
  -- Debug
  if constants.TURBO_MODE then
    transitionToGameplay()
  end
end

transitionToGameplay = function()
  if not isTransitioningScenes then
    isTransitioningScenes = true
    Promise.newActive(0)
      :andThen(function()
        isTransitioningScenes = false
        initRoundStart()
      end)
    end
end

initRoundStart = function()
  scene = 'round-start'
  RoundIndicator:spawn({
    roundNumber = roundNumber
  })
  -- Generate a new round
  local round = generateRound(roundNumber)
  -- Create hand of cards
  local cardsInHand = {}
  local index, cardProps
  for index, cardProps in ipairs(round.hand) do
    table.insert(cardsInHand, Card:spawn({
      rankIndex = cardProps.rankIndex,
      suitIndex = cardProps.suitIndex,
      x = constants.GAME_MIDDLE_X,
      y = constants.GAME_TOP - 0.6 * constants.CARD_HEIGHT,
      rotation = math.random(0, 360)
    }))
  end
  hand = Hand:spawn({
    cards = cardsInHand
  })
  -- Create cards that'll be launched into the air
  local cardsInPlay = {}
  for index, cardProps in ipairs(round.cards) do
    table.insert(cardsInPlay, Card:spawn({
      rankIndex = cardProps.rankIndex,
      suitIndex = cardProps.suitIndex,
      x = cardProps.x,
      y = cardProps.y,
      vr = math.random(-80, 80),
      hand = hand
    }))
  end
  -- Loop the music
  Sounds.titleLoop:stop()
  --Sounds.music:play()
  Sounds.gameMusicVerb:setVolume(0.2)
  -- Deal hand cards and then launch remaining cards
  Promise.newActive(function()
      return hand:dealCards()
    end)
    :andThen(0.7)
    :andThen(function()
      Sounds.unholster:play()
      return hand:moveToBottom()
    end)
    :andThen(function()
      local launchMult = constants.TURBO_MODE and 0.4 or 1.0
      local index, card
      for index, cardProps in ipairs(round.cards) do
        local card = cardsInPlay[index]
        Promise.newActive(launchMult * cardProps.launchDelay):andThen(
          function()
            card.canBeShot = true
            card:launch(cardProps.apexX - card.x, cardProps.apexY - card.y, launchMult * cardProps.launchDuration)
            Sounds.launch:play()
          end)
      end
      return launchMult * round.launchDuration
    end)
    :andThen(function()
      return hand:moveToCenter()
    end)
    :andThen(function()
      return hand:showShotCards()
    end)
    :andThen(function()
      local scoreCalculation = ScoreCalculation:spawn({
        score = hand:getSumValue(),
        x = constants.GAME_MIDDLE_X,
        y = constants.GAME_MIDDLE_Y - constants.CARD_HEIGHT / 2 - 17
      })
      return Promise.newActive(1.0)
        :andThen(function()
          scoreCalculation:showScore()
        end)
    end)
    :andThen(0.6)
    :andThen(function()
      local value = hand:getSumValue()
      local result
      if value == 21 then
        result = 'blackjack'
        Sounds.blackjack:play()
      elseif value < 21 then
        result = 'miss'
        Sounds.miss:play()
      elseif value > 21 then
        result = 'bust'
        Sounds.bust:play()
      end
      RoundResults:spawn({
        result = result
      })
      hand:explode(value == 21 and 3 or 1)
    end)
    :andThen(2.0)
    :andThen(function()
      local value = hand:getSumValue()
      entities = {}
      if value == 21 then
        roundNumber = roundNumber + 1
        initRoundStart()
      else
        initTitleScreen()
      end
    end)
end

transitionToRoundEnd = function()
  if not isTransitioningScenes then
    isTransitioningScenes = true
    Promise.newActive(1)
      :andThen(function()
        isTransitioningScenes = false
        initRoundEnd()
      end)
  end
end

initRoundEnd = function()
  scene = 'round-end'
  local handValue = hand:getSumValue()
  local isWinningHand = (handValue == 21)
  local result
  if handValue == 21 and #hand.cards == 2 then
    result = 'blackjack'
  elseif handValue == 21 then
    result = 'win'
  elseif handValue > 21 then
    result = 'bust'
  else
    result = 'miss'
  end
  roundResults = RoundResults:spawn({
    result = result
  })
  Promise.newActive(1)
    :andThen(function()
      entities = {}
      if isWinningHand then
        -- TODO
      else
        initTitleScreen()
      end
    end)
end

local function initSounds()
  Sounds.gunshot = Sound:new("snd/gunshot.wav", 8)
  Sounds.pew1 = Sound:new("snd/pew1.wav", 8)
  Sounds.pew2 = Sound:new("snd/pew2.wav", 8)
  Sounds.pew3 = Sound:new("snd/pew3.wav", 8)
  Sounds.pew4 = Sound:new("snd/pew4.wav", 8)
  Sounds.pew5 = Sound:new("snd/pew5.wav", 8)
  Sounds.pew6 = Sound:new("snd/pew6.wav", 8)
  Sounds.pew7 = Sound:new("snd/pew7.wav", 8)
  Sounds.pew8 = Sound:new("snd/pew8.wav", 8)
  Sounds.pew9 = Sound:new("snd/pew9.wav", 8)
  Sounds.pew10 = Sound:new("snd/pew10.wav", 8)
  Sounds.pew11 = Sound:new("snd/pew11.wav", 8)
  Sounds.pew12 = Sound:new("snd/pew12.wav", 8)
  Sounds.impact = Sound:new("snd/impact.wav", 5)
  Sounds.unholster = Sound:new("snd/gun_unholster.mp3", 1)
  Sounds.launch = Sound:new("snd/launch.mp3", 15)
  Sounds.miss = Sound:new("snd/miss.wav", 1)
  Sounds.bust = Sound:new("snd/bust.wav", 1)
  Sounds.blackjack = Sound:new("snd/impact.wav", 1) -- TODO: design a sound
  Sounds.titleLoop = Sound:new("snd/title_loop.mp3", 1)
  Sounds.titleLoop:setLooping(true)
  --Sounds.music = Sound:new("snd/music.wav", 1)
  --Sounds.music:setLooping(true)
  Sounds.gameMusicVerb = Sound:new("snd/game_music_loop_verb.mp3", 1)
  Sounds.gameMusicVerb:setLooping(true)
end

-- Main methods
local function load()
  scene = nil
  isTransitioningScenes = false
  -- Init sounds
  initSounds()
  -- Initialize game vars
  entities = {}
  -- Start at the title screen
  initTitleScreen()
end

local function playGunshotSound()
  -- Gunshot
  Sounds.gunshot:play()

  -- A random pew.
  local pew = math.random(1, 12)
  if     pew == 1 then  Sounds.pew1:play()
  elseif pew == 2 then  Sounds.pew2:play()
  elseif pew == 3 then  Sounds.pew3:play()
  elseif pew == 4 then  Sounds.pew4:play()
  elseif pew == 5 then  Sounds.pew5:play()
  elseif pew == 6 then  Sounds.pew6:play()
  elseif pew == 7 then  Sounds.pew7:play()
  elseif pew == 8 then  Sounds.pew8:play()
  elseif pew == 9 then  Sounds.pew9:play()
  elseif pew == 10 then Sounds.pew10:play()
  elseif pew == 11 then Sounds.pew11:play()
  elseif pew == 12 then Sounds.pew12:play()
  end
end

local function update(dt)
  -- Update all promises
  Promise.updateActivePromises(dt)
  -- Update all entities
  local index, entity
  for index, entity in ipairs(entities) do
    if entity.isAlive and (isTransitioningScenes or entity:checkScene(scene)) then
      entity.timeAlive = entity.timeAlive + dt
      entity:update(dt)
      entity:countDownToDeath(dt)
    end
  end
  -- Remove dead entities
  entities = removeDeadEntities(entities)
end

local function draw()
  -- Draw all entities
  local index, entity
  for index, entity in ipairs(entities) do
    love.graphics.setColor(1, 1, 1, 1)
    entity:draw()
  end
end

local function onMousePressed(x, y)
  playGunshotSound()
  local index, entity
  for index, entity in ipairs(entities) do
    if entity.isAlive then
      entity:onMousePressed(x, y)
    end
  end
end

return {
  load = load,
  update = update,
  draw = draw,
  onMousePressed = onMousePressed
}
