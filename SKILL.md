---
name: fivem-pro
description: All-in-one FiveM development skill: Lua resource conventions (client/server/NUI), QBCore framework patterns, ox ecosystem (ox_lib/oxmysql/ox_inventory/ox_target), NUI with React, FXServer deployment, live resource workflow, anticheat hardening + security auditing, and GTA V map/MLO creation with Sollumz + CodeWalker. Use when writing, reviewing, debugging, deploying, or securing FiveM resources, or when building custom maps.
license: MIT
metadata:
  author: 1MS Studio
  version: "1.0.0"
  tags: fivem, lua, qbcore, anticheat, mapping, fxserver
---

# FiveM Pro — All-in-One Development Skill

You are a senior FiveM (CitizenFX) developer. This skill covers the full lifecycle:
writing Lua resources, QBCore patterns, ox ecosystem, NUI, deployment, live
workflow, anticheat/security, and map creation. Read the relevant reference
file before doing substantial work in that domain:

- `references/lua.md` — FiveM Lua conventions (events, exports, threads, StateBags, natives)
- `references/qbcore.md` — QBCore patterns (Player object, callbacks, jobs, economy)
- `references/ox-ecosystem.md` — ox_lib, oxmysql, ox_inventory, ox_target
- `references/nui.md` — NUI development (vanilla + React), focus lifecycle
- `references/deployment.md` — FXServer deployment, server.cfg, txAdmin
- `references/workflow.md` — live resource workflow (minimal restarts)
- `references/security.md` — anticheat hardening + security audit checklist
- `references/maps-sollumz.md` — map/MLO creation with Sollumz + CodeWalker

## The Iron Rules (apply to every FiveM task)

1. **Client is never trusted.** Every `RegisterNetEvent` handler on the server
   must validate the payload AND derive the actor from `source` — never from a
   client-sent player ID. Money, items, rewards, and state changes are decided
   server-side only.
2. **One currency enum, not many booleans.** Reward functions take a single
   currency (`cash | bank | blackmoney | rcoin`). Multiple boolean flags cause
   double-payouts.
3. **No busy `while true` loops.** Every thread has a sensible `Wait()`.
   Tight loops without waits freeze the game thread.
4. **Explicit fxmanifest order.** `shared_scripts` → `client_scripts` →
   `server_scripts`, dependencies declared, `lua54 'yes'`.
5. **Capture caller before await.** In async server code, read `source` into a
   local at the top of the handler before any `Wait()`/await — `source` is
   not stable across yields.
6. **NUI focus has a lifecycle.** Every `SetNuiFocus(true, true)` needs a
   matching close path: ESC key, close button, resource stop, player logout.
   A stuck focus traps the player.
7. **Restart the resource, not the server.** `restart <resource>` for Lua/NUI
   changes. Full restarts only for ports, OneSync, server.cfg globals, or DB
   lifecycle. See `references/workflow.md`.
8. **Never hardcode secrets.** Tokens, webhook URLs, license keys go in
   `server.cfg`/environment, never in client files or git.

## Quick Triage

| Task | Read first |
|---|---|
| New/edited Lua resource | `references/lua.md` |
| Player data, jobs, money, callbacks | `references/qbcore.md` |
| Inventory, DB, dialogs, targeting | `references/ox-ecosystem.md` |
| HTML/JS overlay UI | `references/nui.md` |
| server.cfg, ports, txAdmin, go-live | `references/deployment.md` |
| "Fix it while server is running" | `references/workflow.md` |
| Exploit, cheater, event abuse, audit | `references/security.md` |
| Custom interior, MLO, props, ymap | `references/maps-sollumz.md` |

## Conventions

- **Lua style:** `snake_case` locals/functions, `PascalCase` for module tables,
  `UPPER_CASE` constants. One global table per resource (module-per-global),
  everything else `local`.
- **File layout:** `fxmanifest.lua`, `config.lua`, `locales/`, `client/`,
  `server/`, `shared/`, `html/`, `sql/`.
- **Locales:** all player-facing strings in locale files (vi/en minimum),
  never hardcoded in logic.
- **Config over code:** prices, durations, coordinates, toggles live in
  `config.lua`, not buried in handlers.
