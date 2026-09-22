# House Closed (this repo)

Current product: first-person locked rooms in Paloma House.
SSoT: `docs/HOUSE_CLOSED.md`.
Then pipeline / interactables / assets / traps. Then **only** the next `rooms/room_NN_*/ROOM.md`.
Palm Atoll casino (`docs/PALM_ATOLL_BUILD_SPEC.md`) is archive — do not resume it here.

Still: no cash-out, no real-money, no ChanceRng on a puzzle, no children as characters.

## Product laws (fail the build if broken)

- Entertainment only. No cash-out, gift cards, crypto, prize redemption, Sweeps, secondary market.
- Three tokens only: Daylight (never sold), Shells (only wallet), Cosmetics (zero power).
- A purchase MUST NOT change RNG, RTP, strips, weights, shuffle, AI, or prize tables.
- No deficit-selling, fake timers, mid-spin shop, raids, affection gacha, VIP host pressure.
- Chance sits behind labeled doors: `SLOTS` / `POKER` / `ROULETTE`.
- Age gate 18+ (19+ if locale is BC/CA). Boot and every IAP sheet: `FOR FUN ONLY. YOU CANNOT WIN REAL MONEY.`
- Geo-block Washington State chance-play and IAP until counsel says otherwise.
- No P2P Shell/credit transfer. No children as characters. No unlabeled AI at human tables.

## File ownership

Director only: `project.godot`, `export_presets.cfg`, `systems/*`, `data/copy.json`, `data/tile_defs.json`, `ui/boot/`, `ui/hud*`, `README.md`, this file.

Slice-private directories must not edit director files. Need a new autoload or copy key? Stop. Director adds it.

## Tests

```
godot --headless -s res://tests/run_all.gd
```

## Forbidden strings

Grep must be clean of: `whale`, `proto-whale`, `coin drain`, `sweeps`, `cash out`, `redeem`, `WIN BIG`, `LAST CHANCE`, `Beads` (as currency).

## UI words

Door signs all caps verbs only. Forbidden UI: PLAY NOW, WIN BIG, JACKPOT CASH, LAST CHANCE, HURRY.
