# fivem-pro

All-in-one FiveM development skill for AI coding assistants. One skill that
covers the full FiveM resource lifecycle:

- **Lua conventions** — events, exports, threads, StateBags, natives
- **QBCore patterns** — Player object, callbacks, jobs, economy rules
- **ox ecosystem** — ox_lib, oxmysql, ox_inventory, ox_target
- **NUI** — vanilla + React, focus lifecycle, CEF gotchas
- **Deployment** — server.cfg, txAdmin, multi-base layouts
- **Live workflow** — minimal restarts while the server runs
- **Security** — anticheat hardening + resource audit checklist
- **Mapping** — MLO/interior creation with Sollumz + CodeWalker

## Install

Copy to your skills directory:

```bash
cp -r fivem-pro ~/.claude/skills/
# or for Cursor/Codex:
cp -r fivem-pro /path/to/project/.claude/skills/
```

## Layout

```
fivem-pro/
  SKILL.md            # router + the iron rules + quick triage
  references/
    lua.md            # FiveM Lua conventions
    qbcore.md         # QBCore framework patterns
    ox-ecosystem.md   # ox_lib / oxmysql / ox_inventory / ox_target
    nui.md            # NUI development
    deployment.md     # FXServer deployment
    workflow.md       # live resource workflow
    security.md       # anticheat + security audit
    maps-sollumz.md   # map/MLO creation
```

## License

MIT — written from scratch by 1MS Studio. See LICENSE.
