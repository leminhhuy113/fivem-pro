# Anticheat Hardening + Security Audit

## Part A — Harden your own resources

### Server-authoritative patterns
- **Position:** never trust client coords for rewards/teleports. Server keeps
  last-known position; reject jumps beyond speed × time + tolerance.
- **Distance checks:** action requires proximity — verify on server with
  entity coords, not client claims.
- **Rate limits:** cooldown table per `src` for every abusable event
  (give item, payout, heal, spawn).
- **Tokenized events:** for sensitive flows, issue a single-use server token
  per player; the event requires the current token.
- **Honeypot events:** register fake events only a cheater's executor would
  call (`admin:giveAll`, `debug:unlock`). Trigger = instant flag/ban.
- **Explosion/weapon guards:** filter `explosionEvent` / `weaponDamageEvent`
  server-side; strip blacklisted weapons (railgun, minigun, RPG) on a timer.
- **Heartbeat:** client answers a challenge every ~30s; silence = client
  unloaded the anticheat → ban.

### Config hygiene
- `sv_scriptHookAllowed 0`, `sv_endpointPrivacy true`.
- ACE permissions for admin actions (`add_ace group.admin ...`); never gate
  admin powers on a client-side check.
- Staff identifiers resolved server-side; never from client input.

## Part B — Audit a resource (own or third-party)

Work through this checklist; flag anything you can't verify:

1. **Backdoors / RATs:** search for `LoadResourceFile`+`load(` patterns,
   obfuscated chunks, `PerformHttpRequest` to unknown hosts, Discord webhooks
   exfiltrating data. Deobfuscate before judging.
2. **Event abuse:** list every `RegisterNetEvent`/`TriggerClientEvent`;
   confirm server handlers validate payload + derive actor from `source`.
3. **Money/item dupes:** trace every AddMoney/AddItem path — is there a
   single server-side authority? Any client-triggered payout without checks?
4. **SQL injection:** every query parameterized? Any string-concatenated
   query with player input?
5. **NUI vulnerabilities:** player-controlled strings rendered unsanitized?
   `RegisterNUICallback` handlers forwarding to server without validation?
6. **Crash vectors:** unbounded loops, huge payload allocations, recursive
   events, missing payload size/depth bounds.
7. **Secrets:** tokens, webhook URLs, license keys, DB passwords in files?
   They belong in `secrets.cfg`/env, never in git or client files.
8. **Escrow/compiled code:** you can't read it — treat as untrusted. Check
   what events it registers and what it exfiltrates via network monitoring
   before running on production.
9. **Supply chain:** `node_modules` / vendored JS in NUI — known-vulnerable
   versions? `npm audit` the NUI build deps.

## Verdict format

For each finding: **severity** (critical/high/medium/low), **location**
(file:line), **what's wrong**, **exploit scenario**, **fix**. End with an
overall risk rating and the top 3 fixes to ship first.

## Part C — Server-side detection patterns

Run these on a server thread; never rely on a client anticheat alone
(executors kill client scripts first).

### Speed / teleport detection
```lua
-- server thread every 5s: compare against last-known server-side coords
local lastPos = {}
CreateThread(function()
    while true do
        Wait(5000)
        for _, src in ipairs(GetPlayers()) do
            local ped = GetPlayerPed(src)
            local pos = GetEntityCoords(ped)
            local prev = lastPos[src]
            if prev then
                local dist = #(pos - prev)
                -- 5s at 60 m/s (fast car) + tolerance; adjust for your server
                if dist > 400.0 then
                    FlagPlayer(src, ('teleport/speed: %.0fm in 5s'):format(dist))
                end
            end
            lastPos[src] = pos
        end
    end
end)
```

### Godmode / health anomaly
```lua
-- damage the ped slightly server-side is impossible; instead watch stats
-- flag: health never drops after taking documented damage events,
-- or armor values impossible for the player's loadout
RegisterNetEvent('weaponDamageEvent', function(sender, data)
    -- sender is the ATTACKER here; validate victim damage separately
    if data.weaponDamage > 500 then
        FlagPlayer(sender, 'impossible damage value')
    end
end)
AddEventHandler('weaponDamageEvent', function(sender, data)
    CancelEvent() -- drop silently after logging, or let through + flag
end)
```
Note: `weaponDamageEvent`/`explosionEvent` are cancellable server events —
use them as tripwires, not as your only defense.

### Injection / executor detection
- **Resource count check:** client reports `GetNumResources()`; mismatch
  with the server's known count = injected resource. (Spoofable — use as
  one signal among many, never the sole ban reason.)
- **Blacklisted commands:** executors often register commands; scan
  `GetRegisteredCommands()` client-side and report anomalies.
- **Heartbeat challenge:** server sends a random token, client must echo it
  through a protected event within N seconds. No answer = client script
  unloaded → kick, investigate, then ban on repeat.

### Screenshot-basic flow
Request a screenshot on flag (not on every player — expensive). Review
before banning: a false positive ban costs you a player and your reputation.

## Part D — Exploit case studies (learn the shape)

### Case 1: The open payout event
```lua
-- VULNERABLE: client says "I finished the job, pay me"
RegisterNetEvent('jobs:server:finishJob', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', amount) -- amount is attacker-controlled!
end)
```
Exploit: executor calls the event with `amount = 999999999`.
Fix: server looks up the job state it tracked itself, pays a fixed table
value, rate-limits completions (one per N minutes per player).

### Case 2: Inventory dupe via race condition
Two rapid `inventory:server:moveItem` calls for the same stack; if the
server reads quantity, then both handlers deduct from the stale value,
the item duplicates. Fix: per-player mutex (a simple `busy[src]` flag),
or process inventory moves through a single queue.

### Case 3: NUI callback forwarding
```lua
-- VULNERABLE: NUI tells client JS "buy this", client forwards to server blind
RegisterNUICallback('buyItem', function(data, cb)
    TriggerServerEvent('shop:server:buy', data.itemId, data.price) -- price from UI!
    cb('ok')
end)
```
Exploit: modified NUI (or direct event call) sends `price = 1` for a
1,000,000 item. Fix: server ignores client-sent price entirely; looks up
the canonical price from its own shop config.

### The pattern
Every case is the same bug: **the client proposes, the server obeys.**
The fix is always: **the server decides, the client only requests.**
