# Room 04 — The Cabana

**Scene key:** `room_04`  
**Play file:** `rooms/room_04_cabana/cabana_escape.tscn` — **not created**  
**Old chance scene:** `rooms/sunset_cabana/sunset_cabana.tscn` (Hold’em) — **do not** call `Holdem` / `ChanceRng`  
**Status:** Plan only.

Old door label `POKER`. Felt tables stay. Cards are clues. No real deal.

## Working

Enter from cabana hall. FPV around one felt table and a practice cage. Arrange a **shown** hand (not shuffled RNG) to match a framed “house hand” on the wall. That opens a chip-tray false bottom → salon key. Line: *The salon is still sealed.*

## Layout (intended)

Sunset Cabana mesh or a new blend: one table, chairs, a covered second table, wall frame “HOUSE HAND”, a dark `HUMAN` door and a dark `PRACTICE (AI)` door as scenery (both locked; labels stay so the room still reads as the old cabana).

| Socket | Role |
|---|---|
| `PlayerSpawn` | Hall |
| `Felt` | Table |
| `HouseHand` | Framed five cards (texture) |
| `Seat_0..4` | Chairs; one hides a card |
| `ChipTray` | False bottom |
| `HumanDoor` | Locked forever in this room |
| `PracticeDoor` | Locked; optional inner closet |
| `SalonDoor` | Exit |

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `house_hand` | Framed cards | Five specific ranks/suits painted | Look | Know the target hand | — |
| `card_seat` | Chair rail | Loose | Take a physical card item | Card in inventory | — |
| `felt` | Table | Scattered cards as pickups (finite, labelled meshes or textures) | Place cards onto five slots until they **match the frame** | `hand_set` | “Not the house hand.” |
| `tray` | Chip tray | Stuck | Opens only when `hand_set` | Salon key | “Tray’s jammed.” |
| `human_door` | HUMAN | Dark glass | Cannot open | Flavour: “Need a connection.” (no network call) | Sealed |
| `practice_door` | PRACTICE | Cage | Optional: inner fuse | Side path | Sealed if unused |
| `salon_door` | To salon | Card reader | Salon key | Room 04 clear | Dead |

## Implementation note

Card placement is inventory-on-slot, same Use protocol. Do **not** shuffle. The house hand is authored in the ROOM.md when art is chosen (example target: five-card picture on the wall; player gathers those five). Document the five faces in this file before implementation so a later session does not invent RNG.

## Do not

`AiRng` decisions. Stacks as currency. Sit flow that converts Shells.
