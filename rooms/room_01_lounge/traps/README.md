# Room 01 trap review

One file per trap. This is the play check for `ROOM.md`. Design stays in `ROOM.md`. Do not mark a file `ok` from reading code.

Status values:

| Status | Meaning |
|---|---|
| `open` | A known error is listed in that file |
| `not checked` | No known error. Not confirmed in play |
| `ok` | Check list in that file passed in play |

Recorded 2026-09-21. Only `boards` is `ok`.

## Entries

| File | id | Status | What is wrong |
|---|---|---|---|
| [door.md](door.md) | `door` | not checked | Unlock hides `Chain` only. `Padlock` is a separate mesh and is never hidden. Not played. |
| [bird.md](bird.md) | `bird` | open | E turns it and the coins land. Drag, and a full seven-coin check, are not done. |
| [coin.md](coin.md) | `coin` | open | Floor pickup works for one coin. All seven, and reload, are not checked. |
| [setter.md](setter.md) | `setter`, `reel_0..2` | open | Tray use box covers the three symbol cells, so the ray never reaches them. Seen in code. |
| [jammed.md](jammed.md) | `jammed` | not checked | |
| [register.md](register.md) | `register` | open | Till light turns on when the window pays, while the hint still says the screen is dark until the fuse is in. Seen in code. |
| [lantern.md](lantern.md) | `lantern` | not checked | |
| [house_line.md](house_line.md) | `house_line` | not checked | |
| [stool_note.md](stool_note.md) | `stool_note` | not checked | |
| [boards.md](boards.md) | `boards` | ok | Sheet is behind the boards until Use pulls it out. |
| [plinth.md](plinth.md) | `plinth` | open | Handler exists. No plinth in the room. Seen in code. |
| [stool_empty.md](stool_empty.md) | `stool_empty` | open | Use volume is an empty point, not a stool. Seen in code. |
| [save.md](save.md) | (all) | open | Flags write to disk and are never loaded. A coin in hand is not stored. |

## Critical path

Wake, bird, coins, house line, three coins in the tray, P-L-C, slip `418`, fuse, till, key, door.

Blocked now by setter and save. One coin can be picked up. The window notice can be taken. The door has not been reached in a checked play.
