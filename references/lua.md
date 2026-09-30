# FiveM Lua Conventions

## fxmanifest.lua — explicit and ordered

```lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'my-resource'
author '1MS Studio'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
    'client/modules/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/modules/*.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

dependencies {
    'ox_lib',
    'oxmysql',
}
```

Rules: shared → client → server, always. Declare every dependency you
actually use. `lua54 'yes'` is mandatory for modern resources.

## Events — the trust boundary

```lua
-- SERVER: validate payload + derive actor from `source`
RegisterNetEvent('my-resource:server:doAction', function(data)
    local src = source                      -- capture BEFORE any await
    local player = GetPlayer(src)            -- framework lookup by src
    if not player then return end

    if type(data) ~= 'table' then return end
    local amount = tonumber(data.amount)
    if not amount or amount < 1 or amount > 100 then return end  -- bounds

    -- rate limit per player here
    DoServerAuthoritativeThing(player, amount)
end)
```

- Never trust a client-sent player ID, identifier, or balance.
- Bounds-check every number; type-check every field.
- Rate-limit repeatable events per player (cooldown table keyed by `src`).
- Idempotency: give each transaction a unique ID; reject replays.

## Threads — no busy loops

```lua
CreateThread(function()
    while true do
        Wait(1000)  -- ALWAYS wait; tune the interval to the need
        -- periodic work here
    end
end)
```

- Proximity checks: `Wait(500)`+ and early-out by distance.
- One thread per concern; kill threads on resource stop.

## StateBags — replicated state done right

```lua
-- server sets, clients read; no event spam
Player(src).state:set('myFlag', true, true)          -- replicated
AddStateBagChangeHandler('myFlag', nil, function(bag, _, value)
    local entity = GetEntityFromStateBagName(bag)
    -- react
end)
```

## Natives — look them up, don't guess

- Native names and signatures change between FXServer artifacts. Verify at
  https://docs.fivem.net/natives/ instead of recalling from memory.
- Prefer state bags / framework functions over raw native spam in loops.

## Exports — the public API

```lua
-- server-side export other resources consume
exports('GetBalance', function(src)
    return Balances[src] or 0
end)
```

Keep exports small, documented, and server-authoritative. Consumers get
data; they never mutate state through an export without server validation.

## Module-per-global pattern

```lua
-- shared/utils.lua
local Utils = {}
function Utils.Clamp(n, min, max) return math.max(min, math.min(max, n)) end
return Utils

-- usage: local Utils = require 'shared.utils'  (or via shared_script load order)
```

One table per file, returned or assigned once. No sprawling globals.
