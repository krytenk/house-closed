# house_line

- **id:** `house_line`
- **Status:** not checked
- **Object:** Godot plaque `HouseLine` on the left wall at `(-6.78, 1.42, -0.55)`, quads `sym_P.png`, `sym_L.png`, `sym_C.png`
- **Code:** `_build_house_line`, `_use` branch `house_line`

## Expected

Three framed symbols. Use or look sets flag `wallpaper` (the house line was read). Not a gate. The combination is pineapple, leaf, coconut.

## Now

The plaque is marked `house_line`. Use sets `wallpaper` and says the line. `_dress` hides the old model nodes `PaintPineapple`, `PaintLeaf`, `PaintCoconut`, `PaperFlap`, `PaperCurl`, `WallpaperLeft`.

`_peeling_paper`, `_pull_paper`, and `_spray_bird_on_wall` are still in `lounge_escape.gd` and are never called. Do not bring the peel back. The plaque replaced it because there is no paper texture on a flap.

Not played.

## Errors

None recorded.

## Check

- [ ] The left wall shows three framed symbols, not loose fruit shapes
- [ ] Use reads pineapple, leaf, coconut
- [ ] Nothing peels, and the flag stored is `wallpaper`
- [ ] The reels can still be solved without using this plaque (clue, not a lock)
