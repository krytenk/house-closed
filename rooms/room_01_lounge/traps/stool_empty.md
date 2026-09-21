# stool_empty

- **id:** `stool_empty`
- **Status:** open
- **Object:** None. Invisible node `StoolEmpty`.
- **Code:** `_dress` calls `_mark_at(Vector3(-2.4, 0.55, 2.6), "stool_empty", ...)`

## Expected

A stool. Use wobbles it and gives nothing. Red herring. Fail look is the wobble, not a reward.

## Now

The four stools in the model are `Stool_0..3` at `x = -1.6, -0.55, 0.55, 1.6`, `y = 0`, `z = 2.85`. They have `Solid` collision and no `use_id`.

The use volume is a 0.5 m box at `(-2.4, 0.55, 2.6)`, left of the leftmost stool and not parented to one. Looking at a real stool hits `Solid` and gets no hint. The hint "It wobbles. Nothing." only appears on that empty box.

## Errors

### open — the red herring is not a stool

Seen in code, not played. The trap cannot be reviewed on the object it names.

## Check

- [ ] Use is on a visible stool, and that stool moves or reads as a wobble
- [ ] The other stools do not also pretend to be this trap unless they are marked the same way
- [ ] Use grants no item and no flag that the door needs
