# ox Ecosystem: ox_lib, oxmysql, ox_inventory, ox_target

## ox_lib

```lua
-- init via shared_script '@ox_lib/init.lua' gives you global `lib`

-- notifications / text UI
lib.notify({ title = 'Title', description = '...', type = 'success' })
lib.showTextUI('[E] Do thing'); lib.hideTextUI()

-- dialogs / menus
local input = lib.inputDialog('Title', { 'Field 1', { type = 'number', label = 'Amount' } })
lib.registerContext({ id = 'menu', title = 'Menu', options = { ... } })
lib.showContext('menu')

-- progress (replaces qb progressbar)
lib.progressBar({ duration = 5000, label = 'Working...', useWhileDead = false,
    canCancel = true, disable = { move = true, car = true, combat = true } })

-- callbacks (promise-style, preferred over QBCore callbacks in ox stacks)
lib.callback.register('my:server:cb', function(src) return data end)
local result = lib.callback.await('my:server:cb', false)

-- zones
lib.zones.box({ coords = vec3(x, y, z), size = vec3(2, 2, 2), onEnter = ..., onExit = ... })
```

## oxmysql

```lua
-- server (via '@oxmysql/lib/MySQL.lua')
local rows = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', { cid })
MySQL.insert.await('INSERT INTO logs (src, action) VALUES (?, ?)', { src, 'action' })
MySQL.update.await('UPDATE ...')
MySQL.scalar.await('SELECT COUNT(*) FROM ...')
```

- Always parameterize (`?` placeholders). String-concatenated SQL is an
  injection hole.
- `await` variants inside server threads; callback variants otherwise.
- Don't bypass framework money/inventory functions with direct SQL.

## ox_inventory

```lua
-- server-side only
exports.ox_inventory:AddItem(src, 'bread', 2)
exports.ox_inventory:RemoveItem(src, 'bread', 1)
exports.ox_inventory:GetItemCount(src, 'bread')
exports.ox_inventory:CanCarryItem(src, 'bread', 2)
```

- All mutations server-side. Client never calls these directly.
- Register usable items / crafting through inventory config, not ad-hoc events.

## ox_target

```lua
exports.ox_target:addBoxZone({
    coords = vec3(x, y, z), size = vec3(2, 2, 2),
    options = {
        { label = 'Do thing', icon = 'fa-solid fa-box',
          onSelect = function() TriggerServerEvent('my:server:thing') end,
          canInteract = function() return not Busy end },
    }
})
```

- `onSelect` fires client-side → forward to a validated server event.
- Use `canInteract` for distance/job/item gating instead of trusting UI state.
