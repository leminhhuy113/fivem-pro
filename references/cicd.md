# CI/CD for FiveM Resources

Every push gets linted. Every tag ships a ready-to-drop-in zip. No more
"works on my machine, breaks on the server".

## Pipeline layout

```
push / PR ──▶ lint (selene) ──▶ format check (stylua) ──▶ package (zip)
tag v*    ──▶ lint + format ──▶ package ──▶ GitHub Release
```

## 1. Lint with selene

Selene understands FiveM globals (`Citizen`, `RegisterNetEvent`, …) via the
`lua54` + FiveM std config. Add `.selene.toml` at the repo root:

```toml
std = "lua54"
# fiveM globals live in selene's builtin fivem std:
# https://github.com/Kampfkarren/selene (std/fivem.yml)
```

Workflow job (`.github/workflows/ci.yml`):

```yaml
name: ci

on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: NTBBloodbath/selene-action@v1
        with:
          args: --config .selene.toml ./client ./server ./shared
```

Alternative: `luacheck` via `lunarmodules/luacheck` action with a `.luacheckrc`
that whitelists FiveM globals. Pick one linter per repo, not both.

## 2. Format check with stylua

```yaml
  format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: JohnnyMorganz/stylua-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: latest
          args: --check ./client ./server ./shared ./config.lua
```

`stylua.toml` at root:

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 4
```

Fail the build on unformatted code — formatting debates end at the CI gate.

## 3. Package the resource

Zip exactly what the server needs. Exclude `.git`, CI configs, and dev docs:

```yaml
  package:
    needs: [lint, format]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Zip resource
        run: |
          zip -r my-resource.zip fxmanifest.lua config.lua client/ server/ shared/ locales/ html/ sql/ \
            -x "*.git*"
      - uses: actions/upload-artifact@v4
        with:
          name: my-resource
          path: my-resource.zip
```

The zip must unzip to a single folder named after the resource. Test this —
a zip that extracts files into `resources/` root breaks `ensure`.

## 4. Release on tag

```yaml
  release:
    needs: [lint, format, package]
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - name: Zip resource
        run: |
          zip -r my-resource.zip fxmanifest.lua config.lua client/ server/ shared/ locales/ html/ sql/ \
            -x "*.git*"
      - uses: softprops/action-gh-release@v2
        with:
          files: my-resource.zip
          generate_release_notes: true
```

Tag with `git tag v1.2.0 && git push --tags`. Server owners download the zip
from Releases — they never clone the repo onto the server.

## 5. Dependabot for actions

`.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
```

## 6. Branch protection

On `main`: require PR reviews, require the `lint` and `format` jobs to pass
before merge. Direct pushes to `main` off. Hotfixes go through the same gate —
especially hotfixes.

## Full example

Combine jobs 1–4 into one `.github/workflows/ci.yml` per resource repo.
Keep it under ~80 lines: checkout, lint, format, package, conditional
release. Anything fancier (multi-resource monorepo matrix, Discord webhook
on release) is a second workflow, not bolted onto this one.
