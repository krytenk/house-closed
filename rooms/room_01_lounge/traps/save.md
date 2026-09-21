# save

- **id:** `Save.progress.escape.room_01`
- **Status:** open
- **Object:** Not a trap. Shared by every trap above.
- **Code:** `_persist` in `lounge_escape.gd`. Inventory: `systems/escape_inventory.gd`

## Expected

Flags persist under `Save.progress.escape.room_01`. A later visit restores the hour: bird, coins, notebook, house line, tray count, jackpot, fuse, code, key, door, flashlight.

## Now

`_persist` copies `_flags` into that dictionary and calls `Save.write_disk`. `_ready` always calls `EscapeInventory.reset()` and builds a fresh `_flags` table. Nothing reads `escape.room_01` back.

`_pickup_coin` does call `_persist`, but a coin is not a flag. The write does not store how many coins are in hand. A flag restore would still not put coins, the notebook, the fuse, or the key back in the bar unless the load path rebuilt them.

## Errors

### open — the hour does not survive leaving the room

Seen in code, not played. Writes happen. Loads do not. Coins in hand are not part of the write.

## Check

- [ ] Turn the bird, pick up a coin, read the plaque, leave the room, come back
- [ ] Those flags and the coin are still true
- [ ] A cleared door stays cleared and does not play the wake as a new hour
- [ ] A later room does not reuse these flag names
