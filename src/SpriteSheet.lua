local createClass = require 'src/util/createClass'

-- This class makes it easy to draw parts of an image to the screen
local SpriteSheet = createClass({
  constructor = function(self, filePath, quadParams)
    self.image = love.graphics.newImage(filePath)
    self.image:setFilter('nearest', 'nearest')
    self.quads = {}
    local quadName, dimensions
    for quadName, props in pairs(quadParams) do
      if type(props[1]) == 'number' then
        self.quads[quadName] = love.graphics.newQuad(props[1], props[2], props[3], props[4], self.image:getDimensions())
      -- Pass in a function and an array of dimensions to generate a series of quads
      else
        self.quads[quadName] = {}
        local generate = props[1]
        local dimensions = props[2]
        local numQuads = 1
        local index, dimension
        for index, dimension in ipairs(dimensions) do
          numQuads = numQuads * dimension
        end
        local i
        for i = 0, numQuads - 1 do
          local quadObj = self.quads[quadName]
          local args = {}
          local denominator = 1
          for index, dimension in ipairs(dimensions) do
            local value = 1 + (math.floor(i / denominator) % dimension)
            table.insert(args, value)
            if index == #dimensions then
              local generatedProps = generate(unpack(args))
              quadObj[value] = love.graphics.newQuad(generatedProps[1], generatedProps[2], generatedProps[3], generatedProps[4], self.image:getDimensions())
            else
              if not quadObj[value] then
                quadObj[value] = {}
              end
              quadObj = quadObj[value]
            end
            denominator = denominator * dimension
          end
        end
      end
    end
  end,
  getQuad = function(self, quadName)
    -- e.g. getQuad('SWORD')
    if type(quadName) == 'string' then
      return self.quads[quadName]
    -- e.g. getQuad({ 'RUN', 5})
    else
      local quad = self.quads
      local index, dimension
      for index, dimension in ipairs(quadName) do
        quad = quad[dimension]
      end
      return quad
    end
  end,
  draw = function(self, quadName, x, y, r, offsetX, offsetY)
    love.graphics.draw(self.image, self:getQuad(quadName), x, y, (r or 0) * math.pi / 180, 1, 1, -(offsetX or 0), -(offsetY or 0))
  end,
  drawCentered = function(self, quadName, x, y, r, offsetX, offsetY)
    local quadX, quadY, quadWidth, quadHeight = self:getQuad(quadName):getViewport()
    return self:draw(quadName, x, y, r, (offsetX or 0) - quadWidth / 2, (offsetY or 0) - quadHeight / 2)
  end
})

return SpriteSheet
