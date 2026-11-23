# Changelog

## [1.4.1] — 2026-11-23

### Fixed
- Reset the secure turn-in client request state whenever the server rejects a
  start or turn-in request, so a player can retry safely after a denial.

## [1.4.0] — 2026-11-23

### Added
- `examples/secure-turn-in-resource/` — a runnable, framework-selectable
  QBCore / ESX / QBox resource that demonstrates server-authoritative payout.
- GitHub Discussions starter posts for onboarding, focused Q&A and project
  showcases.

### Changed
- FiveM Selene definitions now cover the native calls used by the runnable
  example.

## [1.3.0] — 2026-11-23

### Added
- `references/framework-parity.md` — a framework-parity secure turn-in flow
  for QBCore, ESX and QBox.
- `examples/secure-turn-in-resource/` — runnable server-authoritative QBCore,
  ESX and QBox turn-in example selected through a server-side adapter.
- `docs/quickstart.md` and `references/sources.md` — task-oriented onboarding
  and a dated registry of primary Cfx sources.
- `SECURITY.md`, `SUPPORT.md`, `CODE_OF_CONDUCT.md`, `CODEOWNERS` and
  Dependabot configuration — clearer ownership, contribution and disclosure
  expectations.
- Documentation link/source-registry CI and `docs/social-preview.jpg` for
  GitHub social sharing.

## [Unreleased]

### Added
- `docs/index.html` — responsive, accessible interactive skill hub with
  installation command copying and a domain navigator.
- `.github/workflows/release.yml` — tag-driven installable ZIP and GitHub
  Release publishing.
- `.github/workflows/pages.yml` — automatic GitHub Pages deployment for the
  skill hub.
- `CONTRIBUTING.md` and issue/PR templates — consistent source, safety and
  validation standards for contributors.

## [1.2.0] — 2026-11-23

### Added
- `references/platform-2026.md` — current Cfx platform guidance for Lua 5.4,
  OneSync, State Bags, routing buckets, entity IDs and server hardening.
- `docs/banner-2026.png` — refreshed premium project cover.

### Changed
- `README.md` — clearer installation guidance and a concise 2026 compatibility
  summary with links to the detailed reference.
- `SKILL.md` and the template manifest — removed the outdated instruction to
  add `lua54 'yes'`; CfxLua 5.4 is now the default runtime.

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



