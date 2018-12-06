-- Maps a list to another list using a transformation function
local function map(list, transformFunc)
  local transformedList = {}
  for index, item in ipairs(list) do
    transformedList[index] = transformFunc(item, index)
  end
  return transformedList
end

return {
  map = map
}
