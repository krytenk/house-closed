# jammed

- **id:** `jammed`
- **Status:** ok
- **Played:** 2026-09-21. Before the pay: "Hopper jammed." After: the last digit is 8.
- **Object:** `Cabinet_2` at `(2.5, 0, -2.15)`
- **Code:** `_build_cabinets`, `_use` branch `jammed`

## Expected

Dead hopper. Use after the jackpot says the last digit is 8. Too early: "Hopper jammed."

## Now

One use box on the cabinet front. Use only calls `_say`. It grants nothing.

## Errors

None. Both lines were heard in play on 2026-09-21.

## Check

- [x] Before the jackpot, use says "Hopper jammed."
- [x] After the jackpot, use says the last digit is 8
- [x] It does not award an item or open the door
