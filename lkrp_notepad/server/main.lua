ESX = nil
local savedNotes = {
  
}

TriggerEvent('server:LoadsNote')
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--#Delete comments to use from inventory
-- ESX.RegisterUsableItem('notepad', function(source)
--   local _source  = source
--   local xPlayer   = ESX.GetPlayerFromId(_source)
--   TriggerClientEvent('lkrp_notepad:note', _source)
--   TriggerClientEvent('lkrp_notepad:OpenNotepadGui', _source)
-- end)

TriggerEvent('es:addCommand', 'notes', function(source, args, user)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local item    = xPlayer.getInventoryItem('notepad').count
if item > 0 then
    TriggerClientEvent('lkrp_notepad:note', _source)
    TriggerClientEvent('lkrp_notepad:OpenNotepadGui', _source)
    TriggerEvent('server:LoadsNote')
else
     TriggerClientEvent('esx:showNotification', _source, 'You dont have notepad.')
end
    
end, {help = "Open notepad if you have it!"})


RegisterNetEvent("server:LoadsNote")
AddEventHandler("server:LoadsNote", function()
   TriggerClientEvent('lkrp_notepad:updateNotes', -1, savedNotes)
end)

RegisterNetEvent("server:newNote")
AddEventHandler("server:newNote", function(text, x, y, z)
      local import = {
        ["text"] = ""..text.."",
        ["x"] = x,
        ["y"] = y,
        ["z"] = z,
      }
      table.insert(savedNotes, import)
      TriggerEvent("server:LoadsNote")
end)

RegisterNetEvent("server:updateNote")
AddEventHandler("server:updateNote", function(noteID, text)
  savedNotes[noteID]["text"]=text
  TriggerEvent("server:LoadsNote")
end)

RegisterNetEvent("server:destroyNote")
AddEventHandler("server:destroyNote", function(noteID)
  table.remove(savedNotes, noteID)
  TriggerEvent("server:LoadsNote")
end)

