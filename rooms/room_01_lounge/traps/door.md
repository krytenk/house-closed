# door

- **id:** `door`
- **Status:** not checked
- **Object:** `HallDoor` + `Chain` (`art/models/abandoned_lounge.tscn`). `Padlock` is a third mesh beside them.
- **Code:** `_build_door`, `_use_door`, `_finish` in `lounge_escape.gd`

## Expected

Chain and padlock. Use with the house key. Chain drops, door opens, then: "Room 01 clear. The lobby is still sealed." Too early: "House key is with the till. Till is dead."

## Now

`HallDoor` is marked `door`. With the key, `_use_door` takes the key, sets `door_open`, hides `Chain`, and yaws the door -75°. It does not hide `Padlock`. It does not load Room 02.

The use box is deeper than the door slab, so a look from inside the room should hit `Use_door` before the door's `Solid`. Not confirmed in play.

## Errors

None confirmed. One code note, not yet seen in play: the padlock mesh stays after the chain is hidden.

## Check

- [ ] Chained door shows a hint before the key
- [ ] Use without the key does not open it
- [ ] Use with the key hides the chain and the padlock
- [ ] The slab swings; the player is not left looking at a spinning centred board
- [ ] Finish line names the lobby and does not load it
