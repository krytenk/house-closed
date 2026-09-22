# Room 01 trap review

One file per trap. This is the play check for `ROOM.md`. Design stays in `ROOM.md`. Do not mark a file `ok` from reading code.

Status values:

| Status | Meaning |
|---|---|
| `open` | A known error is listed in that file |
| `not checked` | No known error. Not confirmed in play |
| `ok` | Check list in that file passed in play |

Recorded 2026-09-21. `boards`, `setter`, `jammed`, `register`, `door`, and `save` are `ok`.

## Entries

| File | id | Status | What is wrong |
|---|---|---|---|
| [door.md](door.md) | `door` | ok | Chain and padlock both drop. Lobby line. Played 2026-09-21. |
| [bird.md](bird.md) | `bird` | open | E turns it and the coins land. Drag, and a full seven-coin check, are not done. |
| [coin.md](coin.md) | `coin` | open | Pickup and reload work. All seven in one sitting not checked. |
| [setter.md](setter.md) | `setter`, `reel_0..2` | ok | P, L, C pays slip 418. Played 2026-09-21. |
| [jammed.md](jammed.md) | `jammed` | ok | Both lines heard in play. |
| [register.md](register.md) | `register` | ok | Screen stays dark until the fuse. `418` gives the key. Played 2026-09-21. |
| [lantern.md](lantern.md) | `lantern` | not checked | |
| [house_line.md](house_line.md) | `house_line` | not checked | |
| [stool_note.md](stool_note.md) | `stool_note` | not checked | |
| [boards.md](boards.md) | `boards` | ok | Sheet is behind the boards until Use pulls it out. |
| [plinth.md](plinth.md) | `plinth` | open | Handler exists. No plinth in the room. Seen in code. |
| [stool_empty.md](stool_empty.md) | `stool_empty` | open | Use volume is an empty point, not a stool. Seen in code. |
| [save.md](save.md) | (all) | ok | Quit and relaunch keeps the hour, including a coin in hand. |

## Critical path

Wake, bird, coins, house line, three coins in the tray, P-L-C, slip `418`, fuse, till, key, door.

The critical path has been played through to the lobby line. Still open: bird drag, all seven coins in one sitting, the lantern's second use, the house line as a looked-at object, the flashlight plinth, and the empty stool.

## Changes

- Done: progress lines are larger. Bottom line is 32 px, the bar under it is 24 px. Wake, the end card, and the till pad are unchanged.
- Done: the slip lies on the centre tray floor, local `(0, 0.512, 0.54)` on `Cabinet_1`, not floating above it.
- Started: the keypad is on the front of the till. It does not answer from behind. The till is still a simple mesh. Baked detail is still polish.
- Started: wake blinks dark, light, dark, then the floor line. Reads of the notebook, house line, notice, and slip use a large spoken line. A full voice track is not recorded.
