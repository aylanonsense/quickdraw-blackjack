local function randBucket(weights, values)
  local totalWeight = 0.0
  local index, weight
  for index, weight in ipairs(weights) do
    totalWeight = totalWeight + weight
  end
  local r = math.random()
  local p = 0.0
  for index, weight in ipairs(weights) do
    p = p + weight / totalWeight
    if p >= r then
      if values then
        return values[index]
      else
        return index
      end
    end
  end
end

return randBucket