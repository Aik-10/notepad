var isUI = false;
var ArrayTable = [];
var editID = null;
var prop = null;
var secondaryprop = null;
const NotepadText = "~g~E~s~ to read,~g~G~s~ to destroy";

function DrawText3Ds(x,y,z, text) {
    let [onScreen,_x,_y ] = World3dToScreen2d(x,y,z)
    let [px,py,pz] = GetGameplayCamCoords();
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    let factor = (text.length) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68);
}

RegisterNuiCallbackType("Escape");
on("__cfx_nui:Escape", (data, cb) => {
	let text = data.text
    emit("client:CloseNotepad");
});

RegisterNuiCallbackType("Update");
on("__cfx_nui:Update", (data, cb) => {
	let text = data.text
    emitNet("server:updateNote", editID, text);
    editID = null
    emkit("client:CloseNotepad")
});

RegisterNuiCallbackType("DropEmpty");
on("__cfx_nui:DropEmpty", (data, cb) => {
	console.log("Empty dropping current")
});

RegisterNuiCallbackType("Drop");
on("__cfx_nui:Drop", (data, cb) => {
	let text = data.text
    let [x,y,z] = GetEntityCoords(GetPlayerPed(-1))
    emitNet("server:newNote",text,x,y,z)
    emit("client:CloseNotepad")
});

RegisterNetEvent("client:openNotepad")
on("client:openNotepad", () => {
	if (!isUI) openGui();
});

RegisterNetEvent("client:CloseNotepad")
on("client:CloseNotepad", () => {
    SendNuiMessage( JSON.stringify({ action: "closeNotepad" }))
    SetPlayerControl(PlayerId(), 1, 0)
    isUI = false
    let player = PlayerPedId()
    SetNuiFocus(false, false);
    TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(prop, 1, 1)
    DeleteObject(prop)
    DetachEntity(secondaryprop, 1, 1)
    DeleteObject(secondaryprop)
});

RegisterNetEvent("client:updateNotes")
on("client:updateNotes", (serv) => {
	ArrayTable = serv.filter(n => n);
});

function openGui() {
    let veh = GetVehiclePedIsUsing(GetPlayerPed(-1));
    if ( GetPedInVehicleSeat(veh, -1) !== GetPlayerPed(-1)) {
        SetPlayerControl(PlayerId(), 0, 0)
        SendNuiMessage( JSON.stringify({ action: "openNotepad" }))
        isUI = true;
        SetNuiFocus(true, true);
    } 
}

RegisterNetEvent("client:note")
on("client:note", () => {
	let player = PlayerPedId()
    const ad = "missheistdockssetup1clipboard@base"    
    const prop_name = 'prop_notepad_01'
    const secondaryprop_name = 'prop_pencil_01'
    if (  DoesEntityExist( player ) && !IsEntityDead( player )) {
        loadAnimDict( ad )
        if ( IsEntityPlayingAnim( player, ad, "base", 3 ) ) {
            TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 );
            ClearPedSecondaryTask(PlayerPedId())
            DetachEntity(prop, 1, 1)
            DeleteObject(prop)
            DetachEntity(secondaryprop, 1, 1)
            DeleteObject(secondaryprop)
        } else {
            let [x,y,z] = GetEntityCoords(player);
            prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
            secondaryprop = CreateObject(GetHashKey(secondaryprop_name), x, y, z+0.2,  true,  true, true)
            AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true)
            AttachEntityToEntity(secondaryprop, player, GetPedBoneIndex(player, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true)
            TaskPlayAnim( player, ad, "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        }
    }
});

function loadAnimDict (dict) {
    if ( !HasAnimDictLoaded(dict) ) {
        RequestAnimDict(dict);
    }
}

function openGuiRead(text) {
    let veh = GetVehiclePedIsUsing(GetPlayerPed(-1))
    if (GetPedInVehicleSeat(veh, -1) != GetPlayerPed(-1) ) {
        SetPlayerControl(PlayerId(), 0, 0)
        emit("client:note")
        isUI = true
        console.log("OPENING")
        SendNuiMessage( JSON.stringify({ action: "openNotepadRead", TextRead: JSON.parse(text) }))
        SetNuiFocus(true, true)
    }
}

setTick(() => {
    if ( ArrayTable.length !== 0 ){
        let closestNoteDistance = 900.0
        let closestNoteId = 0
        let [x,y,z] = GetEntityCoords(GetPlayerPed(-1));
        for( let i = 0; i < ArrayTable.length; i++ ) {
            let distance = GetDistanceBetweenCoords(x,y,z, ArrayTable[i].x, ArrayTable[i].y, ArrayTable[i].z, true);
            if ( distance < 10.0 ) {
                DrawMarker(27, ArrayTable[i].x, ArrayTable[i].y, ArrayTable[i].z-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 2.0, 255, 255, 155, 75, false, true, 2, null, null, false);
            }
            if ( distance < closestNoteDistance ) {
                closestNoteDistance = distance;
                closestNoteId = i;
                // console.log("console.log: " + closestNoteId + ", Distance: " + distance + ", closestNoteDistance: " + closestNoteDistance);
            }
        }

        if ( ArrayTable[closestNoteId] != null ) {
            let distance = GetDistanceBetweenCoords(x,y,z, ArrayTable[closestNoteId].x, ArrayTable[closestNoteId].y, ArrayTable[closestNoteId].z, true); 
            if ( distance < 2.0 ) {
                DrawMarker(27, ArrayTable[closestNoteId].x, ArrayTable[closestNoteId].y, ArrayTable[closestNoteId].z-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 2.0, 255, 255, 155, 75, false, true, 2, null, null, false);
                DrawText3Ds(ArrayTable[closestNoteId].x, ArrayTable[closestNoteId].y, ArrayTable[closestNoteId].z-0.4, NotepadText);

                if ( IsControlJustReleased ( 0, 38 ) ){
                    openGuiRead(ArrayTable[closestNoteId].text)
                    editID = closestNoteId;
                }

                if ( IsControlJustReleased ( 0, 47 ) ){
                    emitNet("server:destroyNote", ArrayTable[closestNoteId].text, ArrayTable[closestNoteId].x,ArrayTable[closestNoteId].y,ArrayTable[closestNoteId].z);
                    // delete ArrayTable[closestNoteId];
                    ArrayTable = ArrayTable.filter(n => n);
                }
            }
        }else {
            if ( ArrayTable[closestNoteId] != null ) {
                // delete ArrayTable[closestNoteId];
                ArrayTable = ArrayTable.filter(n => n);
            }
        }
    }
});