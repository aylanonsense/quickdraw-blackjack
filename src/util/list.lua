-- Maps a list to another list using a transformation function
local function map(list, transformFunc)
  local transformedList = {}
  for index, item in ipairs(list) do
    transformedList[index] = transformFunc(item, index)
  end
  return transformedList
end

-- Filters a list so that only items that match the criteria function remain
local function filter(list, criteriaFunc)
  local filteredList = {}
  for index, item in ipairs(list) do
    if criteriaFunc(item, index) then
      table.insert(filteredList, item)
    end
  end
  return filteredList
end

return {
  map = map,
  filter = filter
}
