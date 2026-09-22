# Room 02 — The Lobby

**Scene key:** `room_02` (add to `Game.SCENES` only when playable)  
**Play file:** `rooms/room_02_lobby/lobby_escape.tscn` — **not created**  
**Model on disk:** `art/models/lobby_room.glb`  
**Old scene:** `world/hotel_lobby/lobby.tscn` (Palm Atoll overlay — do not reuse as the escape room)  
**Status:** Plan only. Build after Room 01 polish. Do not load it from Room 01.

**First visit:** about 30 minutes. **Knowing the chain:** about 12. Harder than Room 01: the code is split across two places, the first power cell is wrong, and one of the two keys opens the wrong door.

Old name: Paloma House lobby. Hall left was Lounge (cleared). Hall right Cabana. Rear Salon. Desk was Mara’s. Mara is not here. No living person.

## Working

Walk in from Room 01’s hall. FPV. Cannot walk through the desk, sofas, stairs, or planter. Solve the lobby. Open the **staff door** behind the desk into Room 03. Line: *The desk is still sealed.* Do not load Room 03.

Room 02 stands alone. Do not require the Room 01 fuse or key. A guest who replays the lobby from a fresh save can finish it.

## Time, first visit

| Minutes | What they are doing |
|---|---|
| 0–4 | Arrive. Try the stair rope, the cabana chain, the salon chain. All real doors, none open tonight. |
| 4–8 | Notice board, then the wall clock. The clock looks like the code. The notice says it is not. |
| 8–12 | Both sofas. The dented one is empty. The other hides the scrap. |
| 12–17 | Pigeonholes. Wrong holes first. Third from the left holds the first half of the code. |
| 17–22 | Desk phone bells (wrong count). Then the stamp card in that pigeonhole (right count’s partner). |
| 22–27 | Planter cell fails in the lamp. The real cell is under the desk bell. Lamp comes on. |
| 27–30 | Drawer. Two keys. The spare fails on the cabana chain. The staff key opens the staff door. |

A guest who already knows it skips the clock, the dented sofa, the planter, and the spare key.

## Layout

Reuse `lobby_room.glb`. Dress it abandoned: dust, Mara’s chair empty, one tote on its side. No NPCs.

| Socket to add in Blender | Role |
|---|---|
| `PlayerSpawn` | At the lounge hall mouth |
| `Desk` | Reception. Drawer, lamp, bell, phone |
| `Pigeonhole_1` … `Pigeonhole_6` | Left to right. 3 is Mara’s |
| `NoticeBoard` | Rules, readable pictures |
| `Clock` | Red herring time |
| `Sofa_L` / `Sofa_R` | One empty, one scrap |
| `StairsGate` | Roped. Tease Room 07 |
| `HallCabana` | Chained. Tease Room 04 |
| `HallSalon` | Chained. Tease Room 05 |
| `StaffDoor` | Exit to Room 03 |
| `Planter` | False cell |
| `Chair` | Mara’s. Turns. Nothing |

## Critical path

1. Notice: *House closed at dawn. The staff count is at the desk. It is not the clock.*
2. Sofa scrap (the sofa without the dent): *Third pigeonhole from the left. Count the stamps, not the bells.*
3. Pigeonhole 3: a card, **19**, and six stamps. The stamps are the picture. The digits **19** are the first half.
4. The stair-rope tag, readable only up close: **07**. Second half. The desk code is **1907**.
5. Desk lamp is dark. The planter’s cell is corroded. The lamp spits it out. The live cell is under the reception bell.
6. Lamp on. Enter **1907** on the desk. Not the clock. Not four bells.
7. Drawer: staff key and a spare. Spare fails on `HallCabana`. Staff key opens `StaffDoor`.

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `staff_door` | Staff door | Deadbolt | Use with staff key | Room 02 clear | “Staff only. The desk is dark.” |
| `desk` | Drawer | Dark till, dusty ledger | Lamp on, then 1907 | Staff key and spare key | “The lamp is dead.” / “That is not the staff count.” |
| `lamp` | Desk lamp | Dead | Live cell, not the planter cell | Desk will take the code | “Click. Nothing.” |
| `bell` | Reception bell | Sitting on the blotter | Lift | Live cell | “It rings. Nobody comes.” if lifted after the cell is taken |
| `pigeon_3` | Third hole | Faded M | Pull the card | Digits 19 and six stamps | “Empty.” on the other five holes |
| `sofa_scrap` | The plain sofa | Cushion | Lift | The scrap | — |
| `rope_tag` | Stair rope | Small tag | Read up close | Digits 07 | — |
| `notice` | Notice board | Faded rules | Read | Clock is not the count | — |

## Red herrings

Each one is a real object you can use. None of them open the staff door.

| id | Object | What it promises | What it does |
|---|---|---|---|
| `clock` | Wall clock, stopped at 6:10 | The code | Notice already said no. Entering 610 or 0610 at the desk fails |
| `phone` | Desk phone, four bells drawn on the base | “Count the bells” | Four is wrong. The scrap said stamps |
| `sofa_dent` | Dented sofa | The hiding place | Dust and a dead match. No scrap |
| `planter` | Dry planter | A buried cell | Corroded cell. Lamp refuses it |
| `chair` | Mara’s chair | Something in the seat | Turns. Empty |
| `stairs` | Roped stairs | The way up | “Not tonight.” Names the suite without opening it |
| `hall_cabana` | Right hall | The spare key might fit | “The teeth are wrong. Cards still on the tables.” |
| `hall_salon` | Rear hall | Another way out | “The wheel is covered.” |
| `guest_book` | Open book on the desk | A name that is the code | Three readable pages of guest names. None are the count |
| `stand` | Umbrella stand by the lounge hall | Lost property | One wet tag: “Lost and found is the desk.” Sends you back |

## Flags

Under `Save.progress.escape.room_02` only. Do not reuse Room 01 names for a different meaning.

`notice_read`, `scrap`, `card_19`, `tag_07`, `false_cell`, `live_cell`, `lamp_on`, `desk_open`, `staff_key`, `spare_key`, `staff_door_open`, `cleared`

`clock`, `phone`, `sofa_dent`, `chair` need no flags unless we care that they were tried.

## Assets to make

- Dress `lobby_room.glb` abandoned when the room is built. Dust, tote on its side, empty chair. No living staff.
- Notice, stamp card, rope tag, guest-book pages: pictures you can read, not paragraphs of Label3D.
- Two keys that do not look the same. Ledger. Bell. Lamp. Corroded cell and live cell.

## Do not

Seat anyone. Shop tab. Daylight HUD. A chance door that launches a slot, poker, or roulette scene. The code `418` or `1907` called a jackpot. A timer.
