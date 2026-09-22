# House Closed

Single source of truth for this repo’s **current product**.

Working title: **House Closed**. The guest is locked inside shuttered Paloma House, one room at a time. Each room is about an hour. A new Grok session builds **only the next sealed room**.

Palm Atoll the luxury casino (`docs/PALM_ATOLL_BUILD_SPEC.md`) is **archive**. Do not resume Shells, Daylight SKUs, IAP, or ChanceRng paytables here.

---

## What the game is

First-person. You wake in a closed casino. The door is locked. You leave by using objects, not by luck.

- Tokens you pick up are **inventory**, not a wallet. No cash-out. No shop.
- A “jackpot” or “spin” is a **scripted match**. Never `ChanceRng`.
- No fake timers, HURRY, WIN BIG, affection meters, children as characters.
- Tone: quiet abandonment. No jump-scare budget unless a future ROOM.md says so. Master plan: `docs/ATMOSPHERE.md`.

Boot: `res://rooms/room_01_lounge/lounge_escape.tscn` (see `project.godot` main scene).

---

## House map (Paloma House)

From the old hotel plan, looking from the porch:

```
                    [Garden / island]     sealed
                           |
        [Cabana] ---- [LOBBY] ---- [Lounge]
         POKER          desk         SLOTS
                           |            Room 01 (playable)
                      [Salon]
                      ROULETTE
                           |
                      [Nightclub]
                           |
                    [Suite / bungalow]
```

| ID | Folder | Old name | Status |
|---|---|---|---|
| `room_01` | `rooms/room_01_lounge/` | Tiki Lounge / slots | **In play** |
| `room_02` | `rooms/room_02_lobby/` | Hotel lobby | Plan only. GLB exists. |
| `room_03` | `rooms/room_03_desk/` | Mara’s desk / shop tab | Plan only |
| `room_04` | `rooms/room_04_cabana/` | Sunset Cabana / poker | Plan only. Old chance scene on disk. |
| `room_05` | `rooms/room_05_salon/` | Coral Salon / roulette | Plan only. Old chance scene on disk. |
| `room_06` | `rooms/room_06_nightclub/` | Nightclub | Plan only |
| `room_07` | `rooms/room_07_suite/` | Player suite / bungalow | Plan only |

Exit of room N names room N+1 and **does not build it**.

---

## Read in this order (new session)

1. This file
2. `docs/SCENE_PIPELINE.md` — Blender → Godot
3. `docs/INTERACTABLES.md` — `use_id`, inventory, flags, traps
4. `docs/ASSETS.md` — what art already exists
5. `docs/ATMOSPHERE.md` — sound and dread. Build it after polish, not during a puzzle fix
6. The **next** `rooms/room_NN_*/ROOM.md` only
7. Do not restyle a shipped room except shared escape systems

---

## Laws (fail the build)

- Deterministic puzzles. `ChanceRng` / `AiRng` are unused for this product.
- Coins, keys, fuses, slips are items. Finite. No second wallet.
- Collision on walkable solids (bar, walls, stools, machines, boards).
- Scenery lives in Blender. Godot only hangs sockets and a few gameplay meshes (statue bird, house-line plaque, coins).
- Grep clean of: `whale`, `proto-whale`, `coin drain`, `sweeps`, `cash out`, `redeem`, `WIN BIG`, `LAST CHANCE`, `Beads` (as currency).

---

## What “working” means (every room)

A room is working when all of this is true:

1. Wake in FPV. Mouse look + WASD. Cannot walk through solids.
2. Every **trap** in that ROOM.md can be seen, used, and resolved without a text-only label standing in for the object.
3. Critical path reaches the exit door. Side traps are optional.
4. Save flags persist under `Save.progress.escape.room_NN`.
5. Exit line names the next sealed space. That space is not loaded.
6. Godot MCP: screenshot wake → each critical Use → door opens.
7. No ChanceRng, no IAP sheet, no Daylight SKU.

---

## Leftover Palm Atoll (do not ship)

Keep on disk; do not call from Room 01+:

- `rooms/tiki_lounge/slot_palm.tscn`, `palm_reels.gd`, paytables
- `rooms/sunset_cabana/*` chance poker
- `rooms/coral_salon/*` roulette
- `world/paloma_atoll.tscn` board loop
- `systems/economy.gd`, `daylight.gd`, `iap_stub.gd` as live loops
- Age-gate gambling copy on splash (splash is not the main scene)

---

## Engine

Godot 4.7. Tests: `godot --headless -s res://tests/run_all.gd` (legacy casino tests still exist; they are not Room 01’s definition of done).
