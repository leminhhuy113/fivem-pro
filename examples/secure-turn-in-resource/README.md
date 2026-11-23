# Secure Turn-in Resource

A runnable, framework-selectable FiveM resource that demonstrates the same
server-authoritative turn-in flow for **QBCore**, **ESX** and **QBox**.

## Install

1. Copy this folder into your server's resources directory as
   `[local]/secure-turn-in`.
2. Set `Config.Framework` to `qbcore`, `esx`, `qbox`, or leave it as `auto`.
3. Change the demonstration coordinates and payout in `config.lua`.
4. Add the matching framework resource before `ensure secure-turn-in` in
   `server.cfg`.
5. Test with two clients on staging. A client may open the prompt, but the
   server alone starts, times and consumes the activity before it pays.

This example deliberately has no inventory dependency. Add item requirements
only through your framework or `ox_inventory` server API after the same state,
distance and replay checks pass.

## What it demonstrates

- framework adapter selected server-side;
- server-owned activity state keyed by `source`;
- server-side position check at both start and turn-in;
- fixed server configuration payout; and
- activity state consumed before payout to reject repeated events.

It is a teaching resource, not a drop-in job economy. Use the framework
references and [framework parity guide](../../references/framework-parity.md)
before extending it.
