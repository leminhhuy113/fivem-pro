# GTA V Map / MLO Creation (Sollumz + CodeWalker)

Toolchain: **Blender + Sollumz addon** for modeling/export, **CodeWalker**
for world placement and binary conversion.

## The 9-step interior/MLO workflow

1. **Pick a building** — choose the target building/location in CodeWalker.
2. **CodeWalker export** — export existing drawable/collision/ymap as reference.
3. **Planning** — layout sketch, room list, mood board (optional but saves rework).
4. **Modeling** — build in Blender, convert meshes to Sollumz Drawables.
5. **Texturing** — shaders, textures, UVs, vertex coloring. Halve texture
   sizes per LOD step (512 → 256 → 128 → 64).
6. **Collision** — interior collision via Sollumz; per-room floor materials;
   use the correct Flag Preset or collision silently fails.
7. **YTYP** — define archetypes, rooms, and portals connecting them.
   Portals need correct room-from/room-to or audio/occlusion breaks.
8. **Export** — export from Blender, convert to binary in CodeWalker.
9. **YMAP placement** — final world placement; generate `_manifest.ymf`
   or the MLO won't load in game.

## File formats you will touch

| Format | Contains |
|---|---|
| `.ydr` | Drawable (static mesh) |
| `.ybn` | Collision bounds |
| `.ytd` | Texture dictionary |
| `.ytyp` | Archetype definitions, rooms, portals |
| `.ymap` | Map placements (entities in the world) |
| `_manifest.ymf` | MLO manifest — required for interiors |

## LODs — do them or the map pops

- Build high/medium/low/verylow mesh versions; link each to its drawable slot.
- Orphan LOD: ymap entity flag for LOD-in-parent-map; distances ~50/100/150.
- YMAP parenting: chain HD → LOD → SLOD with correct parent indices
  (0-based) and child LOD distances.

## Common-mistakes triage

| Symptom | Check |
|---|---|
| Collision doesn't work | Sollumz Flag Preset on the collision |
| MLO not loading in game | `_manifest.ymf` generated? |
| Black/invisible textures | `.ytd` exported and streamed? Shader assigned? |
| Audio/occlusion wrong indoors | Portal room-from/room-to assignments |
| Flickering at distance | LOD distances / missing LOD meshes |

## FiveM streaming

- Package as a resource with `fxmanifest.lua`, stream the `.ydr/.ybn/.ytd/
  .ytyp/.ymap/.ymf` files via `files` + `data_file` entries
  (`DLC_ITYP_REQUEST`, etc.).
- Test on a local FXServer before shipping to production.
