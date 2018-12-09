local Entity = require 'src/Entity'

local PlayButton = Entity.extend({
  width = 33,
  height = 23,
  scenes = { 'title' },
  constructor = function(self)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
  end,
  draw = function(self)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('line', self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  end,
  -- Checks to see if the point x,y is contained within this button
  containsPoint = function(self, x, y)
    return self.shape:testPoint(self.x, self.y, 0, x, y)
  end,
  onMousePressed = function(self, x, y)
    if self:containsPoint(x, y) then
      self:onClicked(x, y)
    end
  end,
  onClicked = function(self, x, y) end
})

return PlayButton
