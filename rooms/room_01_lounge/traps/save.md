# save

- **id:** `Save.progress.escape.room_01`
- **Status:** ok
- **Played:** 2026-09-21. A cleared hour reopened on the end card. A fresh hour kept one coin, six on the floor, the turned bird, and the house line.
- **Object:** Not a trap. Shared by every trap above.
- **Code:** `_persist` in `lounge_escape.gd`. Inventory: `systems/escape_inventory.gd`

## Expected

Flags persist under `Save.progress.escape.room_01`. A later visit restores the hour: bird, coins, notebook, house line, tray count, jackpot, fuse, code, key, door, flashlight.

## Now

`_persist` writes `room_01` flags, `room_01_items`, and `room_01_reels`. `_restore_progress` reads them after the room is built. Coins still on the floor are `7` minus coins in hand minus coins in the tray. A cleared room shows the end card and does not play the wake line.

## Errors

### fixed — the hour did not survive leaving the room

2026-09-21: quit on the cleared door, relaunched, and the end card was already up, chain and padlock hidden, door open. Wiped that hour, turned the bird, took one coin, read the house line, quit, relaunched. The bar still had one brass coin, six coins were on the floor, the bird was turned, the house line flag was set, and the door was still locked.

## Check

- [x] Turn the bird, pick up a coin, read the plaque, leave the room, come back
- [x] Those flags and the coin are still true
- [x] A cleared door stays cleared and does not play the wake as a new hour
- [x] A later room does not reuse these flag names
