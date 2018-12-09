local function linear(p)
  return p
end

local function easeOut(p)
  return p ^ 4
end

local function easeIn(p)
  return 1 - easeOut(1 - p)
end

local function easeOutIn(p)
  return (p < 0.5 and easeOut(2 * p) or (easeIn(2 * p - 1) + 1)) / 2
end

return {
  linear = linear,
  easeOut = easeOut,
  easeIn = easeIn,
  easeOutIn = easeOutIn
}
