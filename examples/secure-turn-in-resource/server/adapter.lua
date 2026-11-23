local Adapter = {}
local framework_name = Config.Framework

local function resource_started(resource)
    return GetResourceState(resource) == 'started'
end

if framework_name == 'auto' then
    if resource_started('qbx_core') then
        framework_name = 'qbox'
    elseif resource_started('qb-core') then
        framework_name = 'qbcore'
    elseif resource_started('es_extended') then
        framework_name = 'esx'
    else
        error('secure-turn-in could not detect qbx_core, qb-core or es_extended')
    end
end

if framework_name == 'qbcore' then
    local qb_core = exports['qb-core']:GetCoreObject()

    function Adapter.get_player(src)
        return qb_core.Functions.GetPlayer(src)
    end

    function Adapter.add_money(player, amount, reason)
        return player.Functions.AddMoney(Config.TurnIn.currency, amount, reason)
    end
elseif framework_name == 'esx' then
    local esx = exports['es_extended']:getSharedObject()

    function Adapter.get_player(src)
        return esx.GetPlayerFromId(src)
    end

    function Adapter.add_money(player, amount)
        if Config.TurnIn.currency == 'cash' then
            player.addMoney(amount)
            return true
        end

        player.addAccountMoney(Config.TurnIn.currency, amount)
        return true
    end
elseif framework_name == 'qbox' then
    function Adapter.get_player(src)
        return exports.qbx_core:GetPlayer(src)
    end

    function Adapter.add_money(player, amount, reason)
        return player.Functions.AddMoney(Config.TurnIn.currency, amount, reason)
    end
else
    error(('secure-turn-in received unsupported framework "%s"'):format(framework_name))
end

Adapter.name = framework_name
return Adapter
