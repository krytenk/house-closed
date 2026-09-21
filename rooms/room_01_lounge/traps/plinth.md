# plinth

- **id:** `plinth`
- **Status:** open
- **Object:** None in the room.
- **Code:** `_hint_for` and `_use` branch `plinth` only

## Expected

Optional. Empty plinth. Pry it. Opens `light` (flashlight). Not on the critical path.

## Now

No node is named plinth. Nothing calls `_mark` with `plinth`. The cabinet builder's "plinth" is the machine base, not this trap. `_spray_bird_on_wall` is unused and is not a plinth.

## Errors

### open — the optional flashlight has no object

Seen in code. The flag `flashlight` and the item `light` cannot be reached. The trap cannot be reviewed in play until a plinth mesh exists and is marked.

## Check

- [ ] An empty plinth is in the room and can be looked at
- [ ] Use once adds Flashlight and does not add a second one
- [ ] Skipping it still allows the door
