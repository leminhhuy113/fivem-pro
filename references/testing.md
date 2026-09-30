# Testing FiveM Resources

Untested code is broken code. Test in the cheapest environment that can catch
the bug — never debug on production players.

## Environment discipline

| Environment | Purpose | Rules |
|---|---|---|
| Local dev server | Fast iteration, break things freely | Separate DB copy, `sv_lan` or passworded, debug prints ON |
| Staging (mirror of prod) | Pre-release validation | Same artifacts, same `server.cfg`, anonymized DB copy, debug prints OFF |
| Production | Players | Never test here. Only deploy what passed staging |

Never point dev/staging at the production database. One wrong `DELETE` and
the rollback is a restore, not a restart.

## Debug print toggles

Debug output behind a convar — never ship `print()` spam to production:

```lua
-- shared/debug.lua
local DEBUG = GetConvar('myres:debug', 'false') == 'true'

function dprint(...)
    if DEBUG then
        print(('[^3%s^7]'):format(GetCurrentResourceName()), ...)
    end
end
```

```cfg
# server.cfg (dev only)
set myres:debug true
```

`dprint()` is free when the convar is off. Leave the calls in the code;
toggle via cfg.

## Reading logs

- **Client:** F8 console. Filter by resource name. Repro client-side bugs here
  first — NUI errors, native failures, and missing assets show up here, not
  in the server console.
- **Server:** txAdmin console or `txAdmin` → Live Console. Watch for
  `SCRIPT ERROR` on every restart, and for hitch warnings (`hitch warning:
  frame time of Xms`) which signal a thread doing too much work.
- **txAdmin restarts:** use `restart <resource>` from the txAdmin console so
  the restart is logged with a timestamp and actor.

## Pre-deploy checklist

Run every row before a resource touches staging. Mark N/A only with a reason.

| # | Check | How |
|---|---|---|
| 1 | Fresh character flow | New character, walk the full onboarding path end to end |
| 2 | Money add/remove | Each currency type (`cash`, `bank`, `blackmoney`): add, remove, overdraw attempt |
| 3 | Job duty on/off | Clock in, use every job action, clock out mid-action |
| 4 | Inventory edges | Full inventory, overweight attempt, item use while dead, item use in vehicle |
| 5 | Restart mid-session | `restart <resource>` while players are using it — no stuck states, no dupes |
| 6 | NUI open/close 10x | Open and close the UI ten times fast — focus must release every time, no ESC trap |
| 7 | Disconnect/reconnect | Quit mid-transaction, reconnect — state is sane, no ghost entries |
| 8 | Death/respawn | Die during every timed/progress action — cleanup runs, no leaked threads |
| 9 | Multi-client sync | 2+ clients: one triggers, the other sees it (StateBags, events, target zones) |
| 10 | Permission edges | Run every action as a player WITHOUT the required job/grade — all denied server-side |

Checks 9 and 10 are where most "works on my machine" bugs live. Sync bugs
and missing server-side permission checks only appear with a second client
and a hostile mindset.

## Regression checklist (on every update)

- [ ] Previously fixed bugs still fixed (keep a list per resource).
- [ ] Dependents still load: restart dependents in dependency order after changes.
- [ ] `resmon` before/after: client ms did not regress.
- [ ] No new `SCRIPT ERROR` in server console after 10 minutes idle.
- [ ] Locales complete (vi/en) — no raw English strings leaking into UI.

## Boot-time self-check

Every resource validates its own prerequisites on start. Catch config/DB
mistakes in the console, not in a player's bug report:

```lua
-- server/main.lua (top)
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    assert(Config.Price > 0, 'Config.Price must be positive')
    assert(Config.Job, 'Config.Job is not set')
    print(('[^2%s^7] started OK'):format(res))
end)
```

A failed `assert` prints the exact problem and stops the resource before it
can corrupt state.

## Definition of done

A resource is done when ALL of these hold:

1. Pre-deploy checklist passes on staging, not just dev.
2. Zero `SCRIPT ERROR`s in a 30-minute idle soak on staging.
3. `resmon` idle ≤ 0.05ms client-side (or documented why not).
4. Every net event validates payload + derives actor from `source`
   (see `references/security.md`).
5. README documents: install steps, config options, dependencies, commands.
6. Rollback plan exists: which version to revert to, which DB backup covers it.
