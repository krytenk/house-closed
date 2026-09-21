# register

- **id:** `register`
- **Status:** open
- **Object:** `Register` on the bar, `(0.85, 1.12, 3.55)` in the lounge model. Screen and drawer are separate meshes.
- **Code:** `_build_register`, `_use_register`, `_pad_digit`, `_do_jackpot`

## Expected

Dark screen. After the window pays, put the fuse in, then enter `418`. Opens the house key. Too early: till is dead, or "something pops in the roof."

## Now

`_use_register` waits for `jackpot`, then takes a fuse if `fuse_in` is false, then opens the pad. `418` sets `code_ok` and `has_key` and adds `key`. The pad has digits and Close. This path has not been played. It is downstream of [setter.md](setter.md) and [lantern.md](lantern.md).

## Errors

### open — till light and the dark-screen line disagree

`ROOM.md` says the jackpot opens the till light, and also that the register stays a dark screen until the fuse is in. `_do_jackpot` sets `_register_light` to energy 0.8 (green) immediately. The hint for `register` after the jackpot and before the fuse is still "Screen dark — something pops in the roof."

Seen in code, not played. Decide which look is true before calling this trap checked: light on at the pay, or light on only after the fuse.

## Check

- [ ] Before the jackpot, use says the till is dead and the pad does not open
- [ ] After the jackpot, without a fuse, use does not open the pad
- [ ] With a fuse, one use inserts it and the screen is visibly on
- [ ] Wrong digits do not give the key
- [ ] `418` gives one house key and closes the pad
- [ ] A second use says the drawer is empty
