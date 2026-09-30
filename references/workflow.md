# Live Resource Workflow

Core rule: when FXServer is already running, prefer the smallest reload that
applies the change. Full restarts are the last resort.

## Reload matrix

| Changed | Command |
|---|---|
| Lua client/server in existing resource | `restart <resource>` |
| NUI HTML/CSS/JS | `restart <resource>` (player may need reconnect if CEF caches) |
| `fxmanifest.lua` (existing resource) | `restart <resource>` |
| New/renamed resource folder | `refresh`, then `ensure <resource>` |
| `server.cfg` globals, ports, OneSync, license key | full service restart |
| DB container lifecycle | full service restart |

## Before editing

1. Identify the owning resource from the file path.
2. Check whether the server is running (local dev vs production).
3. Tell the user which resource will need a reload.

## After deploying

1. Watch the server console for script errors.
2. Check dependents: did the restart stop anything that depends on it?
   Restart dependents in dependency order if needed.
3. Verify the actual in-game behavior, not just "no errors in console".

## NUI cache-busting

If NUI changes don't appear after restart, the CEF cache is stale:
- bump a query string on assets, or
- have the player clear cache / reconnect.

Never restart the whole service just to bust NUI cache.
