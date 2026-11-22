# Contributing to fivem-pro

Thanks for helping make FiveM development safer and easier to operate.

## Before you open a change

1. Search existing issues and references so the same guidance is not repeated.
2. Prefer primary Cfx documentation for platform facts. Include a direct link
   when behaviour, a native, a convar or a framework API is mentioned.
3. Keep framework-specific patterns in the matching reference; keep `SKILL.md`
   focused on routing and non-negotiable rules.
4. Never add credentials, webhook URLs, real server data or client-trusting
   payout/inventory examples.

## Documentation changes

- Use short, imperative instructions and explain *why* a safety rule exists.
- Mark compatibility-sensitive configuration as needing staging validation.
- Keep runnable snippets minimal and complete enough to show trust boundaries.
- Update `README.md`, `CHEATSHEET.md` and `CHANGELOG.md` when a new reference
  changes the public map of the skill.

## Example-resource changes

The template is deliberately opinionated. Every server network event must
derive the player from `source`, validate payloads and make any reward
server-authoritative. Keep manifest ordering explicit and user-facing strings
in locales.

Run the same checks used by CI before opening a pull request:

```bash
selene --config selene.toml examples/
stylua --check examples/
```

If a tool is unavailable locally, say so in the pull request and let CI be the
final gate. Do not commit generated archives or secrets.

## Pull requests

- Keep one concern per pull request.
- Explain the problem, the chosen approach and the validation performed.
- For a behaviour or security recommendation, include an authoritative source.
- Use conventional, concise commit messages such as `docs: clarify OneSync
  scope` or `fix: validate template event payload`.

