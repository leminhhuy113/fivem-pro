# ESX Framework Patterns

## Getting the shared object

```lua
-- server (preferred: export, no event race)
local ESX = exports['es_extended']:getSharedObject()

-- fallback for older builds: event-based
local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
while ESX == nil do Wait(50) end
```

- Always guard `ESX` before use on the server; on the client it is only
  available after `es_extended` has started. Never assume it exists inside
  `onResourceStart` handlers of your own resource.

## xPlayer object

```lua
-- server
local xPlayer = ESX.GetPlayerFromId(source)
if not xPlayer then return end

local identifier = xPlayer.identifier          -- char identifier (license/steam)
local cash       = xPlayer.getMoney()           -- cash on hand
local bank       = xPlayer.getAccountMoney('bank')
```

Money and accounts:

```lua
xPlayer.addMoney(500)                 -- cash
xPlayer.removeMoney(200)
xPlayer.addAccountMoney('bank', 1000) -- bank / black_money are accounts
xPlayer.removeAccountMoney('black_money', 250)
```

Inventory:

```lua
xPlayer.addInventoryItem('bread', 2)
xPlayer.removeInventoryItem('bread', 1)

local item = xPlayer.getInventoryItem('bread') -- { name, label, count, ... }
if item and item.count >= 1 then ... end
```

Job and loadout:

```lua
local job = xPlayer.job -- { name = 'police', label = 'Police', grade = 3,
                          --   grade_name = 'boss', grade_label = 'Boss' }
xPlayer.setJob('mechanic', 1)

for _, weapon in ipairs(xPlayer.loadout) do
    -- { name = 'WEAPON_PISTOL', ammo = 60, components = {...}, tintIndex = 0 }
end
```

## Server callbacks

```lua
-- server: register
ESX.RegisterServerCallback('my-resource:server:getData', function(src, cb)
    cb({ ok = true })
end)

-- client: consume (blocks until server responds; do not call every frame)
ESX.TriggerServerCallback('my-resource:server:getData', function(result)
    -- use result
end)
```

## esx_society basics

- Societies are registered boss-managed accounts: `esx_society:registerSociety('police', 'Police', 'society_police', 'society_police', 'society_police', {type = 'public'})`.
- Boss menu actions (hire/fire/promote, withdraw/deposit) go through
  `esx_society` server events — gate them on `xPlayer.job.grade_name == 'boss'`.
- Society money is NOT a player account: read/write via
  `TriggerEvent('esx_addonaccount:getSharedAccount', 'society_police', function(account) ... end)`.
- Never let the client name the society or amount — resolve both server-side
  from `xPlayer.job.name`.

## Items vs weapons

- Items live in `xPlayer.inventory` and go through
  `addInventoryItem` / `removeInventoryItem`.
- Weapons live in `xPlayer.loadout` and go through
  `xPlayer.addWeapon('WEAPON_PISTOL', 60)` / `xPlayer.removeWeapon(...)`.
- Usable items: `ESX.RegisterUsableItem('bandage', function(src) ... end)` —
  server-side only, `src` is the player who used it.

## ESX 1.x vs legacy notes

| | Legacy (1.1/1.2) | 1.x / 1.9+ |
|---|---|---|
| Shared object | event `esx:getSharedObject` only | `exports['es_extended']:getSharedObject()` |
| Jobs | `xPlayer.job.grade` (number) | `xPlayer.job.grade` (number) + `grade_name` |
| Weight system | limit-based (`item.limit`) | weight-based inventory by default |
| Callbacks | same API | same API |

- If a resource must support both, use the event fallback and feature-detect
  `xPlayer.job.grade_name`.
- ESX 1.9+ moved to oxmysql; raw `MySQL.*` calls from the old mysql-async
  wrapper will break — use `exports.oxmysql` / `MySQL.*` from oxmysql.

## Gotchas

- `ESX.GetPlayerFromId(source)` returns `nil` during early connection events
  (`playerConnecting`, first ticks after spawn) — always nil-check and use
  `xPlayer.source` (not the outer `source`) after any `Wait()`.
- `xPlayer.identifier` is the character identifier, not the license — do not
  use it as a ban key; use the license from `GetPlayerIdentifiers`.
- Money functions are synchronous wrappers around account state — calling
  `addMoney` twice in one tick from two resources is fine, but never trust a
  client-sent amount; compute prices server-side.
- `esx_society` boss menus historically trusted client input — re-validate
  grade and amounts on every boss action or employees can promote themselves.
- Do not modify `es_extended` core files to add features — extend through
  your own resources and exports, or upgrades will wipe your changes.
