# FiveM Platform Guidance — 2026

This reference records platform-level decisions that affect every resource.
It complements framework-specific guidance; it does not replace testing on the
FXServer artifact and game build you operate.

## Lua and resource manifests

FiveM uses CfxLua, a modified Lua 5.4 runtime. Since June 2025, the old Lua
5.3 runtime is deprecated and Lua 5.4 is the default. Do **not** add
`lua54 'yes'` to a new `fxmanifest.lua`; the manifest directive itself is
deprecated.

Keep the manifest explicit and minimal:

```lua
fx_version 'cerulean'
game 'gta5'

shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { 'server/main.lua' }
```

When a resource uses server-side JavaScript, select `node_version '22'`
deliberately and test its dependencies; otherwise do not add it merely because
it is available.

Source: [Cfx resource manifest](https://docs.fivem.net/docs/scripting-reference/resource-manifest/)
and [Lua runtime](https://docs.fivem.net/docs/scripting-manual/runtimes/lua/).

## OneSync: design for scope, not global client visibility

OneSync makes the server aware of synchronized entities, but clients only see
entities in their focus zone. Never implement global player iteration or
server-authoritative validation by scanning client entities. Iterate players
server-side and send only the client updates that are needed.

- Prefer server-created persistent entities when the server owns their
  lifecycle. Use `SetEntityOrphanMode(entity, 2)` where persistence is needed.
- Use a routing bucket for isolated sessions, character selection, or game
  modes — **not** as an interior-instancing shortcut.
- If a bucket is intended to reject client-created entities, use `strict`
  entity lockdown and disable bucket population only after validating the
  gameplay impact.
- Do not rely on deprecated culling-radius natives to make a feature correct.

Source: [Cfx OneSync documentation](https://docs.fivem.net/docs/scripting-reference/onesync/).

## State Bags: flat keys, clear authority

State bag reads and writes are shallow: a read retrieves the serialized state,
and only a direct key assignment serializes a write. Avoid nested mutable
tables and use flat namespaced keys such as `job:active` or `vehicle:fuel`.

```lua
-- server: authoritative, replicated state
Player(src).state:set('job:active', true, true)

-- server-only bookkeeping: do not replicate
Player(src).state:set('job:last_payout', os.time(), false)
```

The server can always write state; a player may normally write its own player
state and an entity owner may write that entity state. For a resource that
does not depend on client-authored state, evaluate this server configuration in
staging:

```cfg
set sv_stateBagStrictMode true
```

It is a compatibility-affecting change, not a blind security toggle. Client
state is a hint, never proof for rewards, permissions, inventory or money.

Source: [Cfx State Bags](https://docs.fivem.net/docs/scripting-manual/networking/state-bags/).

## IDs and cross-machine references

An entity handle is local to a runtime and can change when an entity is
recreated. A network ID is the cross-machine reference, but it can be reused
after an entity is gone and may be out of client scope. Pass network IDs across
the boundary, then confirm existence before resolving and acting on them.

```lua
-- client
if NetworkDoesEntityExistWithNetworkId(net_id) then
    local vehicle = NetToVeh(net_id)
    -- still validate type and resource ownership before using it
end
```

Source: [Cfx network and local IDs](https://docs.fivem.net/docs/scripting-manual/networking/ids/).

## Security baseline that survives client tampering

`RegisterNetEvent` creates a network-reachable handler. Use it only when the
event truly crosses client/server boundaries; use `AddEventHandler` for
same-context work. In every server network handler, derive the actor from
`source`, verify server-side state (position, inventory, role, cooldown and
job state), bound every payload, and make rewards idempotent.

Keep these defaults in the server configuration unless an explicit, tested
exception exists:

```cfg
sv_scriptHookAllowed 0
sv_endpointPrivacy true
```

Additional CnL, pure-settings and request-control controls should be enabled
only after reviewing their documented operational effects and testing with real
players; they are defense in depth, not a substitute for authoritative events.

Source: [Cfx secure your events](https://docs.fivem.net/docs/developers/server-security/).
