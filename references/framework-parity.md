# Framework Parity — Secure Turn-in Pattern

This reference answers one question three ways: a client requests a job
turn-in; how does the server decide whether to pay? The client never sends a
payout, an item count, a player ID or a completion flag. Each implementation
tracks the activity server-side, checks the player is at the turn-in point,
rate-limits the request and calculates a fixed payout from server config.

Use the framework-native player API only after the common checks pass. The
snippets are teaching references, not copy/paste production resources: adapt
coordinates, job state and audit logging to the resource that owns the job.

## Shared server authority

```lua
local active_jobs = {}

local function near_turn_in(src)
    local ped = GetPlayerPed(src)
    if ped <= 0 then return false end
    return #(GetEntityCoords(ped) - Config.TurnIn.coords) <= Config.TurnIn.radius
end

local function consume_turn_in(src)
    local job = active_jobs[src]
    if not job or not near_turn_in(src) then return false end
    if os.time() - job.started_at < Config.MinimumDuration then return false end
    active_jobs[src] = nil -- consume before payout: duplicate calls lose
    return true
end

AddEventHandler('playerDropped', function()
    active_jobs[source] = nil
end)
```

The `start` event must apply the same proximity check and initialize
`active_jobs[src]` server-side. If a job collects items, increment a capped
server-side count from validated server ticks; never accept the count from the
client.

## QBCore

```lua
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('my-job:server:turnIn', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not consume_turn_in(src) then return end

    player.Functions.AddMoney('cash', Config.TurnIn.reward, 'my-job-turn-in')
    TriggerClientEvent('QBCore:Notify', src, 'Job complete.', 'success')
end)
```

## ESX

```lua
local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('my-job:server:turnIn', function()
    local src = source
    local x_player = ESX.GetPlayerFromId(src)
    if not x_player or not consume_turn_in(src) then return end

    x_player.addMoney(Config.TurnIn.reward)
    TriggerClientEvent('esx:showNotification', src, 'Job complete.')
end)
```

If the reward must go to bank or black money, choose that server configuration
explicitly and use the matching account API. Do not let a UI choose the account
or the amount.

## QBox + ox_inventory

```lua
RegisterNetEvent('my-job:server:turnIn', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not consume_turn_in(src) then return end

    player.Functions.AddMoney('cash', Config.TurnIn.reward, 'my-job-turn-in')
    exports.ox_inventory:AddItem(src, 'job_receipt', 1)
end)
```

For an item requirement, read and remove it with `ox_inventory` on the server
inside the same authoritative flow. Check `CanCarryItem` before adding rewards
and choose a clear recovery path when the inventory is full.

## Compatibility checklist

- [ ] `GetPlayer...` result is nil-checked.
- [ ] `source` is captured before any yielding work.
- [ ] Coordinates, minimum time, reward and currency live in server-owned config.
- [ ] The activity state is consumed before payout.
- [ ] Disconnect and resource-stop cleanup exists.
- [ ] Two clients and a repeated-event attempt were tested on staging.

Read the framework reference before using an implementation:
[QBCore](qbcore.md), [ESX](esx.md), [QBox](qbox.md), and
[ox ecosystem](ox-ecosystem.md).

