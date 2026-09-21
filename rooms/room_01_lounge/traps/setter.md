# setter

- **ids:** `setter`, `reel_0`, `reel_1`, `reel_2`. Slip is `slip` (no separate trap).
- **Status:** open
- **Object:** `Cabinet_1` at `(0, 0, -2.15)`, tray, three centre cells of the reel window.
- **Code:** `_build_cabinets`, `_wire_reels`, `_use_tray`, `_cycle_reel`, `_do_jackpot`

## Expected

Dark until fed. Insert 3 coins, then click the three centre cells to pineapple, leaf, coconut (P, L, C). Opens `jackpot`, slip `418`, till light. Too early: "Feed the tray first."

## Now

The tray mark is one box on the whole cabinet: size `(1.2, 2.2, 1.0)` centred at local `(0, 1.1, 0.4)`. Its front face is local `z = 0.9` (world `z = -1.25`).

The clickable cells are `Cell_1_1`, `Cell_2_1`, `Cell_3_1` (middle row, middle three of five columns). Each use box is `(0.14, 0.17, 0.08)` on a cell at about local `z = 0.40`. Those boxes sit inside the tray box.

`_update_hover` returns the first hit and walks parents only. A look at a symbol hits `setter` first. `reel_0..2` never become the hover id, so `_cycle_reel` never runs.

Feeding coins is the `setter` use. It does not require the coin to be the selected slot. It checks `EscapeInventory.count_of("coin")`. That part is untested in play, and it is blocked by [coin.md](coin.md) anyway.

On P-L-C, `_do_jackpot` shows the slip at `(-0.4, 1.05, -1.45)`, sets the till light, and says the window paid. The slip is a Godot quad with a `Label3D`, not a paper in the tray mesh.

## Errors

### open — centre symbols cannot be set

Seen in code, not yet played. The tray volume covers `reel_0`, `reel_1`, and `reel_2`. The window cannot be set to P-L-C, so the slip, the jammed hint, and the till never start.

## Check

- [ ] Look at the tray: hint is the tray, not a symbol
- [ ] Look at each centre symbol: hint is that symbol (`reel_0`, `reel_1`, `reel_2`), not the tray
- [ ] Use on a symbol before 3 coins says "Feed the tray first" and does not change it
- [ ] Three coins go in. Each centre cell cycles S, P, L, C
- [ ] P then L then C shows a readable slip `418` and sets `jackpot`
- [ ] The other two columns are not required
