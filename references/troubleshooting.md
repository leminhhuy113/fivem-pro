# FiveM Troubleshooting FAQ

Read the symptom, check the likely cause, apply the fix. When in doubt,
reproduce with F8 console open — most client errors print there first.

## Quick table

| Symptom | Likely cause | Fix |
|---|---|---|
| `hitch warning: frame time of X ms` in console | A resource blocks the game thread (tight loop, heavy native spam, giant DB result) | `resmon 1` in F8, find the ms hog, add `Wait()` / cache natives / batch queries |
| `No such export X in resource Y` | Export called before Y started, or typo in export/resource name | Add `Y` to `dependencies` in fxmanifest; check spelling on both sides |
| Server `RegisterNetEvent` handler never fires | Event name mismatch client↔server, or handler registered after `stop` | Compare the exact event string on both sides; check resource started without fxmanifest errors |
| Client event not received | `TriggerClientEvent` sent to wrong `src` (`-1` vs player id), or client file not loaded | Verify target id; confirm the client script is in `client_scripts` and the resource is started |
| NUI black screen | `ui_page` path wrong, missing file in `files {}`, or JS error on load | Check `ui_page` + `files` entries match real paths; open with `nui_devtools` / F8 for JS errors |
| NUI focus stuck — mouse trapped, can't ESC | No close path: missing ESC handler, close button, or `onResourceStop` cleanup | Add ESC/close-button handler calling `SetNuiFocus(false, false)`; also handle resource stop and player logout |
| oxmysql connection timeout on start | Wrong credentials/host in connection string, or MariaDB not listening | Verify the connection string in server.cfg; `systemctl status mariadb`; check firewall/port |
| `Could not find dependency X` on start | Dependency resource missing or misnamed in `[resources]` folder | Install/rename the dependency; ensure `ensure X` runs before dependents in server.cfg |
| fxmanifest parse errors | Lua syntax error (missing brace/comma) in fxmanifest | Open fxmanifest, check brackets around `shared_scripts`/`client_scripts` blocks; `lua54 'yes'` present |
| Players see old map / wrong game build | `sv_enforceGameBuild` not set or client on older build | Set `sv_enforceGameBuild 3095` (or current) in server.cfg; clients must update GTA V |
| txAdmin restart loop / server won't stay up | Crash in `server.cfg` (bad exec path), or a resource crashing on start | Check txAdmin console for the first error line; start with minimal cfg, `ensure` resources one by one |
| OneSync entity not syncing for some players | Entity outside their Infinity scope, or not server-owned | Confirm players are within scope range; create with server-side natives and `SetEntityAsMissionEntity` |
| oxmysql `Duplicate entry 'x' for key 'PRIMARY'` | Inserting a row that already exists (no upsert logic, double-fired event) | Use `INSERT ... ON DUPLICATE KEY UPDATE`, or check-then-insert; also fix the double-trigger (see security.md rate limits) |
| `SCRIPT ERROR` referencing nil value | Variable used before assignment, or framework not loaded yet | Trace the line number in F8/server console; guard with `if x then`; wait for framework export on start |
| Resource works alone, breaks with others | Global name collision (two resources defining same global) | Module-per-global pattern: one global table per resource, everything else `local` |

## General method

1. **Read the first error, not the last.** Cascading errors hide the root cause.
2. **F8 console** for client, **txAdmin/server console** for server — know which side failed.
3. **`restart <resource>`** after each fix; don't nuke the whole server to test one change.
4. **Bisect:** disable half the resources, re-test, repeat — fastest way to find conflicts.
5. **Check the artifact:** outdated FXServer builds cause natives to misbehave; pin a supported build (see `deployment.md`).
