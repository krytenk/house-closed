# How a scene is created

House Closed rooms are **not** built as Godot boxes with Label3D clues. Scenery is Blender. Gameplay is a thin Godot wrapper on named sockets.

```
Blender (model, materials, lights)
  → export .glb
    → tools/import_glb.gd  (or Godot import)
      → art/models/<room>.tscn
        → rooms/room_NN_<slug>/<slug>.tscn
            instances the model
            hangs StaticBody3D + use_id on sockets
            places machines / plaques that must move
```

## 1. Blender

- File: `tools/<room>.blend` (Room 01: `tools/abandoned_lounge.blend`)
- Builder script (optional): `tools/build_<room>.py`
- Units: metres. Origin on the floor centre.
- Godot import flips Blender Y → Godot −Z. Keep sockets named; do not bake unique transforms in two places.

**Name sockets exactly** (empties or meshes). Godot `find_child(name, true, false)`:

| Socket | Role |
|---|---|
| `PlayerSpawn` | Wake position |
| `CabinetSpawn_0..n` | Where machines instance |
| `BirdPivot` | Turnable statue (or Godot builds the bird here) |
| `PaperFlap` | Optional peel strip. Unused in Room 01. |
| `HallDoor` | Exit door mesh |
| `Chain` | Visible lock; hide when unlocked |
| `Register` | Till |
| `Notebook` | Pickup mesh |
| `LanternFuse` | Fuse source |
| `Ocean` | Window opening |

Add new sockets in that room’s ROOM.md **before** using them in GDScript.

## 2. Export

```
blender --background --python tools/build_abandoned_lounge.py
# writes art/models/abandoned_lounge.glb
godot --headless -s res://tools/import_glb.gd --path .
# writes art/models/abandoned_lounge.tscn
```

Keep `.blend` under `tools/`, not `art/models/`, so Godot does not try the Blender importer.

## 3. Godot wrapper

`rooms/room_NN_<slug>/<slug>.tscn` is a Node3D with one script. It:

1. Instances the lounge tscn.
2. Does **not** paint over imported materials (`_paint_abandoned` is forbidden on a dressed GLB).
3. Clamps imported light energy (Blender watts become huge in Godot).
4. Adds floor + mesh collision (`_collide_room`).
5. Marks sockets with `_mark(node, use_id, size, offset)`.
6. Instances gameplay-only meshes (Room 01: statue bird, house-line plaque, coins).

## 4. What stays in Godot vs Blender

| In Blender | In Godot |
|---|---|
| Walls, floor, ceiling, bar, stools, door slab, wallpaper | Raycast Use, inventory, flags |
| Wood / fabric / metal materials | House-line plaque (uses existing `sym_P/L/C.png`) |
| Register body, notebook, lantern cage | Turnable pelican statue, brass coin pickups |
| Window boards (or Godot overlays wood planks if the GLB boards are too thin) | Pad UI for till code, HUD hint |

If a clue is a picture, use a **texture on a quad or a framed plaque**. Do not stand in with two spheres and a cone.

## 5. Collision

Every walkable solid gets a `StaticBody3D` named `Solid` (box from mesh AABB). Player is `CharacterBody3D` + `move_and_slide`. If you can walk through it, it is a bug.

## 6. Verify

Godot MCP: `run_project` on that room’s tscn. Screenshot wake, each critical Use, open door. Do not call a room done from code review alone.
