--[[
 _  _ _____   _                             _      
| || |___  |_| |_   _ _ __   __ _ _ __ ___ (_) ___ 
| || |_ / / _` | | | | '_ \ / _` | '_ ` _ \| |/ __|
|__   _/ / (_| | |_| | | | | (_| | | | | | | | (__ 
   |_|/_/ \__,_|\__, |_| |_|\__,_|_| |_| |_|_|\___|
                |___/                              
--]]

RegisterServerEvent('47dynamic:sacuvajpeda')
AddEventHandler('47dynamic:sacuvajpeda', function(id, model, x, y, z, h)
  MySQL.Async.execute('INSERT INTO pedovi (id, model, x, y, z, h) VALUES (@id, @model, @x, @y, @z, @h)', {
      ['@id'] = id,
      ['@model'] = model,
      ['@x'] = x,
      ['@y'] = y,
      ['@z'] = z,
      ['@h'] = h
  }, function(rowsChanged)
      if rowsChanged > 0 then
          print('[^3SQL^0]: PED sa ID ^4' ..id.. '^0 je ^2spremljen^0 u databazu.')
      else
          print('[^1ERROR^0]: Doslo je do greske prilikom ^1brisanja^0 peda iz databaze.')
      end
  end)
end)

RegisterServerEvent('47dynamic:obrisipeda')
AddEventHandler('47dynamic:obrisipeda', function(pedId)
    MySQL.Async.execute('DELETE FROM pedovi WHERE id = @id', {
        ['@id'] = pedId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print('[^3SQL^0]: PED sa ID ^4' ..pedId.. '^0 je ^1izbrisan^0 iz databaze.')
                
        else
            print('[^1ERROR^0]: Doslo je do greske prilikom ^1brisanja^0 peda iz databaze.')
        end
    end)
end)   

RegisterServerEvent('47dynamic:sacuvajanimaciju')
AddEventHandler('47dynamic:sacuvajanimaciju', function(pedId, animacija)
    MySQL.Async.execute('UPDATE pedovi SET animacija = @animacija WHERE id = @id', {
        ['@id'] = pedId,
        ['@animacija'] = animacija
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print('[^3SQL^0]: Animacija za PED sa ID ^4' ..pedId.. '^0 je ^2spremljena^0 u databazu.')
        else
            print('[^1ERROR^0]: Doslo je do greske prilikom ^1azuriranja^0 animacije u databazi.')
        end
    end)
end)

RegisterServerEvent('47dynamic:uklonianimaciju')
AddEventHandler('47dynamic:uklonianimaciju', function(pedId)
    MySQL.Async.execute('UPDATE pedovi SET animacija = NULL WHERE id = @id', {
        ['@id'] = pedId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print('[^3SQL^0]: Animacija za PED sa ID ^4' ..pedId.. '^0 je ^1uklonjena^0 iz databaze.')
        else
            print('[^1ERROR^0]: Doslo je do greske prilikom ^1uklanjanja^0 animacije iz databaze.')
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    info()
end)

AddEventHandler('playerConnecting', function()
    local src = source
    Citizen.Wait(5000)
    ucitaj('47dynamic:ucitajpedovesql', src)
end)

info = function(eventName)
    MySQL.Async.fetchAll('SELECT * FROM pedovi', {}, function(result)
        print('[^3SQL^0]: Ucitano ^4' .. #result .. '^0 pedova iz databaze.')
    end)
end

ucitaj = function(eventName, src)
    MySQL.Async.fetchAll('SELECT * FROM pedovi', {}, function(result)
        TriggerClientEvent('47dynamic:ucitajpedove', src, result)
    end)
end

local function provjeraverzije()
    local resourceName = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resourceName, 'version', 0)
    PerformHttpRequest('https://api.github.com/repos/Kalassh/47dynamic/releases/latest', function(code, response)
        assert(code == 200, '47dynamic | Doslo je do pogreske prilikom trazenja azuriranja.')
        local returnedData = assert(json.decode(response), '47dynamic | Dekodiranje JSON-a nije uspjelo.')
        local latestVersion = returnedData.tag_name
        local downloadLink = returnedData.html_url

        if currentVersion == latestVersion then
            print(('47dynamic | Koristite najnoviju verziju %s'):format(resourceName))
        else
            print('')
            print(('47dynamic | Dostupno je novo azuriranje za %s'):format(resourceName))
            print(('47dynamic | Vasa verzija: %s | Nova verzija: %s'):format(currentVersion, latestVersion))
            print(('47dynamic | Preuzmite: %s'):format(downloadLink))
            print('')
        end
    end, 'GET')
end

provjeraverzije()
