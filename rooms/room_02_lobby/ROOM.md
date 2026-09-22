# Room 02 — The Lobby

**Scene key:** `room_02` (add to `Game.SCENES` only when playable)  
**Play file:** `rooms/room_02_lobby/lobby_escape.tscn` — **not created**  
**Model on disk:** `art/models/lobby_room.glb`  
**Old scene:** `world/hotel_lobby/lobby.tscn` (Palm Atoll overlay — do not reuse as the escape room)  
**Status:** Plan only. Build after Room 01 is shipped.

Old name: Paloma House lobby. Hall left was Lounge (cleared). Hall right Cabana. Rear Salon. Desk = Mara.

## Working

Wake or walk in from Room 01’s hall. FPV. Cannot walk through desk, sofas, stairs. Solve lobby traps. Open the **desk-side staff door** into Room 03. Line: *The desk is still sealed.* Do not load Room 03.

## Layout (intended)

Reuse `lobby_room.glb`: reception desk, two sofas, stairs, hall mouths, planter, notice board.

| Socket to add in Blender | Role |
|---|---|
| `PlayerSpawn` | At the lounge hall mouth (you just left Room 01) |
| `Desk` | Reception |
| `NoticeBoard` | Paper clues |
| `Sofa_L` / `Sofa_R` | Search |
| `StairsGate` | Blocked upstairs |
| `HallCabana` | Visible, chained — Room 04 later |
| `HallSalon` | Visible, chained — Room 05 later |
| `StaffDoor` | Exit to Room 03 |
| `Planter` | Optional hide |

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `staff_door` | Staff door behind desk | Deadbolt | Staff key from desk drawer | Room 02 clear | “Staff only. Desk is dark.” |
| `desk` | Reception desk | Closed till, dusty ledger | After power: open drawer | Staff key **or** half-key | “Mara took the till tape.” |
| `notice` | Notice board | Faded house rules | Read | Guest names / a time | — |
| `lamp` | Desk lamp | Dead | Insert fuse **or** battery from Room 01 flashlight if kept | Desk usable | Click. Nothing. |
| `sofa` | Rattan sofa | Cushion dent | Lift cushion | Ledger scrap (desk code) | Dust |
| `stairs` | Stair rope | “Suites closed” | Cannot open in Room 02 | Tease Room 07 | “Not tonight.” |
| `hall_cabana` | Right hall | Chain | Cannot open | Tease Room 04 | “Cards still on the tables.” |
| `hall_salon` | Rear hall | Chain | Cannot open | Tease Room 05 | “The wheel is covered.” |
| `planter` | Planter | Dry soil | Dig (optional) | Spare digit | Optional |

## Intended hour

1. Arrive from lounge hall. Other halls chained. Stairs roped.
2. Notice board: *House closed at dawn. Staff count at the desk.*
3. Sofa scrap: a four-digit **or** a name that matches a pigeonhole.
4. Power the desk lamp (carry fuse from Room 01 **or** a lobby battery in a side table — prefer a new item in this room so Room 02 stands alone on replay).
5. Desk drawer: staff key.
6. Staff door.

## Assets to make

- Dress `lobby_room.glb` abandoned: dust, overturned tote, Mara’s chair empty. No living NPCs.
- Ledger mesh, notice papers as textured quads (readable pictures, not Label3D paragraphs).
- Staff key item.

## Do not

Seat Arthur/Nia. Shop tab. Daylight HUD. Chance doors that launch slots.
