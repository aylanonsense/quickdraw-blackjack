local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local Card = require 'src/entity/Card'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ui.png', {
  HOW_TO_PLAY = { 203, 293, 110, 18 },
  HAND_LESSON = { 213, 215, 68, 35 },
  POINTS_LESSON = { 203, 312, 119, 8 },
  BLACKJACK_LESSON = { 213, 251, 61, 20 },
  ROUND_LESSON = { 203, 272, 94, 20 }
})

local TutorialScreen = Entity.extend({
  scenes = { 'tutorial' },
  constructor = function(self)
    Entity.constructor(self)
    Card:spawn({
      rankIndex = 9,
      suitIndex = 1,
      x = constants.GAME_MIDDLE_X - 35 - constants.CARD_WIDTH / 2 - 1,
      y = 0.195 * constants.GAME_HEIGHT,
      scenes = { 'tutorial' }
    })
    Card:spawn({
      rankIndex = 6,
      suitIndex = 3,
      x = constants.GAME_MIDDLE_X - 35 + constants.CARD_WIDTH / 2 + 1,
      y = 0.195 * constants.GAME_HEIGHT,
      scenes = { 'tutorial' }
    })
    Card:spawn({
      rankIndex = 3,
      suitIndex = 2,
      canBeShot = true,
      x = constants.GAME_MIDDLE_X + 35,
      y = 0.38 * constants.GAME_HEIGHT,
      vr = 60,
      scenes = { 'tutorial' }
    })
  end,
  draw = function(self)
    SPRITESHEET:drawCentered('HOW_TO_PLAY', constants.GAME_MIDDLE_X, constants.GAME_TOP + 13)
    SPRITESHEET:drawCentered('HAND_LESSON', constants.GAME_MIDDLE_X + 27, constants.GAME_HEIGHT * 0.195)
    SPRITESHEET:drawCentered('BLACKJACK_LESSON', constants.GAME_MIDDLE_X - 27, constants.GAME_HEIGHT * 0.38)
    SPRITESHEET:drawCentered('POINTS_LESSON', constants.GAME_MIDDLE_X, constants.GAME_HEIGHT * 0.51)
    SPRITESHEET:drawCentered('ROUND_LESSON', constants.GAME_MIDDLE_X, constants.GAME_HEIGHT * 0.63)
  end
})

return TutorialScreen
