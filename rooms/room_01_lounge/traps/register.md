# register

- **id:** `register`
- **Status:** ok
- **Played:** 2026-09-21. Screen stays dark until the fuse. `419` does nothing. `418` gives the house key.
- **Object:** `Register` on the bar, `(0.85, 1.12, 3.55)` in the lounge model. Screen and drawer are separate meshes.
- **Code:** `_build_register`, `_use_register`, `_pad_digit`, `_do_jackpot`

## Expected

Dark screen. After the window pays, put the fuse in, then enter `418`. Opens the house key. Too early: till is dead, or "something pops in the roof."

## Now

The pay line says the till clicks. The green light and the screen stay off until the fuse is in. Then `_light_the_screen` turns the screen green and opens the pad.

Polish, from play: the pad is a panel in the middle of the screen, so it can be used from behind the till. Put the keypad on the front of the till, make the till more detailed, and refuse the pad from the back. Not done.

## Errors

### fixed — the till glowed while the line said the screen was dark

The light now waits for the fuse. 2026-09-21 play: before the pay, use said the till is dead. After the pay, with no fuse, the light energy was 0 and the line was the dark-screen line. The fuse made the screen green. `419` left the pad open and gave no key. `418` closed it and put a house key in the bar.

## Check

- [x] Before the jackpot, use says the till is dead and the pad does not open
- [x] After the jackpot, without a fuse, use does not open the pad
- [x] With a fuse, one use inserts it and the screen is visibly on
- [x] Wrong digits do not give the key
- [x] `418` gives one house key and closes the pad
- [x] Looking at it after that says the drawer is empty
