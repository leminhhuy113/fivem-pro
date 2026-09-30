# FXServer Deployment

## server.cfg essentials

```cfg
# identity
sv_hostname "RSRM City"
sets locale "vi-VN"

# network
endpoint_add_tcp "0.0.0.0:30120"
endpoint_add_udp "0.0.0.0:30120"

# license
sv_licenseKey "cfx_..."

# security baseline
sv_scriptHookAllowed 0
sv_endpointPrivacy true

# onesync
set onesync on
set onesync_enableInfinity true

# database
set mysql_connection_string "mysql://user:pass@127.0.0.1/db?charset=utf8mb4"

# resources (order matters: framework -> libs -> gameplay)
ensure qb-core
ensure oxmysql
ensure ox_lib
ensure [my-category]
```

- Secrets (license key, DB password, webhook URLs) in a separate
  `secrets.cfg` that is `exec`'d and NEVER committed to git.
- Linux paths are case-sensitive: `[LMH]` ≠ `[lmh]`.

## txAdmin / systemd

- Run FXServer under txAdmin or a systemd unit per environment
  (e.g. `rsrm2026.service`). One service per base — never two bases on one
  service.
- Deploy checklist:
  1. Baseline: note current resource versions/hashes.
  2. Backup the resource folder + relevant DB tables.
  3. Copy new files, verify `fxmanifest.lua` syntax.
  4. `restart <resource>` via txAdmin console (not full service restart).
  5. Watch server console for errors; verify dependents still running.
  6. In-game smoke test the changed flow.

## Ports (example multi-base layout)

| Base | Game TCP/UDP | txAdmin | DB |
|---|---|---|---|
| legacy | 30120 | 40120 | rsrm |
| 2026 | 30121 | 40121 | rsrm2026 |

Separate DB, separate txData, separate license key per base.

## Don't

- Don't `reboot` / full-restart the service to apply a CSS or Lua change.
- Don't `ensure` a resource before its dependencies in server.cfg.
- Don't copy an entire production DB over a dev base — migrate schema with
  versioned migrations, backup first, make them re-runnable.
