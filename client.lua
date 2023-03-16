--[[
 _  _ _____   _                             _      
| || |___  |_| |_   _ _ __   __ _ _ __ ___ (_) ___ 
| || |_ / / _` | | | | '_ \ / _` | '_ ` _ \| |/ __|
|__   _/ / (_| | |_| | | | | (_| | | | | | | | (__ 
   |_|/_/ \__,_|\__, |_| |_|\__,_|_| |_| |_|_|\___|
                |___/                              
--]]

local kreiranipedovi = {}

RegisterCommand('napravipeda', function(source, args, rawCommand)
    if not args[1] or args[1] == "" then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'SERVER', 'Morate unijeti model peda!' }
        })
        return
    end

    local model = args[1]
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
    local h = GetEntityHeading(PlayerPedId())
    local id = math.random(1, 1000)

    while kreiranipedovi[id] do
        id = math.random(1, 1000)
    end 

    RequestModel(model)
    while not HasModelLoaded(model) do 
        Citizen.Wait(1)
    end

    local prizemlji, podZ = GetGroundZFor_3dCoord(x, y, z)
    if prizemlji then
        z = podZ
    end

    local npc = CreatePed(4, model, x, y, z, h, false, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetPedDropsWeaponsWhenDead(npc, false)
    SetPedDiesWhenInjured(npc, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    local pedinfo = {
        id = id,
        model = model,
        x = x,
        y = y,
        z = z,
        h = h,
        npc = npc
    }
    table.insert(kreiranipedovi, pedinfo)

    TriggerServerEvent('47dynamic:sacuvajpeda', id, model, x, y, z, h)
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0 },
        multiline = true,
        args = { 'SERVER', 'PED '.. model ..' uspjesno napravljen sa ID '..id..'!' }
    })
end)

RegisterCommand('obrisipeda', function(source, args, rawCommand)
    local najbliziped = locirajpeda()

    if najbliziped ~= nil then
        local pedId = nil
        for i=1, #kreiranipedovi do
            if kreiranipedovi[i].npc == najbliziped then
                pedId = kreiranipedovi[i].id
                DeletePed(najbliziped)
                table.remove(kreiranipedovi, i)
                break
            end
        end
		
        TriggerServerEvent('47dynamic:obrisipeda', pedId)
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'SERVER', 'PED sa ID '..pedId..' je uspjesno obrisan!' }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'SERVER', 'PED nije u blizni!' }
        })
    end
end)

RegisterCommand('dodajanimaciju', function(source, args, rawCommand)
    local najbliziped = locirajpeda()

    if najbliziped ~= nil then
        local pedId = nil
        for i=1, #kreiranipedovi do
            if kreiranipedovi[i].npc == najbliziped then
                pedId = kreiranipedovi[i].id
                break
            end
        end

        local animacija = args[1]

        if animacija ~= nil then
            TaskStartScenarioInPlace(najbliziped, animacija, 0, false)
            TriggerServerEvent('47dynamic:sacuvajanimaciju', pedId, animacija)
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                multiline = true,
                args = { 'SERVER', 'Dodali ste animaciju '..animacija..' pedu!' }
            })
        else
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                multiline = true,
                args = { 'SERVER', 'Morate unijeti ime animacije!' }
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'SERVER', 'Nema pedova u blizini!' }
        })
    end
end)

RegisterCommand('uklonianimaciju', function(source, args, rawCommand)
    local najbliziped = locirajpeda()
    
    if najbliziped ~= nil then
        local pedId = nil
        for i=1, #kreiranipedovi do
            if kreiranipedovi[i].npc == najbliziped then
                pedId = kreiranipedovi[i].id
                break
            end
        end
    
        if pedId ~= nil then
            ClearPedTasks(najbliziped)
            TriggerServerEvent('47dynamic:uklonianimaciju', pedId)
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                multiline = true,
                args = { 'SERVER', 'Uklonili ste animaciju sa peda!' }
            })
        else
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                multiline = true,
                args = { 'SERVER', 'Ped nije pronadjen u bazi!' }
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'SERVER', 'Nema pedova u blizini!' }
        })
    end
end)

RegisterNetEvent('47dynamic:ucitajpedove')
AddEventHandler('47dynamic:ucitajpedove', function(peds)
    kreiranipedovi = {}
    local i = 1

    local function ucitajPed()
        if i > #peds then
            return
        end

        local id = peds[i].id
        local model = peds[i].model
        local x = peds[i].x
        local y = peds[i].y
        local z = peds[i].z
        local h = peds[i].h
        local hash = GetHashKey(model)

        RequestModel(hash)
        while not HasModelLoaded(hash) do 
            Citizen.Wait(1)
        end

        local npc = CreatePed(4, hash, x, y, z, h, false, true)
        SetPedFleeAttributes(npc, 0, 0)
        SetPedDropsWeaponsWhenDead(npc, false)
        SetPedDiesWhenInjured(npc, false)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        local pedinfo = {
            id = id,
            model = model,
            x = x,
            y = y,
            z = z,
            h = h,
            npc = npc
        }

        table.insert(kreiranipedovi, pedinfo)

        i = i + 1

        Citizen.CreateThread(ucitajPed)
    end

    Citizen.CreateThread(ucitajPed)
end)

locirajpeda = function()
    local playerPed = PlayerPedId()
    local najbliziped = nil
    local najblizipeddist = 10.0

    for i=1, #kreiranipedovi do
        local ped = kreiranipedovi[i].npc
        local pedCoords = GetEntityCoords(ped)
        local dist = #(GetEntityCoords(playerPed) - pedCoords)

        if DoesEntityExist(ped) and dist < najblizipeddist then
            najbliziped = ped
            najblizipeddist = dist
        end
    end

    return najbliziped
end
