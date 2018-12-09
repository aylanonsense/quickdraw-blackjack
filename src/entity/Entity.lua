local createClass = require 'src/util/createClass'
local easingFunctions = require 'src/util/easing'

-- This is the base class for all game entities
local Entity = createClass({
  isAlive = true,
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  vxPrev = nil,
  vyPrev = nil,
  frameRateIndependent = false,
  timeToDeath = 0,
  constructor = function(self)
    self.animations = {}
  end,
  update = function(self, dt)
    self:applyVelocity(dt)
    self:applyAnimations(dt)
  end,
  draw = function(self) end,
  setVelocity = function(self, vx, y)
    self.vx = vx
    self.vy = vy
    self.vxPrev = vx
    self.vyPrev = vy
  end,
  applyVelocity = function(self, dt)
    if not self:animationsInclude('x') and not self:animationsInclude('y') then
      if self.frameRateIndependent and self.vxPrev ~= nil and self.vyPrev ~= nil then
        self.x = self.x + (self.vx + self.vxPrev) / 2 * dt
        self.y = self.y + (self.vy + self.vyPrev) / 2 * dt
      else
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
      end
    end
    self.vxPrev = self.vx
    self.vyPrev = self.vy
  end,
  applyAnimations = function(self, dt)
    local animationsLeft = {}
    local index, animation
    for index, animation in ipairs(self.animations) do
      animation.timeRemaining = animation.timeRemaining - dt
      local p = math.max(0, math.min(1 - (animation.timeRemaining / animation.duration), 1))
      animation.apply(p)
      if animation.timeRemaining > 0 then
        table.insert(animationsLeft, animation)
      end
    end
    self.animations = animationsLeft
  end,
  cancelAnimations = function(self)
    self.animations = {}
  end,
  animationsInclude = function(self, attr)
    local index, animation
    for index, animation in ipairs(self.animations) do
      if animation.attributes[attr] then
        return true
      end
    end
    return false
  end,
  countDownToDeath = function(self, dt)
    if self.timeToDeath > 0 then
      self.timeToDeath = self.timeToDeath - dt
      if self.timeToDeath <= 0 then
        self:die()
        return true
      end
    end
    return false
  end,
  die = function(self)
    if self.isAlive then
      self.isAlive = false
      self:onDeath()
    end
  end,
  onDeath = function(self) end,
  onMousePressed = function(self, x, y) end,
  checkScene = function(self, scene)
    if self.scenes then
      local isInValidScene = false
      local index, scene2
      for index, scene2 in ipairs(self.scenes) do
        if scene2 == scene then
          isInValidScene = true
        end
      end
      if not isInValidScene then
        self:die()
        return false
      end
    end
    return true
  end,
  animate = function(self, attributes, duration)
    local processedAttributes = {}
    local attr, props
    local overridesMovement = false
    for attr, props in pairs(attributes) do
      local startValue = self[attr]
      local endValue
      if type(props.change) == 'number' then
        endValue = startValue + props.change
      else
        endValue = props.value
      end
      if attr == 'x' or attr == 'y' then
        overridesMovement = true
      end
      local easing = props.easing or 'linear'
      processedAttributes[attr] = {
        startValue = startValue,
        endValue = endValue,
        easing = type(easing) == 'string' and easingFunctions[easing] or easing
      }
    end
    local animation = {
      duration = duration,
      timeRemaining = duration,
      attributes = processedAttributes,
      apply = function(p)
        local attr, props
        for attr, props in pairs(processedAttributes) do
          local p2 = props.easing(p)
          self[attr] = props.endValue * p2 + props.startValue * (1 - p2)
        end
      end
    }
    if animation.duration > 0 then
      table.insert(self.animations, animation)
      animation.apply(0)
    else
      animation.apply(1)
    end
    return animation
  end
})

return Entity
