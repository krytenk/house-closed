# lantern

- **id:** `lantern`
- **Status:** not checked
- **Object:** `LanternFuse` at `(-2.2, 2.35, 1.4)`, plus a Godot flicker light on that point
- **Code:** `_build_room`, `_use` branch `lantern`

## Expected

Flicker. Use unscrews a fuse into the inventory. After that the socket is empty.

## Now

The mark is on the lantern mesh. First use sets `fuse`, adds item `fuse`, and drops the flicker energy to 0.15. It does not hide `LanternFuse` or `LanternCage`. Not played.

## Errors

None recorded.

## Check

- [ ] The hanging lantern can be looked at and used
- [ ] One use adds a fuse and the flicker stops
- [ ] A second use says the socket is empty and does not add another fuse
- [ ] The fuse can be carried to the register. See [register.md](register.md)
