# jammed

- **id:** `jammed`
- **Status:** not checked
- **Object:** `Cabinet_2` at `(2.5, 0, -2.15)`
- **Code:** `_build_cabinets`, `_use` branch `jammed`

## Expected

Dead hopper. Use after the jackpot says the last digit is 8. Too early: "Hopper jammed."

## Now

One use box on the cabinet front, same size as the setter tray. No reel cells. Use only calls `_say`. It grants nothing. Not played. It cannot be reached in a full run until [setter.md](setter.md) is fixed.

## Errors

None recorded.

## Check

- [ ] Before the jackpot, use says "Hopper jammed."
- [ ] After the jackpot, use says the last digit is 8
- [ ] It does not award an item or open the door
