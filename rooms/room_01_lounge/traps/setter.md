# setter

- **ids:** `setter`, `reel_0`, `reel_1`, `reel_2`. Slip is `slip` (no separate trap).
- **Status:** ok
- **Played:** 2026-09-21. Tray and the three centre cells are separate. P, L, C paid slip 418.
- **Object:** `Cabinet_1` at `(0, 0, -2.15)`, tray, three centre cells of the reel window.
- **Code:** `_build_cabinets`, `_wire_reels`, `_use_tray`, `_cycle_reel`, `_do_jackpot`

## Expected

Dark until fed. Insert 3 coins, then click the three centre cells to pineapple, leaf, coconut (P, L, C). Opens `jackpot`, slip `418`, till light. Too early: "Feed the tray first."

## Now

The tray mark is only the tray: size `(0.76, 0.32, 0.40)` at local `(0, 0.52, 0.68)`. Each centre cell has its own use box pushed in front of the cabinet body, so the ray can hit `reel_0`, `reel_1`, and `reel_2`.

On P-L-C the slip shows `418`. The till stays dark until the fuse. The click is the line, not a green light.

The slip lies on the tray floor, parented to `Cabinet_1` at local `(0, 0.512, 0.54)`.

## Errors

### fixed — centre symbols could not be set

The tray volume used to cover the cells. 2026-09-21 play: a symbol before any coins said "Feed the tray first" and stayed on S. Three coins went in. The cells cycled to P, L, C. The slip read 418 and `jackpot` was set. The jammed hopper then said the last digit is 8.

## Check

- [x] Look at the tray: hint is the tray, not a symbol
- [x] Look at each centre symbol: hint is that symbol (`reel_0`, `reel_1`, `reel_2`), not the tray
- [x] Use on a symbol before 3 coins says "Feed the tray first" and does not change it
- [x] Three coins go in. Each centre cell cycles S, P, L, C
- [x] P then L then C shows a readable slip `418` and sets `jackpot`
- [x] The other two columns are not required
