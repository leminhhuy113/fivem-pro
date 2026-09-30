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
