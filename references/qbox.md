# QBox Framework Patterns

## What QBox is

- QBox is a community-maintained fork of QBCore, rebuilt around the ox
  ecosystem (ox_lib, ox_inventory, ox_target, oxmysql) instead of QBCore's
  legacy modules.
- Resource prefix is `qbx_*` (`qbx_core`, `qbx_vehicles`, `qbx_garages`,
  `qbx_vehiclekeys`...). Framework-agnostic ox resources generally work
  unchanged; `qb-*` resources usually need porting.
- If you know QBCore, you know ~80% of QBox — the differences below are the
  20% that bites.

## Player object: key differences vs QBCore

```lua
-- server
local player = exports.qbx_core:GetPlayer(source)
if not player then return end

local citizenid = player.PlayerData.citizenid
```

| QBCore | QBox |
|---|---|
| `exports['qb-core']:GetCoreObject()` | `exports.qbx_core:GetPlayer(src)` / `GetPlayerByCitizenId(id)` |
| `Player.Functions.AddMoney('cash', n)` | `player.Functions.AddMoney('cash', n)` (same shape) |
| `QBCore.Functions.CreateCallback` | `lib.callback.register('my-res:server:cb', function(src) ... end)` (ox_lib) |
| `QBCore.Functions.TriggerCallback` (client) | `lib.callback.await('my-res:server:cb', false)` (client, ox_lib) |
| `qb-inventory` / `qs-inventory` | **ox_inventory** — items via `exports.ox_inventory:AddItem(src, ...)` |
| `qb-target` | **ox_target** — `exports.ox_target:addBoxZone(...)` |
| `qb-menu` / `qb-input` | **ox_lib** — `lib.registerContext`, `lib.inputDialog`, `lib.alertDialog` |

Money still lives at `player.PlayerData.money.cash` / `.bank`; mutate only
through `player.Functions.AddMoney/RemoveMoney/SetMoney`.

Callbacks, the QBox way:

```lua
-- server
lib.callback.register('my-resource:server:getData', function(src)
    return { ok = true }
end)

-- client (await blocks the coroutine, not the game thread)
local result = lib.callback.await('my-resource:server:getData', false)
```

## Character selection flow

- `qbx_core` owns spawn/character select: `qbx_core:client:playerLoggedIn`
  fires after a character is chosen. Do not run player-setup logic on
  `playerSpawned` — the character may not be selected yet.
- Multichar data persists through `qbx_core` server functions; new characters
  get default job/gang from `qbx_core` config, not from a separate
  `qb-multicharacter` resource.

## Vehicles, keys, garages

- `qbx_vehiclekeys`: keys are granted server-side —
  `exports.qbx_vehiclekeys:GiveKeys(src, plate)`. Never trust a client
  claiming ownership of a plate.
- `qbx_garages`: garage storage is server-authoritative; spawn requests must
  re-validate ownership and impound state server-side before creating the
  entity.
- Owned-vehicle data lives in the `player_vehicles` table (oxmysql) — query
  by `citizenid`, never by client-sent plate alone.

## Migration notes: QBCore → QBox

What breaks, in rough order of pain:

1. **Inventory** — every `AddItem`/`RemoveItem`/`GetItemByName` call must move
   to `exports.ox_inventory` equivalents; item metadata shape differs
   (ox uses `metadata` tables, not QBCore's `info`).
2. **Target/zones** — `qb-target` box zones become `ox_target` zones; option
   syntax differs (`onSelect` vs `action`).
3. **Menus/inputs** — `qb-menu` and `qb-input` calls become
   `lib.registerContext` / `lib.inputDialog`.
4. **Phone/dispatch** — `qb-phone` has no 1:1 QBox equivalent; most servers
   adopt a third-party phone or `qs-smartphone`.
5. **Callbacks** — mechanical swap to `lib.callback` (see table above).
6. **Jobs/gangs** — data shape is close; `player.PlayerData.job.name`,
   `.grade.level`, `.onduty` still apply, but duty toggling is QBox's own
   implementation.

Migration strategy: port leaf resources first (jobs, shops), keep a shim
resource exporting QBCore-style wrappers during transition, then delete the
shim. Never run `qb-core` and `qbx_core` simultaneously.

## When to choose QBox over QBCore

- New server, no legacy `qb-*` dependencies — QBox's ox-native stack is
  faster to develop on and better maintained.
- You want ox_inventory / ox_target as first-class citizens, not retrofits.
- You prefer upstream community maintenance over the QBCore org's pace.
- Stick with QBCore when: you already run a heavily customized QBCore base
  (custom inventory/phone/economy), or your paid resources are QBCore-locked.

## Gotchas

- `exports.qbx_core:GetPlayer(src)` returns `nil` before character selection
  completes — nil-check everywhere, and prefer the `playerLoggedIn` event
  over `playerSpawned` for setup logic.
- ox_inventory is authoritative: adding items via raw SQL or QBCore-style
  functions silently desyncs — always use `exports.ox_inventory` server
  functions.
- `lib.callback.await` on the client yields the current coroutine — calling
  it at the top level of a file (outside a thread/function) deadlocks.
- QBox has no built-in phone: budget for a phone resource decision early,
  because half your gameplay resources will want phone integration.
- Do not mix `qb-*` and `qbx_*` resources expecting shared state — job,
  money, and inventory data do not cross the framework boundary.
