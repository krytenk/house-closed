# House Closed

Single source of truth for this repo’s **current product**.

Working title: **House Closed**. The guest is locked inside shuttered Paloma House, one room at a time. The first room is a short waking-up episode. Each later room is harder and longer than the one before it. A new Grok session builds **only the next sealed room**.

Palm Atoll the luxury casino (`docs/PALM_ATOLL_BUILD_SPEC.md`) is **archive**. Do not resume Shells, Daylight SKUs, IAP, or ChanceRng paytables here.

---

## What the game is

First-person. You wake in a closed casino. The door is locked. You leave by using objects, not by luck.

- Tokens you pick up are **inventory**, not a wallet. No cash-out. No shop.
- A “jackpot” or “spin” is a **scripted match**. Never `ChanceRng`.
- No fake timers, HURRY, WIN BIG, affection meters, children as characters.
- Tone: quiet abandonment. No jump-scare budget unless a future ROOM.md says so. Master plan: `docs/ATMOSPHERE.md`.

Boot: splash, age gate, then `res://rooms/room_01_lounge/lounge_escape.tscn`. The project main scene is the splash.

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

## How long a room is

Length is a first visit by someone who does not know the chain. A person who already knows the solution should be clearly shorter. Do not fill time by hiding the use spot or by a fake timer.

| Room | First visit | Knowing the chain | Job |
|---|---|---|---|
| 01 Lounge | 15–25 min | about 10 min | Wake up. Learn the house. One code, one key. |
| 02 Lobby | about 30 min | about 12 min | Two clues make one code. A false cell. A false key. |
| 03–07 | Longer than the room before | Shorter than that room’s first visit | Harder each time. More false doors. More steps. |

Room 02’s half hour is designed in `rooms/room_02_lobby/ROOM.md`. Do not stretch Room 01 to an hour. Polish does not add locks.

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

## Free demo page

Room 01 can ship alone, free, in the browser. Later rooms stay sealed. The page is not a store for the next rooms.

Short description: A free first room. You wake in a shuttered lounge. The rest of the house is still sealed.

Genre: Puzzle.

Keyword tags: 3D, First-Person, Atmospheric, Exploration, Mystery, Escape Game, Short, Singleplayer, Godot, Episodic.

Do not use Horror, Psychological Horror, Scary, or Adult. Adult on that site means sexual content.

Press pictures are in `art/press/house_closed/`. The cover is 1260×1000, which is the 630×500 page shape at twice the size. The web export preset is `Web`. Built zips stay out of git.

---

## Leftover Palm Atoll (do not ship)

Keep on disk; do not call from Room 01+:

- `rooms/tiki_lounge/slot_palm.tscn`, `palm_reels.gd`, paytables
- `rooms/sunset_cabana/*` chance poker
- `rooms/coral_salon/*` roulette
- `world/paloma_atoll.tscn` board loop
- `systems/economy.gd`, `daylight.gd`, `iap_stub.gd` as live loops
- Old chance scenes. The splash is the main scene, and after the age question it enters Room 01.

---

## Engine

Godot 4.7. Tests: `godot --headless -s res://tests/run_all.gd` (legacy casino tests still exist; they are not Room 01’s definition of done).
