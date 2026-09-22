# Room 07 — The Suite

**Scene key:** `room_07`  
**Play file:** `rooms/room_07_suite/suite_escape.tscn` — **not created**  
**Old scenes:** `world/bungalow/bungalow.tscn` (decorate studio), guest corridor nameplates  
**Status:** Plan only. Last indoor room of v1.

Player suite: eight furniture slots from the archive spec become **search slots**, not cosmetics-with-power. End of the house: open the garden / porch and **stop**. Do not build the island board.

## Working

Search the suite. Assemble a house master from pieces hidden in furniture. Open the garden door to a black frame and a final line: *Paloma House is closed. The island stays dark.* No Room 08 in this pass.

## Layout (intended)

One room. Slots: bed, lamp, rug, window drape, chair, plant, wall art, nightstand. Each is a search trap. Window looks at a black garden.

| Socket | Role |
|---|---|
| `PlayerSpawn` | Stair |
| `Bed` `Lamp` `Rug` `Drape` `Chair` `Plant` `Art` `Nightstand` | Search |
| `GardenDoor` | Final exit |

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `nightstand` | Drawer | Stuck | Use after lamp is on | Half of master key | Dark |
| `lamp` | Bedside | Dead | Bulb from plant pot or drape weight | Desk light | — |
| `plant` | Pot | Dry | Dig | Bulb or digit | — |
| `art` | Wall frame | Crooked | Straighten; back compartment | Other half of key | — |
| `bed` | Mattress | Unmade | Lift | Red herring or extra digit | — |
| `rug` | Floor | Wrinkled | Peel back | Floor safe (code from art + plant) | — |
| `drape` | Window | Heavy | Pull | Optional | — |
| `chair` | Seat | Loose rail | — | Optional | — |
| `garden_door` | French door | Two locks | Both key halves | Room 07 clear / series end | One lock still set |

## Do not

Decor shop. Stat bonuses. Enter Nia/Arthur/Jules rooms. Rebuild the 24-tile island.

## Series end

Credits card. Save `cleared` on `room_07`. Future outdoor rooms are a new contract, not implied by this door.
