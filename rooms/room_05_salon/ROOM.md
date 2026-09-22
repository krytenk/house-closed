# Room 05 — The Salon

**Scene key:** `room_05`  
**Play file:** `rooms/room_05_salon/salon_escape.tscn` — **not created**  
**Old chance scene:** `rooms/coral_salon/coral_salon.tscn` + `roulette.gd` — **do not** spin `ChanceRng`  
**Status:** Plan only.

Old door label `ROULETTE`. The wheel is a **combination lock**. European layout (0–36) stays as numbers on the wheel, used as a code, not a bet.

## Working

Set the wheel to a **written** number (from a salon chit), drop a single ball into that pocket by using the ball item on the marked pocket (or rotate wheel until the marker lines up — authored, not random). That releases the nightclub key. Line: *The nightclub is still sealed.*

## Layout (intended)

Coral Salon: one wheel, felt, a covered table, chandelier (one dead bulb), cage of chips that are scenery.

| Socket | Role |
|---|---|
| `PlayerSpawn` | Hall |
| `Wheel` | Rotatable (like Room 01 bird) |
| `Ball` | Pickup |
| `Marker` | Zero diamond or house marker |
| `Chit` | Paper with the pocket number |
| `ChipCage` | Optional |
| `NightclubDoor` | Exit |

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `chit` | Paper under felt | Folded | Read | Pocket number **authored** (pick one 0–36 when building; write it here) | — |
| `wheel` | Roulette wheel | Dusty, covered | Drag-rotate until the number faces the marker | `wheel_set` | “Not that pocket.” |
| `ball` | Ivory ball | In a cup | Use on wheel only when `wheel_set` | `drop` → nightclub key in the bill slot | “Cover’s still on.” |
| `cover` | Wheel cover | Cloth | Remove first | Wheel usable | — |
| `nightclub_door` | Rear door | Chain | Key from bill slot | Room 05 clear | Chained |

**Author the pocket in this file before coding.** Example placeholder: pocket `17` — replace with the number printed on the chit texture so they cannot drift apart.

## Do not

37-pocket RNG. Bets. Paytable. `test_european_roulette_37.gd` is legacy, not this room’s done list.
