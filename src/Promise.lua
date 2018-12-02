local createClass = require 'src/createClass'

-- This is an implementation for faux promises. They aren't actual promises--
--  they can't reject or return data or anything like that--but they're useful
--  for scheduling
local Promise
Promise = createClass({
  -- Static properties and methods
  activePromises = {},
  newActive = function(...)
    local promise = Promise.new(...)
    promise:activate()
    return promise
  end,
  updateActivePromises = function(dt)
    local promises = {}
    local index, promise
    for index, promise in ipairs(Promise.activePromises) do
      promise:update(dt)
      if promise.status == 'active' then
        table.insert(promises, promise)
      end
    end
    Promise.activePromises = promises
  end,
  -- Instance properties and methods
  isPromise = true,
  status = 'inactive',
  onActivate = nil,
  timeToResolve = 0.00,
  isRecursiveDeactivate = false,
  constructor = function(self, handler, ...)
    self.promises = {}
    -- Pass in a number and the Promise will auto-resolve after that amount of time
    if type(handler) == 'number' then
      self.timeToResolve = handler
    -- Pass in a function and it'll be called when activated
    elseif type(handler) == 'function' then
      local args = {...}
      self.onActivate = function()
        local timeToResolve = handler(unpack(args))
        if type(timeToResolve) == 'number' then
          self.timeToResolve = timeToResolve
        else
          self:resolve()
        end
      end
    end
  end,
  activate = function(self)
    if self.status == 'inactive' then
      self.status = 'active'
      -- Activate the promise
      if self.onActivate then
        self:onActivate()
      elseif self.timeToResolve <= 0.0 then
        self:resolve()
      end
      -- So long as that didn't resolve or deactivate it, add it to a list of active promises
      if self.status == 'active' then
        table.insert(Promise.activePromises, self)
      end
    end
  end,
  deactivate = function(self, recursive)
    if self.status ~= 'deactivated' or (recursive and not self.isRecursiveDeactivate) then
      self.status = 'deactivated'
      self.isRecursiveDeactivate = recursive
      if self.isRecursiveDeactivate then
        local index, promise
        for index, promise in ipairs(self.promises) do
          promise:deactivate(true)
        end
      end
    end
  end,
  update = function(self, dt)
    if self.status == 'active' and self.timeToResolve > 0.0 then
      self.timeToResolve = self.timeToResolve - dt
      if self.timeToResolve <= 0.0 then
        self:resolve()
      end
    end
  end,
  resolve = function(self)
    if self.status == 'active' then
      self.status = 'resolved'
      local index, promise
      for index, promise in ipairs(self.promises) do
        promise:activate()
      end
    end
  end,
  andThen = function(self, ...)
    -- Wrap the args up in a promise
    local args = {...}
    local promise
    if #args == 1 and args.isPromise then
      promise = args[1]
    else
      promise = Promise.new(...)
    end
    -- Decide whether to activate the promise now
    table.insert(self.promises, promise)
    if self.status == 'deactivated' then
      if self.isRecursiveDeactivate then
        promise:deactivate(true)
      end
    elseif self.status == 'resolved' then
      promise:activate()
    end
    -- Return the promise
    return promise
  end
})

return Promise
