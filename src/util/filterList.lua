-- Filters a list so that only items that match the criteria function remain
local function filterList(list, criteriaFunc)
  local filteredList = {}
  for index, item in ipairs(list) do
    if criteriaFunc(item, index) then
      table.insert(filteredList, item)
    end
  end
  return filteredList
end

return filterList
