# boards

- **id:** `boards`
- **Status:** ok
- **Played:** 2026-09-21. Use pulls the sheet out. It must not be readable while it is still behind the boards.
- **Object:** Godot group `WindowBoards` on `Ocean` `(0, 1.4, -4.92)`. Model boards `WindowBoard_0..2` are hidden.
- **Code:** `_board_the_window`, `_use` branch `boards`

## Expected

Boarded ocean window. Use reads the newspaper behind the boards: "PALOMA HOUSE CLOSED — STAFF LEFT THE TILL."

## Now

Six overlapping planks cover the window. `WindowNotice` sits behind that wood (`z` behind the plank backs). The words are not visible until Use. The use box is on the front of the boards. Use pulls the sheet out to the camera, holds it, then removes it. Flag `notice`.

## Errors

### fixed — the newspaper behind the boards could not be accessed

Was seen in play. There was no paper, only a hint line. 2026-09-21: the notice was readable in the gap, use brought it out in front of the camera, and the gap was empty afterward with the line on screen.

## Check

- [x] The ocean window reads as wood boards, not a bare dark quad
- [x] The sheet cannot be read while it is behind the boards
- [x] Use pulls that paper out. The closed-house line is on the paper
- [x] After it is taken, the boards stay up and the line remains
