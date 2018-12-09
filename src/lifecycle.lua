local Promise = require('src/Promise')

local scene = nil
local isChangingScenes = false
local changeScenePromise = nil

local function createTitleScreen()
  scene = 'title'
end

local function startGame()
  if scene == 'title' and not isChangingScenes then
    isChangingScenes = true
  end
end

return {
  startGame = startGame
}
