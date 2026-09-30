# NUI Development (FiveM CEF)

## Manifest wiring

```lua
-- fxmanifest.lua
ui_page 'html/index.html'
files { 'html/index.html', 'html/style.css', 'html/app.js' }
```

## Message flow

```lua
-- client.lua: push data to UI
SendNUIMessage({ action = 'open', title = 'Shop', items = items })
SetNuiFocus(true, true)

-- client.lua: receive from UI
RegisterNUICallback('buy', function(data, cb)
    -- validate, then forward to server event
    TriggerServerEvent('my-resource:server:buy', data.itemId)
    cb('ok')
end)

-- html/app.js
window.addEventListener('message', (e) => {
    if (e.data.action === 'open') render(e.data);
});
fetch(`https://${GetParentResourceName()}/buy`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({ itemId })
});
```

## Focus lifecycle — no stuck focus, ever

Every open path needs ALL of these close paths:
1. Close button / action in UI → `SetNuiFocus(false, false)`
2. ESC key: NUI `keyup Escape` → callback → close
3. Resource stop: `AddEventHandler('onResourceStop', ...)` → close + focus off
4. Player logout / character switch → close + focus off

```lua
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'close' })
    end
end)
```

## React NUI (Vite)

- Build with Vite to `html/`; `base: './'` for relative asset paths.
- Keep the bundle small — CEF is not desktop Chrome; avoid heavy deps.
- Bridge pattern: a tiny `client/nui.lua` owns ALL `SendNUIMessage` /
  `RegisterNUICallback` calls; game logic never touches NUI directly.
- Dev loop: `vite dev` in browser for layout, then `vite build` +
  `restart <resource>` for in-game verification. Always verify in-game —
  desktop browser lies about CEF quirks (fonts, focus, performance).

## Gotchas

- Bundle fonts locally and declare them in fxmanifest `files`; test
  Vietnamese diacritics IN-GAME, not just in the desktop browser.
- `fetch` to `https://<resource>/callback` — never hardcode the resource name,
  use `GetParentResourceName()`.
- Sanitize any player-controlled strings rendered into the DOM (XSS via
  player names is real).
- Keep NUI state in one place; re-render from `message` events rather than
  scattering DOM mutations.
