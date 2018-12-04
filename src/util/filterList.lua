local function filterList(list, func)
  local filteredList = {}
  for index, item in ipairs(list) do
    if func(item, index) then
      table.insert(filteredList, item)
    end
  end
  return filteredList
end

return filterList
