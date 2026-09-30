-- server/main.lua — the server decides, the client only requests.
local QBCore = exports['qb-core']:GetCoreObject()

local cooldowns = {} -- src -> timestamp of last claim (rate limit)

RegisterNetEvent('template:server:claimReward', function()
    -- Iron Rule 5: capture source before any yield
    local src = source

    -- Iron Rule 1: client is never trusted — derive actor from source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    -- Rate limit: one claim per Config.Reward.cooldownMinutes
    local now = os.time()
    local last = cooldowns[src] or 0
    if now - last < Config.Reward.cooldownMinutes * 60 then
        TriggerClientEvent('QBCore:Notify', src, 'Too soon. Come back later.', 'error')
        return
    end
    cooldowns[src] = now

    -- Iron Rule 2: one currency enum — amount comes from config, not the client
    Player.Functions.AddMoney(Config.Reward.currency, Config.Reward.amount, 'template-reward')

    TriggerClientEvent('QBCore:Notify', src, ('You received $%d'):format(Config.Reward.amount), 'success')
end)

-- Clean up cooldowns on drop so rejoins aren't stuck
AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)
