# QBCore Framework Patterns

## Getting the core / player

```lua
-- server
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('my-resource:server:action', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
end)
```

- `Player.PlayerData` holds identity, charinfo, job, gang, money.
- Money: `Player.PlayerData.money.cash`, `.bank`, plus custom types
  (e.g. `.blackmoney`) — all persist in the `players.money` JSON column.
- Mutate money ONLY through `Player.Functions.AddMoney` /
  `RemoveMoney` / `SetMoney` — never raw SQL on the players table, or the
  in-RAM value desyncs.

## Callbacks (server → client request/response)

```lua
-- server: register
QBCore.Functions.CreateCallback('my-resource:server:getData', function(src, cb)
    cb({ ok = true })
end)

-- client: consume
QBCore.Functions.TriggerCallback('my-resource:server:getData', function(result)
    -- use result
end)
```

## Jobs, gangs, duty

- `Player.PlayerData.job.name`, `.grade.level`, `.onduty`.
- Gate actions on `Player.PlayerData.job.onduty` for police/EMS/etc.
- Use `QBCore.Functions.GetPlayersOnDuty('police')` for counts.

## Items and inventory

- With qs-inventory / ox_inventory: add/remove items ONLY through the
  inventory's server API (`AddItem`/`RemoveItem` exports). Never hand the
  client an item directly.
- Usable items: `QBCore.Functions.CreateUseableItem('item_name', function(src) ... end)`.

## Economy rules

- One currency enum per reward (`cash | bank | blackmoney | rcoin`).
- Server computes price, payout, and outcome. Client sends intent only.
- Audit money changes: log `src`, amount, reason, before/after to a
  money-log resource.

## Don't

- Don't modify `qb-core` internals to add features — extend via your own
  resource and exports.
- Don't call `GetCoreObject()` on the client every frame — cache it once.
- Don't trust `PlayerData` sent from client; always re-fetch server-side.
