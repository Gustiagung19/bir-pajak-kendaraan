ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('bir-pajak-kendaraan:pajak')
AddEventHandler('bir-pajak-kendaraan:pajak', function()

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE type = @type AND job = @job',
    {
        ['@type'] = 'car',
        ['@job'] = 'civ'
    },
    function(result)
        for i=1, #result, 1 do
            local xPlayer = ESX.GetPlayerFromIdentifier(result[i].owner)
            local data = json.decode(result[i].vehicle)
            local jumlahpajak = JumlahPajak(data.model)
            local sistemjumlah = DapatkanPajak(data.model)
            if jumlahpajak ~= nil and sistemjumlah ~= nil then
                if result[i].pajak >= sistemjumlah then
                    MySQL.Async.execute('INSERT INTO `pajak_kendaraan` (`owner`, `vehicle`, `type`, `job`, `plate`, `pajak`) VALUES(@owner, @vehicle, @type, @job, @plate, @pajak)',
                    {
                        ['@owner'] = result[i].owner,
                        ['@vehicle'] = result[i].vehicle,
                        ['@type'] = 'car',
                        ['@job'] = 'civ',
                        ['@plate'] = result[i].plate,
                        ['@pajak'] = result[i].pajak
                    })
                    Citizen.Wait(0)
                    MySQL.Async.execute('DELETE FROM owned_vehicles WHERE owner = @owner AND vehicle = @vehicle AND type = @type AND job = @job AND plate = @plate',
                    {
                        ['@owner'] = result[i].owner,
                        ['@vehicle'] = result[i].vehicle,
                        ['@type'] = 'car',
                        ['@job'] = 'civ',
                        ['@plate'] = result[i].plate
                    })
                    if xPlayer ~= nil then
                        xPlayer.showNotification('Kendaraan Anda Dengan Plate '..result[i].plate..' Disita Untuk Hutang Pajak, Anda Bisa Mendapatkan Kembali Kendaraan Anda Di Kantor Pajak.')
                    end
                else
                    MySQL.Async.execute('UPDATE owned_vehicles SET pajak = pajak + @pajak WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
                    {
                        ['@pajak'] = jumlahpajak,
                        ['@owner'] = result[i].owner,
                        ['@type'] = 'car',
                        ['@job'] = 'civ',
                        ['@plate'] = result[i].plate
                    })
                end
            end
        end
        print('^2[bir-pajak-kendaraan]^0 Pemotongan Pajak Berhasil')
    end)
end)

function JumlahPajak(jumlah)
    MySQL.Async.fetchAll('SELECT * FROM vehicles',
    {

    },
    function(result)
        for i = 1, #result, 1 do
            local model = GetHashKey(result[i].model)
            if model == jumlah then
                aracfiyat = (result[i].price / Config.BagianPerpajakan)
            end
        end
    end)
    Citizen.Wait(100)
    return aracfiyat
end

function DapatkanPajak(jumlah2)
    MySQL.Async.fetchAll('SELECT * FROM vehicles',
    {

    },
    function(result)
        for i = 1, #result, 1 do
            local model2 = GetHashKey(result[i].model)
            if model2 == jumlah2 then
                aracfiyat2 = (result[i].price / Config.BagianPajak)
            end
        end
    end)
    Citizen.Wait(100)
    return aracfiyat2
end

