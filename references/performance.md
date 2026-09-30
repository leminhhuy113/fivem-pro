# FiveM Performance Optimization

## resmon — measure first

Open the F8 console, type `resmon 1`. Every resource gets a live ms value.
Rules of thumb:

- **< 0.05ms** — fine.
- **0.05–0.15ms** — watch it on low-end PCs.
- **> 0.15ms** — fix now; multiply by 200 players and it hurts everyone.

`resmon 0` to hide. The game thread budget is roughly **8ms per tick** —
the client must run all resources plus rendering inside it. Anything that
spikes over budget causes visible hitches.

## Threads — tune the Wait()

The #1 perf killer is a tight loop. Scale the interval to the need:

```lua
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if #(pos - Config.Zone) < 100.0 then
            wait = 250          -- closer: check more often
            -- do proximity work here
        end
        Wait(wait)              -- adaptive: idle is cheap, near is precise
    end
end)
```

- Distance checks run **before** any expensive work; early-out first.
- One thread per concern; kill threads on `onResourceStop`.

## Cache expensive natives

`GetPlayerPed(-1)` / `PlayerPedId()` and `GetEntityCoords()` cost more
than you think when called every frame. The classic anti-pattern:

```lua
-- BAD: three native calls per frame, per loop
CreateThread(function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1))  -- don't do this
    end
end)

-- GOOD: cache once per tick, reuse
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        -- reuse `ped` and `pos` for all checks this tick
    end
end)
```

Prefer `Wait(0)` only when you genuinely need per-frame work (drawing
markers, prompts). Everything else waits longer.

## StateBags over chatty events

`TriggerServerEvent` / `TriggerClientEvent` in a loop is network spam.
For state that many clients read (door locks, job blips, statuses), set
a StateBag once and let clients react to changes:

```lua
-- server: set once, replicated to everyone in scope
Entity(ent).state:set('locked', true, true)

-- client: react on change, no polling loop needed
AddStateBagChangeHandler('locked', nil, function(bag, _, value)
    -- update local representation
end)
```

## OneSync Infinity — entities outside scope don't exist

With OneSync Infinity, the server only syncs entities near each player
(~500m by default). Consequences:

- A client **cannot see or interact** with distant entities — don't write
  logic assuming global entity visibility.
- Server-side entity loops must iterate `GetAllPeds()`/`GetAllVehicles()`
  on the server (which sees everything), not trust client reports.
- Population far away is culled; your "persistent NPC" needs a
  server-owned respawn model, not a single client-owned ped.

## Entity lifecycle — clean up what you spawn

```lua
local ent = CreateVehicle(model, x, y, z, heading, true, false)
SetEntityAsMissionEntity(ent, true, true)   -- server can manage/delete it
-- ...later:
DeleteEntity(ent)
```

- Always `SetEntityAsMissionEntity` for server-spawned entities, or they
  may never despawn and leak into the entity pool.
- Track spawned entities in a table; delete them on resource stop and
  on player disconnect (for player-scoped spawns).

## Streaming / LOD basics (maps)

- Keep custom prop draw distances sane; huge `streamingRange` on many
  props = texture/VRAM pressure for everyone nearby.
- Use LODs for large custom assets; a 4K texture on a distant rooftop
  is pure waste.
- Fewer, larger ymaps beat dozens of tiny ones (less streaming churn).

## Batch oxmysql queries

```lua
-- BAD: one query per row in a loop
for _, id in ipairs(ids) do
    MySQL.scalar.await('SELECT money FROM users WHERE id = ?', { id })
end

-- GOOD: single query
local rows = MySQL.query.await(
    'SELECT id, money FROM users WHERE id IN (?)', { ids }
)
```

- One `IN (...)` query beats N round-trips. Same for inserts:
  `MySQL.prepare` with multi-row `VALUES` or a transaction.
- Never query the DB inside a per-frame or per-second client thread —
  cache on the server, push via StateBag/export.

## NUI perf

- Don't `SendNUIMessage` every frame; throttle to state changes
  (10–15Hz max for live data like speedometers).
- In React: memoize lists, avoid re-rendering the whole tree on each
  tick. In vanilla JS: update text nodes, don't rebuild innerHTML.
- Use CSS `contain: layout paint` on animated panels to limit repaint.

## Perf checklist

| Check | Target |
|---|---|
| `resmon 1` on every resource | < 0.05ms idle, < 0.15ms active |
| Every `while true` has `Wait()` | no `Wait(0)` unless per-frame |
| Native calls cached per tick | no repeated `GetPlayerPed(-1)` |
| Distance early-out before work | check range first, work second |
| Events replaced by StateBags where polled | set once, react on change |
| Spawned entities tracked + deleted | no leaks on stop/disconnect |
| DB queries batched | no query-per-row loops |
| NUI messages throttled | state changes only, not per-frame |
| Map props have sane streaming ranges + LODs | no 4K textures at distance |
