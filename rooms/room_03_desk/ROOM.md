# Room 03 — The Desk

**Scene key:** `room_03`  
**Play file:** `rooms/room_03_desk/desk_escape.tscn` — **not created**  
**Old scene:** `world/hotel_lobby/desk_shop.tscn` (IAP shop — **do not** enable SKUs)  
**Status:** Plan only.

The shop was a tab on Mara’s desk. Here it is a locked back office: pigeonholes, a dead terminal, a cash drawer with no money, staff keys to the cabana.

## Working

Enter from lobby staff door. Solve office traps. Unlock **Cabana hall** from this side. Line: *The cabana is still sealed.*

## Layout (intended)

Small room behind the lobby desk: counter back, pigeonholes, safe, coat peg, staff roster, dead CRT, cash drawer.

| Socket | Role |
|---|---|
| `PlayerSpawn` | Door from lobby |
| `Pigeonholes` | Named slots (Nia, Arthur, Jules — empty, searchable) |
| `Safe` | Combination |
| `Terminal` | Dead screen; later shows a room number |
| `CashDrawer` | Empty of cash; holds a token or keycard |
| `Roster` | Paper with a shift code |
| `Coat` | Optional pocket |
| `CabanaBolt` | Exit |

## Traps

| id | Object | Locked look | Action | Opens | Too early |
|---|---|---|---|---|---|
| `safe` | Small safe | Dial | Code from roster + notice (deterministic, written in-world) | Cabana keycard | Wrong code: click, reset. No lockout timer. |
| `drawer` | Cash drawer | Stuck | Use staff key from Room 02 **or** a desk crank found here | Token / blank keycard | “Won’t slide.” |
| `terminal` | CRT | Black | Fuse or plug under desk | Shows `CABANA 04` | Dark |
| `pigeon_arthur` | Hole | Envelope | Take | Roster fragment | Empty if already taken |
| `coat` | Jacket | Hanging | Search | Optional battery | Lint |
| `cabana_bolt` | Door to cabana hall | Card reader dead | Keycard after safe | Room 03 clear | Beep. Dark. |

## Intended hour

Office search. Combination is on paper in the room (roster × pigeonhole number). No purchase, no SKU list as a puzzle that sells anything. A faded SKU sheet on the wall may exist as **set dressing only** (cosmetics names, zero power, not usable).

## Do not

Wire `iap_stub.gd`. Deficit-selling copy. “Last chance” pack art.