RegisterServerEvent('bir-pajak-kendaraan:returncar')
AddEventHandler('bir-pajak-kendaraan:returncar', function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = xPlayer.getMoney()

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
    {
        ['@owner'] = xPlayer.identifier,
        ['@type'] = 'car',
        ['@job'] = 'civ',
        ['@plate'] = plate
    },
    function(result)
        if result[1] then
            if result[1].pajak ~= 0 then
                if money >= result[1].pajak then
                    MySQL.Async.execute('UPDATE owned_vehicles SET pajak = @pajak WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
                    {
                        ['@pajak'] = 0,
                        ['@owner'] = xPlayer.identifier,
                        ['@type'] = 'car',
                        ['@job'] = 'civ',
                        ['@plate'] = plate
                    })
                    xPlayer.removeMoney(result[1].pajak)
                    xPlayer.showNotification('Anda Membayar '..result[1].pajak..'$ Pajak Kendaraan Dengan Plate '..plate..'.')
                else
                    xPlayer.showNotification('Anda Tidak Punya Cukup Uang Untuk Membayar '..result[1].pajak..'$ Pajak Kendaraan Dengan Plate '..plate..'.')
                end
            end
        else
            MySQL.Async.fetchAll('SELECT * FROM pajak_kendaraan WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
            {
                ['@owner'] = xPlayer.identifier,
                ['@type'] = 'car',
                ['@job'] = 'civ',
                ['@plate'] = plate
            },
            function(result)
                if result[1] then
                    if money >= result[1].pajak then
                        MySQL.Async.execute('INSERT INTO `owned_vehicles` (`owner`, `vehicle`, `type`, `job`, `plate`, `pajak`, `stored`) VALUES(@owner, @vehicle, @type, @job, @plate, @pajak, @stored)',
                        {
                            ['@owner'] = xPlayer.identifier,
                            ['@vehicle'] = result[1].vehicle,
                            ['@type'] = 'car',
                            ['@job'] = 'civ',
                            ['@plate'] = plate,
                            ['@pajak'] = 0,
                            ['@stored'] = 1
                        })
                        Citizen.Wait(0)
                        MySQL.Async.execute('DELETE FROM pajak_kendaraan WHERE owner = @owner AND vehicle = @vehicle AND type = @type AND job = @job AND plate = @plate',
                        {
                            ['@owner'] = xPlayer.identifier,
                            ['@vehicle'] = result[1].vehicle,
                            ['@type'] = 'car',
                            ['@job'] = 'civ',
                            ['@plate'] = plate
                        })
                        xPlayer.removeMoney(result[1].pajak)
                        xPlayer.showNotification('Anda Membayar '..result[1].pajak..'$ Pajak Kendaraan Dengan Plate '..plate..'. Kendaraan Anda Sudah Dikirim Kembali Ke Garasi Anda.')
                    else
                        xPlayer.showNotification('Anda Tidak Punya Cukup Uang Untuk Membayar '..result[1].pajak..'$ Pajak Kendaraan Dengan Plate '..plate..'.')
                    end
                else
                    xPlayer.showNotification('Harap Masukkan Plate Kendaraan Yang Valid!')
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback('bir-pajak-kendaraan:infokendaraan', function(source, cb, hash)
    local pajak = JumlahPajak(hash)
    local sistemjumlah = DapatkanPajak(hash)
    cb(pajak, sistemjumlah)
end)

ESX.RegisterServerCallback('bir-pajak-kendaraan:infokendaraan2', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
    {
        ['@owner'] = xPlayer.identifier,
        ['@type'] = 'car',
        ['@job'] = 'civ',
        ['@plate'] = plate
    },
    function(result)
        if result[1] then
            local pajak = result[1].pajak
            cb(pajak)
        else
            MySQL.Async.fetchAll('SELECT * FROM pajak_kendaraan WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
            {
                ['@owner'] = xPlayer.identifier,
                ['@type'] = 'car',
                ['@job'] = 'civ',
                ['@plate'] = plate
            },
            function(result)
                if result[1] then
                    local pajak = result[1].pajak
                    cb(pajak)
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback('bir-pajak-kendaraan:infokendaraan3', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
    {
        ['@owner'] = xPlayer.identifier,
        ['@type'] = 'car',
        ['@job'] = 'civ',
        ['@plate'] = plate
    },
    function(result)
        if result[1] then
            if result[1].pajak == 0 then
                xPlayer.showNotification('Kendaraan Anda Tidak Memiliki Pajak Yang Harus Dibayar.')
            else
                local pajak = result[1].pajak
                cb(pajak)
            end
        else
            MySQL.Async.fetchAll('SELECT * FROM pajak_kendaraan WHERE owner = @owner AND type = @type AND job = @job AND plate = @plate',
            {
                ['@owner'] = xPlayer.identifier,
                ['@type'] = 'car',
                ['@job'] = 'civ',
                ['@plate'] = plate
            },
            function(result)
                if result[1] then
                    local pajak = result[1].pajak
                    cb(pajak)
                else
                    xPlayer.showNotification('Harap Masukkan Plate Kendaraan Yang Valid!')
                end
            end)
        end
    end)
end)

PajakKontrol = function()
    TriggerEvent('bir-pajak-kendaraan:pajak')
end

TriggerEvent('cron:runAt', Config.Jam, Config.Menit, PajakKontrol)
