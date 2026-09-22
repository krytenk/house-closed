# House Closed

You wake in shuttered Paloma House. One locked room at a time. About an hour each.

**For fun. You cannot win real money.** Coins are puzzle items, not a wallet.

Engine: Godot 4.7. Product bible: [`docs/HOUSE_CLOSED.md`](docs/HOUSE_CLOSED.md).

Palm Atoll the luxury casino is archived in [`docs/PALM_ATOLL_BUILD_SPEC.md`](docs/PALM_ATOLL_BUILD_SPEC.md). Do not resume it in this repo.

## Run

```
godot --path . --editor
godot --path . --scene rooms/room_01_lounge/lounge_escape.tscn
```

WASD, mouse look, E / click to use. Esc frees the mouse. Hold-drag the pelican on the broken machine.

## Docs

| File | What |
|---|---|
| [docs/HOUSE_CLOSED.md](docs/HOUSE_CLOSED.md) | Product, map, laws, working |
| [docs/FOLDER_LAYOUT.md](docs/FOLDER_LAYOUT.md) | Folders |
| [docs/SCENE_PIPELINE.md](docs/SCENE_PIPELINE.md) | Blender → Godot |
| [docs/INTERACTABLES.md](docs/INTERACTABLES.md) | Use, inventory, flags |
| [docs/ASSETS.md](docs/ASSETS.md) | Art on disk |
| [docs/TRAPS.md](docs/TRAPS.md) | Every trap index |
| [rooms/room_01_lounge/ROOM.md](rooms/room_01_lounge/ROOM.md) | Room 01 (playable) |
| [rooms/room_02_lobby/ROOM.md](rooms/room_02_lobby/ROOM.md) | Room 02 plan |
| … through `room_07_suite` | Later rooms, plan only |

## Tests

```
godot --headless -s res://tests/run_all.gd
```

Those tests still cover leftover Palm Atoll systems. They are not Room 01’s definition of done.
