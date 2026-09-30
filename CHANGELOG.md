# Changelog

## [1.1.0] — 2026-09-30

### Added
- `references/esx.md` — ESX framework patterns (xPlayer, callbacks, society)
- `references/qbox.md` — QBox patterns and QBCore→QBox migration notes
- `references/performance.md` — resmon profiling, tick budget, entity/streaming optimization
- `references/testing.md` — test discipline, pre-deploy checklist, staging flow
- `references/cicd.md` — GitHub Actions for FiveM resources (lint, format, release)
- `references/troubleshooting.md` — symptom → cause → fix FAQ
- `references/security.md` — Part C: server-side detection patterns (speed/teleport,
  godmode, injection, heartbeat, screenshot-basic); Part D: exploit case studies
  (open payout event, inventory dupe race condition, NUI callback forwarding)
- `examples/template-resource/` — minimal secure resource demonstrating every Iron Rule
- `.github/workflows/lint.yml` — CI: selene lint + StyLua format check on PRs
- `selene.toml` — FiveM-aware selene config
- `CHEATSHEET.md` — one-page quick reference

### Changed
- `SKILL.md` — router and triage table cover all 14 reference domains; version 1.1.0
- `README.md` — skill map updated

## [1.0.0] — 2026-09-30

Initial release. All-in-one FiveM dev skill: Lua conventions, QBCore patterns,
ox ecosystem, NUI (vanilla + React), FXServer deployment, live resource workflow,
anticheat hardening + security audit, map/MLO creation with Sollumz + CodeWalker.
