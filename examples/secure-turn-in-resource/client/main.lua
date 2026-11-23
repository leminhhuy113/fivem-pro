local job_requested = false

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

RegisterNetEvent('secure-turn-in:client:notify', function(message)
    notify(message)
end)

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local distance = #(GetEntityCoords(ped) - Config.TurnIn.coords)

        if distance <= Config.TurnIn.radius then
            wait = 0
            DrawMarker(1, Config.TurnIn.coords.x, Config.TurnIn.coords.y, Config.TurnIn.coords.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 190, 230, 60, 150,
                false, false, 2, false, nil, nil, false)

            if IsControlJustReleased(0, 38) then
                if job_requested then
                    TriggerServerEvent('secure-turn-in:server:turn_in')
                else
                    TriggerServerEvent('secure-turn-in:server:start')
                    job_requested = true
                end
            end
        end

        Wait(wait)
    end
end)

RegisterNetEvent('secure-turn-in:client:reset', function()
    job_requested = false
end)
