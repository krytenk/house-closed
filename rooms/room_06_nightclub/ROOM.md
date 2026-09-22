# Room 06 — The Nightclub

**Scene key:** `room_06`  
**Play file:** `rooms/room_06_nightclub/nightclub_escape.tscn` — **not created**  
**Old scene:** `world/hotel_lobby/nightclub.tscn` (lantern deck preview)  
**Status:** Plan only.

No chance games. Lanterns, a dead mixer, a stage. Power and sequence puzzles.

## Working

Light three lanterns in the order painted on a setlist. Mixer powers. A cassette or reel in the deck plays a short click pattern that matches a keypad on the suite stair gate. Line: *The suite is still sealed.*

## Layout (intended)

Lantern deck: dance floor (empty), DJ booth, three hanging lanterns, a boarded garden door, stairs up to suites.

| Socket | Role |
|---|---|
| `PlayerSpawn` | From salon |
| `Lantern_0..2` | Unlit |
| `Setlist` | Painted order on a chalkboard |
| `Mixer` | Dead until lanterns |
| `Deck` | Cassette |
| `GardenDoor` | Boarded — tease island, never open in v1 |
| `SuiteGate` | Exit |

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `setlist` | Chalkboard | Three lantern icons in order | Read | Know order | — |
| `lantern_0` `lantern_1` `lantern_2` | Hanging lamps | Cold | Use in setlist order | `lights` | Wrong order: all go dark, reset. No damage, no timer. |
| `mixer` | Booth | Dark | On after `lights` | Deck usable | Dead |
| `cassette` | In deck | Label worn | Play | Hear N clicks = keypad digits (authored; write digits here when audio exists) | — |
| `suite_gate` | Stair gate | Keypad | Enter heard code | Room 06 clear | Wrong: shake, clear. |
| `garden` | Boards | Nailed | Cannot open | Flavour | “House is closed.” |

## Do not

Dance minigame. Chance. Music as a shop.

## Audio

Legacy `audio/` loops may be reused as atmosphere. The cassette pattern must be authored and listed in this file before implementation (example placeholder: `2-4-1` — replace when the clip is made).
