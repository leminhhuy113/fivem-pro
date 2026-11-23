local Adapter = require('server.adapter')
local active_jobs = {}

local function notify(src, message)
    TriggerClientEvent('secure-turn-in:client:notify', src, message)
end

local function near_turn_in(src)
    local ped = GetPlayerPed(src)
    if ped <= 0 then
        return false
    end

    return #(GetEntityCoords(ped) - Config.TurnIn.coords) <= Config.TurnIn.radius
end

RegisterNetEvent('secure-turn-in:server:start', function()
    local src = source
    if not Adapter.get_player(src) or not near_turn_in(src) then
        return
    end
    if active_jobs[src] then
        notify(src, 'You already have an active job.')
        return
    end

    active_jobs[src] = { started_at = os.time() }
    notify(src, 'Job started. Return here after the timer.')
end)

RegisterNetEvent('secure-turn-in:server:turn_in', function()
    local src = source
    local player = Adapter.get_player(src)
    local job = active_jobs[src]
    if not player or not job or not near_turn_in(src) then
        return
    end

    if os.time() - job.started_at < Config.TurnIn.minimumDurationSeconds then
        notify(src, 'The job is not complete yet.')
        return
    end

    active_jobs[src] = nil -- consume before payout: repeat events cannot pay twice
    local paid = Adapter.add_money(player, Config.TurnIn.reward, 'secure-turn-in')
    if not paid then
        notify(src, 'Payout failed. Contact staff.')
        return
    end

    notify(src, ('You received $%d.'):format(Config.TurnIn.reward))
    TriggerClientEvent('secure-turn-in:client:reset', src)
end)

AddEventHandler('playerDropped', function()
    active_jobs[source] = nil
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        print(('[secure-turn-in] started with %s adapter'):format(Adapter.name))
    end
end)
