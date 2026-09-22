# Assets

## Art that Room 01 actually uses

| Path | Role |
|---|---|
| `art/models/abandoned_lounge.tscn` | Dressed lounge (from GLB) |
| `art/models/abandoned_lounge.glb` | Blender export |
| `tools/abandoned_lounge.blend` | Source. Open this to dress the room. |
| `tools/build_abandoned_lounge.py` | Rebuild GLB |
| `tools/import_glb.gd` | GLB → tscn |
| `art/seasons/paloma/wood.png` | Bar, posts, window planks |
| `art/seasons/paloma/tiles_ref/wood_plank.png` | Floor (stretched; UV polish later) |
| `art/seasons/paloma/tiles_ref/thatch.png` | Ceiling |
| `art/seasons/paloma/wallpaper_lounge.png` | Wall paper (applied in Godot) |
| `art/seasons/paloma/sym_P.png` | Pineapple |
| `art/seasons/paloma/sym_L.png` | Leaf |
| `art/seasons/paloma/sym_C.png` | Coconut |
| `art/seasons/paloma/sym_S.png` | Shell (reel cycle filler) |
| `rooms/tiki_lounge/cabinet_builder.gd` | Teal cabinets + statue bird |

## Art on disk, not in the live loop

| Path | Notes |
|---|---|
| `art/models/casino_lounge.glb` | Older block lounge |
| `art/models/lobby_room.glb` | **Room 02** shell |
| `art/models/tiki_cabinet.glb` | Unused; cabinets are CSG |
| `art/seasons/paloma/cabinet_*.jpg` | Concept stills. Do not full-screen as TextureRect. |
| `art/seasons/paloma/lounge_interior.jpg` | Concept. Not the play mesh. |
| `art/seasons/paloma/shot_*.png` | Old overlay shots |

## Audio (legacy)

`audio/click.wav`, `steel.wav`, `surf.wav`, `win.wav` — not wired in Room 01 yet.

## What a new room must bring

1. `tools/<room>.blend` + export GLB
2. Named sockets listed in that ROOM.md
3. Collision-ready meshes (or Godot `_collide_room` list)
4. Clue art as textures on plaques / papers, not unlabeled primitives
5. No new autoload without putting it in `docs/HOUSE_CLOSED.md`

## Weathering (later, not now)

Dirt, rust, peeled corners baked into Blender materials. Do not fake aging with extra Godot cubes. Tracked as polish after the hour of play works.
