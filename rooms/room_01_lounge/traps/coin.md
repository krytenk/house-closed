# coin

- **id:** `coin`
- **Status:** open
- **Played:** 2026-09-21. Seven coins sat on the floor. One was taken. Six stayed. The bar read `>1 Brass coin`.
- **Object:** Seven brass disks spawned by the bird. Not a mesh in the lounge model.
- **Code:** `_dump_coins`, `_pickup_coin`

## Expected

Seven separate brass coins on the floor in front of the broken machine. Look and use picks one up into the inventory as `coin`. Three of them feed the centre tray.

## Now

`_dump_coins` lays seven disks on the floor in front of `Cabinet_0`, two rows, spacing 0.26. Height is `y = 0.03`. The collider is a short cylinder, radius 0.11. Pickup uses the body the crosshair is already on, then writes the save.

Look-down reaches about 60° so the floor in front of you is in the ray.

## Errors

### fixed — coins floated and could not be picked up

Was seen in play. 2026-09-21: after the bird turned, seven coins were on the floor, the hint was "Pick up a brass coin", and use took one. The bar showed `>1 Brass coin` and six coins were left.

Still open: picking up all seven, and the coin surviving a reload. See [save.md](save.md).

## Check

- [x] After the bird turns, seven coins rest on the floor, not in the air
- [x] A coin can be looked at. Hint: "Pick up a brass coin"
- [x] Use takes that coin and adds it to the bar
- [ ] All seven can be collected
- [ ] They are still in the bar after leaving and re-entering the room
