ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local distance = Vdist2(pCoords, Config.KantorPajak.x, Config.KantorPajak.y, Config.KantorPajak.z)
        if distance < 125 then
            sleep = 5
            DrawMarker(2, Config.KantorPajak.x, Config.KantorPajak.y, Config.KantorPajak.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
            if distance < 2 then
                DrawText3D(Config.KantorPajak.x, Config.KantorPajak.y, Config.KantorPajak.z + 0.4, 'Tekan [E] Untuk Membuka Menu')
                if IsControlJustPressed(0, 38) then
                    PajakKontrol()
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

function PajakKontrol()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'pajak_kontrol',
        {
            title = ('Harap Masukkan Plate Kendaraan'),
        },
        function(data, menu)
            menu.close()
            --TriggerServerEvent('bir-pajak-kendaraan:returncar', data.value)
            ESX.TriggerServerCallback('bir-pajak-kendaraan:infokendaraan3', function(pajak)
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pajak_kontrol2',
                {
                    title    = 'Pajak Kendaraan Anda '..pajak..'$. Bayar Sekarang?',
                    align    = 'top-left',
                    elements = {
                        {label = 'Iya', value = 'iya'},
                        {label = 'Tidak', value = 'tidak'}
                    }
                },
                function(data2, menu2)
                    if data2.current.value == 'iya' then
                        menu2.close()
                        TriggerServerEvent('bir-pajak-kendaraan:returncar', data.value)
                    elseif data2.current.value == 'tidak' then
                        menu2.close()
                    end
                end,
                function(data2, menu2)
                    menu2.close()
                end)
            end, data.value)
        end,
        function(data, menu)
        menu.close()
    end)
end

RegisterCommand('pajak', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = GetVehicleNumberPlateText(vehicle)
    local name = GetEntityModel(vehicle)
    ESX.TriggerServerCallback('bir-pajak-kendaraan:infokendaraan2', function(pajak)
        ESX.ShowNotification('Pajak Kendaraan Saat Ini: '..pajak..'$')
    end, plate)
    ESX.TriggerServerCallback('bir-pajak-kendaraan:infokendaraan', function(pajak, sistempajak)
        ESX.ShowNotification('Pajak Kendaraan Harian: '..pajak..'$')
        ESX.ShowNotification('Batas Pajak Kendaraan: '..sistempajak..'$')
    end, name)
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(vector3(Config.KantorPajak.x, Config.KantorPajak.y, Config.KantorPajak.z))

    SetBlipSprite (blip, Config.Blip.sprite)
    SetBlipScale  (blip, Config.Blip.scale)
    SetBlipColour (blip, Config.Blip.colour)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Kantor Pajak')
    EndTextCommandSetBlipName(blip)
end)
