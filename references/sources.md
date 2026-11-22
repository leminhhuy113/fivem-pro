# Source Registry

**Last verified: 2026-11-23.** These are primary sources used to refresh the
platform guidance. Re-check a source before making a compatibility claim after
an FXServer, framework or ox release.

| Area | Primary source | Used for |
|---|---|---|
| Resource manifests / CfxLua | [Cfx resource manifest](https://docs.fivem.net/docs/scripting-reference/resource-manifest/) · [Lua runtime](https://docs.fivem.net/docs/scripting-manual/runtimes/lua/) | manifest directives, runtime defaults, Node versions |
| Events / security | [Secure your events](https://docs.fivem.net/docs/developers/server-security/) | network event trust boundaries and server validation |
| OneSync | [OneSync](https://docs.fivem.net/docs/scripting-reference/onesync/) | scopes, server-created entities and routing buckets |
| State Bags | [State Bags](https://docs.fivem.net/docs/scripting-manual/networking/state-bags/) | shallow state semantics and write authority |
| Entity references | [Network and local IDs](https://docs.fivem.net/docs/scripting-manual/networking/ids/) | net IDs versus local handles |
| Native APIs | [Cfx native reference](https://docs.fivem.net/natives/) | native signatures; check before adding native examples |

Framework and ox APIs move independently. When an upstream project provides
versioned documentation, link the exact version in a pull request or release
note. Do not cite forum replies, decompiled code or an AI answer as the sole
authority for a security or compatibility recommendation.

