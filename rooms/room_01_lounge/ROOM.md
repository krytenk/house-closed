# Room 01 — The Lounge

**Scene key:** `room_01`  
**Play file:** `rooms/room_01_lounge/lounge_escape.tscn`  
**Model:** `art/models/abandoned_lounge.tscn`  
**Blend:** `tools/abandoned_lounge.blend`  
**Status:** In play. Hour of puzzles on one floor.

Sound and dread: `docs/ATMOSPHERE.md`. Not in this room yet. Build that after the polish list in `traps/README.md`.

Old name: Tiki Lounge / SLOTS door.

## Working

Wake FPV → cannot walk through bar/walls/machines → turn bird → 7 coins → house line P-L-C → 3 coins in centre tray → set reels → slip `418` → fuse in lantern → till code → house key → chained door opens → *Room 01 clear. The lobby is still sealed.*

## Layout (Godot)

- **−Z:** boarded ocean window, three cabinets (broken / setter / jammed)
- **+Z:** bar, stools, hall door
- **−X wall:** wallpaper + house-line plaque (pineapple, leaf, coconut)
- Spawn: `PlayerSpawn` facing the broken machine

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `door` | `HallDoor` + `Chain` | Chain and padlock | Use with `key` | `door_open` → finish | “House key is with the till. Till is dead.” |
| `bird` | Statue pelican on `Cabinet_0` | Cocked on a brass pin, OUT OF ORDER tape | Hold-drag (or E nudge) to ~180° | 7 `coin` on the floor | “It turns on the pin. Keep going.” |
| `setter` / `reel_0..2` | `Cabinet_1` tray + three centre cells | Dark until fed | Insert 3 coins, click cells to P, L, C | `jackpot`, slip `418`, till light | “Feed the tray first.” |
| `jammed` | `Cabinet_2` | Dead hopper | Use after jackpot | Hint: last digit is 8 | “Hopper jammed.” |
| `register` | `Register` on bar | Dark screen | Fuse in, then pad `418` | `key` | Dead / “something pops in the roof” |
| `lantern` | `LanternFuse` | Flicker | Use | `fuse` | Empty socket |
| `house_line` | Plaque on left wall | Three framed symbols | Use / look | Flag `wallpaper` (read) | — |
| `stool_note` | `Notebook` on floor | Book by stools | Pickup | `notebook` | Already taken |
| `boards` | Wood planks over `Ocean` | Boarded window | Use | Newspaper line | — |
| `plinth` | Optional | Empty plinth | Pry | `light` flashlight | Optional |
| `stool_empty` | Stool | Wobble | Use | Nothing | Red herring |

## Items

`coin` ×7, `notebook`, `fuse`, `key`, optional `light`.

## Flags

See `docs/INTERACTABLES.md`. Save `Save.progress.escape.room_01`.

## Scene build

Blender lounge + Godot cabinets (`cabinet_builder.gd`), statue bird, house-line quads (`sym_P/L/C.png`), wood planks on the window, wallpaper material on walls, `_collide_room`.

## Exit hook

Do **not** build Room 02. Line only: the lobby is still sealed.

## Do not

Peel-wallpaper trap (no paper texture on a flap). ChanceRng spin. Sit-in-cabinet minigame.

## Review

One file per trap, plus coin pickup and save: [traps/README.md](traps/README.md).

Known errors live in those files. A trap is not checked until its file says `ok`. Do not mark that from code review alone.
