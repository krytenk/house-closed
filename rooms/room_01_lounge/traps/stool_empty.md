# stool_empty

- **id:** `stool_empty`
- **Status:** ok
- **Played:** 2026-09-22. Use on `Stool_1` tipped it and said dust and a dead match. No item.
- **Object:** `Stool_1`, the stool beside the notebook
- **Code:** `_dress` marks `Stool_1`. `_wobble_stool` tips it and puts it back.

## Expected

A stool. Use wobbles it and gives nothing. Red herring. Fail look is the wobble, not a reward.

## Now

`Stool_1` (`x = -0.55`, beside the notebook) carries the use. Use tips it a few degrees and returns it. The line is still dust and a dead match. No item.

## Errors

### fixed — the wobble was an empty box

Seen in play. `Stool_1` tips and settles. The other three stools are still only collision.

## Check

- [x] Use is on a visible stool, and that stool moves
- [x] The other stools are not this trap
- [x] Use grants no item and no flag that the door needs
