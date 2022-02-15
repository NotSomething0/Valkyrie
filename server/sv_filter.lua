local filterMessages = 0
local filteredText = {}

exports.chat:registerMessageHook(function(source, outMessage, hookRef)
  local message = outMessage.args[2]

  if (filterMessages == 1 and #filteredText ~= 0) then
    for _, v in pairs(filteredText) do
      local b, e = message:lower():find(v:lower())
      local s = b and e and message:sub(b, e)

      if (s) then
        message = message:sub(1, b - 1) ..('#'):rep(s:len()) .. message:sub(e + 1)
      end
    end

    hookRef.updateMessage({args = {outMessage.args[1], message}})
  else
    message = outMessage.args[2]:lower()

    for _, v in pairs(filteredText) do
      if (message:find(v:lower())) then
        hookRef.cancel()
        break
      end
    end
  end
end)

AddEventHandler('__vac_internel:intalizeServer', function(module)
  if (module == 'chat' or 'all') then
    local count = #filteredText

    if (count ~= 0) then
      for i = 1, count do
        filteredText[i] = nil
      end
    end

    local toFilter = json.decode('vac_filterText', '{}')

    if (toFilter ~= '{}') then
      for i = 1, #toFilter do
        rawset(filteredText, i, toFilter[i])
      end
    end

    filterMessages = GetConvarInt('vac_filterMessages' 0)
  end
end)
