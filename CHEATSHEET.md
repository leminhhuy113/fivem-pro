# fivem-pro Cheat Sheet

## The Iron Rules (never break these)
1. Client is never trusted — validate server-side, actor from `source`
2. One currency enum (`cash|bank|blackmoney`), never boolean flags
3. No busy `while true` — every thread has `Wait()`
4. Explicit fxmanifest order: shared → client → server, `lua54 'yes'`
5. Capture `source` into a local before any yield
6. NUI focus needs a close path: ESC, button, resource stop, logout
7. Restart the resource, not the server
8. Secrets in server.cfg/env, never in client files or git

## Lua essentials
```lua
local src = source -- capture FIRST
RegisterNetEvent('res:server:do', function(payload)
    -- validate payload, derive actor from src
end)
CreateThread(function() while true do Wait(1000) --[[ work ]] end end)
exports['other']:SomeExport(args)
local val = lib.callback.await('res:cb', false, args) -- ox_lib
```

## QBCore
```lua
local Player = QBCore.Functions.GetPlayer(src)
Player.PlayerData.citizenid / .job / .money
Player.Functions.AddMoney('cash', 100, 'reason')
Player.Functions.AddItem('bread', 1)
QBCore.Functions.CreateCallback('res:cb', function(src, cb) cb(result) end)
```

## ESX
```lua
local xPlayer = ESX.GetPlayerFromId(src)
xPlayer.getMoney() / .addMoney(n) / .removeMoney(n)
xPlayer.addInventoryItem('bread', 1)
xPlayer.job.name / xPlayer.job.grade
ESX.RegisterServerCallback('res:cb', function(src, cb) cb(result) end)
```

## QBox
- Community QBCore fork, ox-native (ox_lib/ox_inventory built in)
- Migrating: inventory/phone/dispatch exports differ — check `qbox.md`

## ox ecosystem
```lua
MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {cid})
MySQL.insert.await('INSERT INTO t (a) VALUES (?)', {v})
exports.ox_inventory:AddItem(src, 'bread', 1)
exports.ox_target:addBoxZone({coords=vec3(0,0,0), size=vec3(2,2,2), options={...}})
lib.notify(src, {title='Hi', type='success'})
```

## NUI
- `SetNuiFocus(true, true)` + `SendNUIMessage({action='open'})`
- `RegisterNUICallback('name', function(data, cb) cb('ok') end)`
- JS: `fetch('https://' + GetParentResourceName() + '/name', {...})`
- CEF: transparent root, avoid `box-shadow` (use `drop-shadow`), no `transform: scale` for zoom

## Security checklist
- [ ] Every server event validates payload + uses `source`
- [ ] Money/items decided server-side, never from client numbers
- [ ] Rate limits on abusable events
- [ ] Distance/position checks server-side
- [ ] No secrets in repo or client files
- [ ] NUI callbacks don't forward client prices/amounts

## Performance checklist
- [ ] `resmon 1` — every resource under budget
- [ ] No per-frame expensive natives without caching
- [ ] Distance-gated threads with adaptive `Wait()`
- [ ] StateBags over chatty events where possible
- [ ] DB queries batched, indexed

## Debugging
- F8 console (client), server console / txAdmin (server)
- `resmon 1` — resource time; hitch warnings = long frame
- "No such export" → dependency not started / wrong name
- Event not firing → check resource name, event name spelling, client/server side

## Deploy
- Artifacts: pin a supported build, `sv_enforceGameBuild`
- `ensure` order in server.cfg matters
- txAdmin for restarts/schedules; full restart only for ports/OneSync/cfg
