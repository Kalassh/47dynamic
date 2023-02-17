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

RegisterServerEvent('47dynamic:ucitajpedove')
AddEventHandler('47dynamic:ucitajpedove', function()
    MySQL.Async.fetchAll('SELECT * FROM pedovi', {}, function(result)
        TriggerClientEvent('47dynamic:ucitajpedove', -1, result)
        print('[^3SQL^0]: Ucitano ^4' .. #result .. '^0 pedova iz databaze.')
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerEvent('47dynamic:ucitajpedove')
end)


