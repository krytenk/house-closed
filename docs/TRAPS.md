# Trap index

Every scripted lock in the series. Details and fail lines live in each `ROOM.md`.

Room 01 play review is `rooms/room_01_lounge/traps/`. One file per id. Status lives there, not in this index.

| Room | id | Kind |
|---|---|---|
| 01 Lounge | `door` | Chain + key |
| 01 | `bird` | Drag-rotate statue, dump coins |
| 01 | `setter` / `reel_*` | Feed coins, set P L C |
| 01 | `jammed` | Dead hopper until jackpot |
| 01 | `register` | Fuse + code 418 |
| 01 | `lantern` | Unscrew fuse |
| 01 | `house_line` | Wall plaque (the combination) |
| 01 | `stool_note` | Notebook pickup |
| 01 | `boards` | Wood on the ocean window |
| 01 | `plinth` | Optional flashlight |
| 01 | `stool_empty` | Red herring |
| 02 Lobby | `staff_door` | Exit |
| 02 | `desk` | Drawer |
| 02 | `notice` | Read |
| 02 | `lamp` | Power desk |
| 02 | `sofa` | Cushion scrap |
| 02 | `stairs` | Tease suite |
| 02 | `hall_cabana` | Tease 04 |
| 02 | `hall_salon` | Tease 05 |
| 02 | `planter` | Optional |
| 03 Desk | `safe` | Combination |
| 03 | `drawer` | Cash drawer |
| 03 | `terminal` | CRT |
| 03 | `pigeon_arthur` | Envelope |
| 03 | `coat` | Optional |
| 03 | `cabana_bolt` | Exit |
| 04 Cabana | `house_hand` | Framed cards |
| 04 | `card_seat` | Hidden card |
| 04 | `felt` | Place matching hand |
| 04 | `tray` | Chip false bottom |
| 04 | `human_door` | Sealed flavour |
| 04 | `practice_door` | Optional |
| 04 | `salon_door` | Exit |
| 05 Salon | `cover` | Wheel cloth |
| 05 | `chit` | Pocket number |
| 05 | `wheel` | Rotate to number |
| 05 | `ball` | Drop on set pocket |
| 05 | `nightclub_door` | Exit |
| 06 Nightclub | `setlist` | Lantern order |
| 06 | `lantern_0..2` | Light in order |
| 06 | `mixer` | Powers with lights |
| 06 | `cassette` | Click code |
| 06 | `suite_gate` | Keypad exit |
| 06 | `garden` | Boarded, never opens |
| 07 Suite | `lamp` `plant` `art` `nightstand` `bed` `rug` `drape` `chair` | Search |
| 07 | `garden_door` | Two key halves, series end |

**Rules:** deterministic; no fake timer; if the object cannot look like the trap, change the trap (see Room 01 house line vs peel).
