-- Maps a list to another list using a transformation function
local function map(list, transformFunc)
  local transformedList = {}
  local index, item
  for index, item in ipairs(list) do
    transformedList[index] = transformFunc(item, index)
  end
  return transformedList
end

-- Filters a list so that only items that match the criteria function remain
local function filter(list, criteriaFunc)
  local filteredList = {}
  local index, item
  for index, item in ipairs(list) do
    if criteriaFunc(item, index) then
      table.insert(filteredList, item)
    end
  end
  return filteredList
end

local function join(list, separator)
  local s = ''
  local index, item
  for index, item in ipairs(list) do
    s = s..(index > 1 and separator or '')..item
  end
  return s
end

return {
  map = map,
  filter = filter,
  join = join
}
