# Quickstart

Choose the path that matches the job in front of you. Start with the narrowest
reference, then use the template only after the rules are clear.

## I am creating a resource

1. Read [`references/lua.md`](../references/lua.md) for manifest, event and
   thread conventions.
2. Pick your framework: [QBCore](../references/qbcore.md),
   [ESX](../references/esx.md), or [QBox](../references/qbox.md).
3. If you use ox packages, read [`references/ox-ecosystem.md`](../references/ox-ecosystem.md).
4. Start from [`examples/template-resource/`](../examples/template-resource/)
   and replace its demo coordinates and reward before staging.

## I am auditing a vulnerable or paid resource

1. Read [`references/security.md`](../references/security.md).
2. List every server `RegisterNetEvent`; trace money, item, entity and SQL paths.
3. Check that the server derives the player from `source`, ignores client
   reward amounts and validates location, permissions and cooldowns.
4. Test on a separate staging database — never against production players.

## I am fixing lag or preparing a deployment

1. Profile before changing code: [`references/performance.md`](../references/performance.md).
2. Follow the restart and rollback discipline in [`references/workflow.md`](../references/workflow.md).
3. Complete the staging checklist in [`references/testing.md`](../references/testing.md).
4. Use [`references/deployment.md`](../references/deployment.md) only after
   backups and hashes are recorded.

## I need the same secure flow on another framework

Use [`references/framework-parity.md`](../references/framework-parity.md) for
the QBCore, ESX and QBox server-side turn-in pattern. It highlights what must
remain identical even when framework APIs differ.

