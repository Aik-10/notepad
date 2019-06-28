ESX = nil
local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local keyParam = Keys["ESC"]
local isUiOpen = false 
local object = 0
local TestLocalTable = {}
local editingNotpadId = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NetworkIsSessionStarted() then
            Citizen.Wait(100)
            TriggerServerEvent("server:LoadsNote")
            return -- break the loop
        end
    end
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)

end


RegisterNUICallback('escape', function(data, cb)
    local text = data.text
    TriggerEvent("lkrp_notepad:CloseNotepad")
end)

RegisterNUICallback('updating', function(data, cb)
    local text = data.text
    TriggerServerEvent("server:updateNote",editingNotpadId, text)
    editingNotpadId = nil
    TriggerEvent("lkrp_notepad:CloseNotepad")
end)

RegisterNUICallback('droppingEmpty', function(data, cb)
    exports['mythic_notify']:DoHudText('error', 'You cant drop empty notepad')
end)

RegisterNUICallback('dropping', function(data, cb)
    local text = data.text
    local location = GetEntityCoords(GetPlayerPed(-1))
    TriggerServerEvent("server:newNote",text,location["x"],location["y"],location["z"])
    TriggerEvent("lkrp_notepad:CloseNotepad")
end)

RegisterNetEvent("lkrp_notepad:OpenNotepadGui")
AddEventHandler("lkrp_notepad:OpenNotepadGui", function()
    if not isUiOpen then
        openGui()
    end
end)

RegisterNetEvent("lkrp_notepad:CloseNotepad")
AddEventHandler("lkrp_notepad:CloseNotepad", function()
    SendNUIMessage({
        action = 'closeNotepad'
    })
    SetPlayerControl(PlayerId(), 1, 0)
    isUiOpen = false
    SetNuiFocus(false, false);
    TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    Citizen.Wait(100)
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(prop, 1, 1)
    DeleteObject(prop)
    DetachEntity(secondaryprop, 1, 1)
    DeleteObject(secondaryprop)
end)

RegisterNetEvent('lkrp_notepad:note')
AddEventHandler('lkrp_notepad:note', function()
    local player = PlayerPedId()
    local ad = "missheistdockssetup1clipboard@base"
                
    local prop_name = prop_name or 'prop_notepad_01'
    local secondaryprop_name = secondaryprop_name or 'prop_pencil_01'
    
    if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
        loadAnimDict( ad )
        if ( IsEntityPlayingAnim( player, ad, "base", 3 ) ) then 
            TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
            Citizen.Wait(100)
            ClearPedSecondaryTask(PlayerPedId())
            DetachEntity(prop, 1, 1)
            DeleteObject(prop)
            DetachEntity(secondaryprop, 1, 1)
            DeleteObject(secondaryprop)
        else
            local x,y,z = table.unpack(GetEntityCoords(player))
            prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
            secondaryprop = CreateObject(GetHashKey(secondaryprop_name), x, y, z+0.2,  true,  true, true)
            AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true) -- lkrp_notepadpad
            AttachEntityToEntity(secondaryprop, player, GetPedBoneIndex(player, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true) -- pencil
            TaskPlayAnim( player, ad, "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        end     
    end
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

RegisterNetEvent('lkrp_notepad:updateNotes')
AddEventHandler('lkrp_notepad:updateNotes', function(serverNotesPassed)
    TestLocalTable = serverNotesPassed
end)

function openGui() 
    local veh = GetVehiclePedIsUsing(GetPlayerPed(-1))  
    if GetPedInVehicleSeat(veh, -1) ~= GetPlayerPed(-1) then
        SetPlayerControl(PlayerId(), 0, 0)
        SendNUIMessage({
            action = 'openNotepad',
        })
        isUiOpen = true
        SetNuiFocus(true, true);
    end
end

function openGuiRead(text)
  local veh = GetVehiclePedIsUsing(GetPlayerPed(-1))
  if GetPedInVehicleSeat(veh, -1) ~= GetPlayerPed(-1) then
        SetPlayerControl(PlayerId(), 0, 0)
        TriggerEvent("lkrp_notepad:note")
        isUiOpen = true
        Citizen.Trace("OPENING")
        SendNUIMessage({
            action = 'openNotepadRead',
            TextRead = text,
        })
        SetNuiFocus(true, true)
  end  
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if #TestLocalTable == 0 then
            Citizen.Wait(1000)
        else
            local closestNoteDistance = 900.0
            local closestNoteId = 0
            local plyLoc = GetEntityCoords(GetPlayerPed(-1))
            for i = 1, #TestLocalTable do
                local distance = GetDistanceBetweenCoords(plyLoc["x"], plyLoc["y"], plyLoc["z"], TestLocalTable[i]["x"],TestLocalTable[i]["y"],TestLocalTable[i]["z"], true)
                if distance < 10.0 then
                    DrawMarker(27, TestLocalTable[i]["x"],TestLocalTable[i]["y"],TestLocalTable[i]["z"]-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 2.0, 255, 255,150, 75, 0, 0, 2, 0, 0, 0, 0)
                end

                if distance < closestNoteDistance then
                  closestNoteDistance = distance
                  closestNoteId = i
                end
            end

            if closestNoteDistance > 100.0 then
                Citizen.Wait(math.ceil(closestNoteDistance*10))
            end

            if TestLocalTable[closestNoteId] ~= nil then
            local distance = GetDistanceBetweenCoords(plyLoc, TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"], true)
            if distance < 2.0 then
                DrawMarker(27, TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"]-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 2.0, 255, 255, 155, 75, 0, 0, 2, 0, 0, 0, 0)
                DrawText3Ds(TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"]-0.4, "~g~E~s~ to read,~g~G~s~ to destroy")

                if IsControlJustReleased(0, 38) then
                    openGuiRead(TestLocalTable[closestNoteId]["text"])
                    editingNotpadId = closestNoteId
                end
                if IsControlJustReleased(0, 47) then
                  TriggerServerEvent("server:destroyNote",closestNoteId)
                  table.remove(TestLocalTable,closestNoteId)
                end

            end
          else
            if TestLocalTable[closestNoteId] ~= nil then
              table.remove(TestLocalTable,closestNoteId)
            end
          end 

        end
    end 
end)