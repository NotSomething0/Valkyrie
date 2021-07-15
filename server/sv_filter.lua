local filterMessages = 0
local filteredText = {}

exports.chat:registerMessageHook(function(source, outMessage, hookRef)
  local content = outMessage.args[2]

  if filterMessages == 1 then
    for _, text in pairs(filteredText) do
      if content:find(text) then
        content = content:gsub(text, ("#"):rep(text:len()))
      end
    end
    hookRef.updateMessage({args = {outMessage.args[1], content}})
  else
    for _, text in pairs(filteredText) do
      if content:lower():find(text:lower()) then
        hookRef.cancel()
        break
      end
    end
  end
end)

AddEventHandler('vac_initalize_server', function(module)
  if module == 'filter' or 'all' then

    local count = #filteredText

    for i = 1, count do
      filteredText[i] = nil
    end

    local text = json.decode(GetConvar('valkyrie_blocked_expressions', '[]'))

    for i = 0, #text do
      rawset(filteredText, i, text[i])
    end

    filterMessages = GetConvarInt('valkyrie_filter_messages', 0)
  end
end)
