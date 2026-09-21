# bird

- **id:** `bird`
- **Status:** open
- **Object:** Loose pelican built on `Cabinet_0` (`build_statue_bird`). `BirdPivot` in the lounge model is not used.
- **Code:** `_build_cabinets`, `_nudge_bird`, `_finish_turn`, `_dump_coins`

## Expected

Cocked on a brass pin, OUT OF ORDER tape. Hold and drag, or nudge with E, to about 180°. Opens seven coins on the floor. Too early: "It turns on the pin. Keep going."

## Now

The statue starts at 32° on Y. Drag rotates `Spin`. E adds 45°. Past 150° from zero, `_dump_coins` runs. Tape label is a `Label3D` on the cabinet.

2026-09-21: three E nudges spent the statue and put seven coins on the floor. Hold-drag was not tried. See [coin.md](coin.md).

## Errors

### open — coin reload is still unchecked

The dump itself lands on the floor and one coin was taken. See [coin.md](coin.md). Collecting all seven and reloading are still open.

## Check

- [ ] The statue reads as a bird on the broken machine, not the tiny crest pelican (that one is hidden)
- [ ] Hold-drag and the E nudge both turn it
- [ ] Short of the turn, the fail line shows and no coins appear
- [ ] A full turn dumps seven coins that pass [coin.md](coin.md)
