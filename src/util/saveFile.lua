local function getFilePath(fileName)
  local directoryPath = love.filesystem.getSaveDirectory() .. '/saves'
  local info = love.filesystem.getInfo(directoryPath)
  if not info then
    print('Creating save directory...')
    if love.filesystem.createDirectory(directoryPath) then
      print('Successfully created save directory at ' .. directoryPath)
    else
      print('Unable to create save directory at ' .. directoryPath)
    end
  end
  return directoryPath .. '/' .. fileName
end

local function load(fileName)
  print('Loading save data...')
  -- Read the file
  local filePath = getFilePath(fileName)
  local fileInfo = love.filesystem.getInfo(filePath)
  if not fileInfo then
    print('Unable to load save data: no save file exists!')
    return {}
  else
    local fileContents, fileSize = love.filesystem.read(filePath)
    print('Loaded save data!\n' .. fileContents)
    if fileSize > 0 then
      -- Unstringify the data
      local saveData = {}
      local key = ''
      local value = ''
      local isReadingValue = false
      local i
      for i = 1, #fileContents do
        local char = fileContents:sub(i, i)
        if char == '\n' then
          if #key > 0 then
            saveData[key] = value
          end
          key = ''
          value = ''
          isReadingValue = false
        elseif isReadingValue then
          value = value .. char
        elseif char == '=' then
          isReadingValue = true
        else
          key = key .. char
        end
      end
      if #key > 0 then
        saveData[key] = value
      end
      -- Return the save data as an object
      return saveData
    else
      return {}
    end
  end
end

local function save(fileName, data)
  print('Saving...')
  -- Stringify the data
  local stringifiedData = ''
  local key, value
  for key, value in pairs(data) do
    stringifiedData = stringifiedData .. key .. '=' .. tostring(value) .. '\n'
  end
  -- Write it to a file
  local success, message = love.filesystem.write(getFilePath(fileName), stringifiedData)
  -- Return the results
  if success then
    print('Successfully saved!\n' .. stringifiedData)
    return data
  else
    print('Unable to save: ' .. message)
  end
end

return {
  load = load,
  save = save
}
