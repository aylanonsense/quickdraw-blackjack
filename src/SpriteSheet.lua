local createClass = require 'src/createClass'

-- This class makes it easy to draw parts of an image to the screen
local SpriteSheet = createClass({
  constructor = function(self, filePath, quadParams)
    self.image = love.graphics.newImage(filePath)
    self.image:setFilter('nearest', 'nearest')
    self.quads = {}
    local quadName, dimensions
    for quadName, dimensions in pairs(quadParams) do
      self.quads[quadName] = love.graphics.newQuad(dimensions[1], dimensions[2], dimensions[3], dimensions[4], self.image:getDimensions())
    end
  end,
  draw = function(self, quadName, x, y, r, offsetX, offsetY)
    love.graphics.draw(self.image, self.quads[quadName], x, y, (r or 0) * math.pi / 180, 1, 1, offsetX, offsetY)
  end,
  drawCentered = function(self, quadName, x, y, r, offsetX, offsetY)
    local quadX, quadY, quadWidth, quadHeight = self.quads[quadName]:getViewport()
    return self:draw(quadName, x, y, r, (offsetX or 0) + quadWidth / 2, (offsetY or 0) + quadHeight / 2)
  end
})

return SpriteSheet
