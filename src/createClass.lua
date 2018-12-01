-- Helper function that "extends" one object from another
local function extend(sub, super)
  setmetatable(sub, { __index = super })
  return sub
end

-- Create a new class from an object
local function createClass(class, superClass)
  -- If there's a superclass, extend from it
  if superClass then
    extend(class, superClass)
  end
  -- Add an instantiation function to the class
  class.new = function(...)
    local args = {...}
    local instance
    if #args == 1 and type(args) == 'table' then
      instance = extend(args[1], class)
    else
      instance = extend({}, class)
    end
    instance:constructor(...)
    return instance
  end
  -- Return the class
  return class
end

return createClass
