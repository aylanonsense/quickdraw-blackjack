-- Helper function that "extends" one object from another
local function extend(sub, super)
  setmetatable(sub, { __index = super })
  return sub
end

-- Create a new class from an object
local createClass
createClass = function(class, superClass)
  -- If there's a superclass, extend from it
  if superClass then
    extend(class, superClass)
  end
  -- Add an extend method
  class.extend = function(subClass)
    return createClass(subClass, class)
  end
  -- Add an instantiation function to the class
  class.new = function(...)
    local args = {...}
    local instance
    if #args == 1 and type(args[1]) == 'table' then
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
