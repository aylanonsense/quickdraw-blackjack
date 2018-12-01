-- Game dimensions are display-independent (i.e. not pixel-based)
local GAME_WIDTH = 125
local GAME_HEIGHT = 220

-- Screen dimensions are hardware-based (what's the size of the display device)
local SCREEN_WIDTH = 400
local SCREEN_HEIGHT = 700

-- Render dimenisions reflect how the game should be drawn to the canvas
local RENDER_SCALE = math.floor(math.min(SCREEN_WIDTH / GAME_WIDTH, SCREEN_HEIGHT / GAME_HEIGHT))
local RENDER_WIDTH = RENDER_SCALE * GAME_WIDTH
local RENDER_HEIGHT = RENDER_SCALE * GAME_HEIGHT
local RENDER_X = (SCREEN_WIDTH - RENDER_WIDTH) / 2
local RENDER_Y = (SCREEN_HEIGHT - RENDER_HEIGHT) / 2

return {
  GAME_WIDTH = GAME_WIDTH,
  GAME_HEIGHT = GAME_HEIGHT,
  SCREEN_WIDTH = SCREEN_WIDTH,
  SCREEN_HEIGHT = SCREEN_HEIGHT,
  RENDER_SCALE = RENDER_SCALE,
  RENDER_WIDTH = RENDER_WIDTH,
  RENDER_HEIGHT = RENDER_HEIGHT,
  RENDER_X = RENDER_X,
  RENDER_Y = RENDER_Y
}
