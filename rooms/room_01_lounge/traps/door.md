# door

- **id:** `door`
- **Status:** ok
- **Played:** 2026-09-21. No key: the till line, door stays shut. With the key: chain and padlock both hide, the door yaws open, then the lobby line.
- **Object:** `HallDoor` + `Chain` (`art/models/abandoned_lounge.tscn`). `Padlock` is a third mesh beside them.
- **Code:** `_build_door`, `_use_door`, `_finish` in `lounge_escape.gd`

## Expected

Chain and padlock. Use with the house key. Chain drops, door opens, then: "Room 01 clear. The lobby is still sealed." Too early: "House key is with the till. Till is dead."

## Now

`HallDoor` is marked `door`. With the key, `_use_door` takes the key, sets `door_open`, hides `Chain` and `Padlock`, and yaws the door -75°. It does not load Room 02.

## Errors

### fixed — the padlock stayed after the chain dropped

Both meshes hide together now. 2026-09-21: without the key the door stayed shut and said the key is with the till. With the key, chain and padlock were both hidden, the door sat at -75°, and the screen said the lobby is still sealed.

## Check

- [x] Chained door shows a hint before the key
- [x] Use without the key does not open it
- [x] Use with the key hides the chain and the padlock
- [x] The slab swings; the player is not left looking at a spinning centred board
- [x] Finish line names the lobby and does not load it
