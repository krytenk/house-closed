# PALM ATOLL — GROK BUILD SPECIFICATION
## Version 1.1 LOCKED — 17 September 2026
## Single source of truth. Do not invent. Do not stub and call it done.

If a MUST item is missing, the build is **NOT DONE**.  
If a MUST NOT item exists in the build, the build is **FAILED**.  
If two comments in this file ever seem to disagree, keep the **stricter anti-predatory** rule.

---

# 0. WHAT THIS IS

**Title:** Palm Atoll  
**Island:** Paloma Atoll  
**Product sentence:** A resort you live on, with a casino you can visit — not a casino wearing a lei.  
**Genre:** Island board-path resort + optional labeled chance rooms + skill breaks  
**Audience:** 18+ (19+ copy if locale is British Columbia)  
**v1 platforms:** Android ARM64, Windows x86_64, Linux x86_64  
**Engine:** Godot 4.3+  
**Not in v1:** iOS, cash-out, sweeps, P2P transfers, raids, affection gacha, shooter skins, ads, season 2 island

---

# 1. PRODUCT LAWS (FAIL THE BUILD IF BROKEN)

**P0.** Entertainment only. No cash-out, no gift cards, no crypto, no prize redemption, no Sweeps Coins, no secondary market.

**P1.** Three tokens only:
1. **Daylight** — movement. Never sold. No SKU. No product id.
2. **Shells** — the only wallet. Build, decorate, lounge stakes, roulette stakes, poker buy-in.
3. **Cosmetics** — IAP / season pass. Zero power.

On entering Tiki Lounge, Coral Salon, or Sunset Cabana, Shells convert 1:1 into table credits. On exit, leftovers convert 1:1 back to Shells. HUD shows **one number**.  
Do not ship Beads, Gold Coins, Sweeps, or a second wallet.

**P2.** A purchase MUST NOT change RNG, RTP, reel strips, wheel weights, roulette mapping, card shuffle, AI parameters, or prize tables. Same math for payer and F2P.

**P3.** F2P can complete a **20-minute satisfying session every calendar day** with no ad and no IAP.

**P4.** No deficit-selling. No fake timers on packs. No “Shells almost gone” pushes. No mid-spin shop. No raid that damages a friend’s build. No gold-untradeable timed stickers. No affection / outfit gacha. No VIP host pressure.

**P5.** Chance sits behind labeled doors: `SLOTS` / `POKER` / `ROULETTE`. The island path is not a slot.

**P6.** Age gate 18+ at first launch (19+ copy if locale is BC/CA). Boot screen and every IAP sheet:

> FOR FUN ONLY. YOU CANNOT WIN REAL MONEY.

**P7.** Geo-block **Washington State** chance-play and IAP until counsel says otherwise. No P2P Shell/credit transfer.

**P8.** Self-exclusion, spend caps, session timer ship in v1. Honor them. Never gift currency to a user who asked to stop.

**P9.** Human poker tables never seat unlabeled AI.

**P10.** No children as characters. All presented characters are adults.

---

# 2. DEFINITION OF DONE

Call the game **done** only if every box is true. Otherwise reply `NOT DONE` and list the IDs.

## Boot
- [ ] D1 Age gate → disclaimer lock screen → Paloma House lobby → island. First run cannot skip.
- [ ] D2 Android, Windows, and Linux each complete D1 on a clean install.

## Anti-predatory session
- [ ] T1 Fresh install, no IAP: play 20 minutes. Must walk ≥12 tiles, add ≥1 Tide piece OR decorate 1 item, open Cabana OR Lounge, finish 1 skill game. Must NOT see a blocking shop, a fake countdown pack, or empty Daylight before minute 15 if the bar started full.
- [ ] T2 After a mock IAP, 10,000 Palm Reels spins vs 10,000 pre-IAP spins: chi-square p > 0.05 on win-size buckets. Fail if tighter.
- [ ] T5 No SKU named Daylight, Energy, or Dice.
- [ ] T6 Disclaimer + age gate before island.
- [ ] T7 Cool-off locks IAP + chance staking; island still loads.
- [ ] T8 Friend / dock visit cannot damage host buildings or steal Shells.
- [ ] T9 Every chance door label matches the verb.
- [ ] T10 All three platform artifacts boot the same first island.

## Rooms and toys
- [ ] AT-MAP-01 Full Daylight 40 can complete one 24-tile lap without IAP.
- [ ] AT-MAP-02 No tile auto-launches a chance game. Doors need a second tap.
- [ ] AT-TM-01 Parts 1–6 place only in order. Cannot buy a part.
- [ ] AT-TM-02 Crank at 6/6 plays the full 8.0s chain and pays **exactly 40 Shells**.
- [ ] AT-TM-03 Crank at <6 parts does not open a shop and pays no prize table.
- [ ] AT-ROOM-01 Tiki Lounge door `SLOTS` readable at walking height.
- [ ] AT-ROOM-02 Cabana sit flow shows `HUMAN` vs `PRACTICE (AI)` before credits move.
- [ ] AT-CHAR-01 No affection meter, no outfit-unlock-for-power.
- [ ] AT-ART-01 No magenta casino lobby in any default camera.
- [ ] T3 Human table never seats unlabeled AI.
- [ ] T4 AI cannot read other seats’ hole cards (unit test).

## Repo hygiene
- [ ] Grep clean of: `whale`, `proto-whale`, `coin drain`, `sweeps`, `cash out`, `redeem`, `WIN BIG`, `LAST CHANCE`, `Beads` (as currency).

---

# 3. TECH

## Engine and exports
- Godot 4.3+ (4.x LTS if available). GDScript.
- Exports:
  - Android APK + AAB, ARM64-v8a
  - Windows zip: `PalmAtoll.exe` + pck, x86_64
  - Linux `PalmAtoll.x86_64` + pck (AppImage optional)
- No iOS in v1.
- Input: touch + mouse + keyboard. Hit targets ≥ 48 dp.
- Esc = back. Space = confirm Walk / Crank on desktop.
- 60 fps target. Low-end Android: half-res water.
- Desktop 16:9. Android 19.5:9 / 20:9 portrait and landscape. Letterbox; **never crop the Tide Machine**.
- Offline-first. Human poker requires network; if offline, Human door: `Need a connection for human tables.` Practice AI always works.

## Project layout
```
res://
  project.godot
  systems/chance_rng.gd
  systems/ai_rng.gd
  systems/economy.gd
  systems/daylight.gd
  systems/play_safe.gd
  systems/save.gd
  systems/region_policy.gd
  systems/iap_stub.gd
  world/paloma_atoll.tscn
  world/board_loop.gd
  world/tide_machine/
  world/bungalow/
  world/hotel_lobby/
  rooms/tiki_lounge/
  rooms/sunset_cabana/
  rooms/coral_salon/
  minis/jetski_slalom/
  minis/coconut_shy/
  minis/recipe_mix/
  characters/
  ui/
  data/paytables/
  data/tile_defs.json
  data/copy.json
  art/seasons/paloma/
  audio/
  tests/
```

## RNG
`ChanceRng` (`res://systems/chance_rng.gd`) is the only source for slots, wheel, dive bonus, roulette pocket, board die, postcard draws.

API:
- `rand_int(max_exclusive) -> int`
- `rand_float() -> float`
- `weighted_index(weights: PackedInt32Array) -> int`

Poker cards also use ChanceRng Fisher–Yates.  
Poker **decisions** use `AiRng` only.

IAP, shop, ads, spend-cap, VIP events MUST NOT call ChanceRng and MUST NOT mutate its seed or tables.

Offline desktop: OS CSPRNG seed at boot. Log seed per session for support replay: given seed + bet, reproduce outcome.

---

# 4. ECONOMY (NUMBERS FROZEN)

## Daylight
- Cap **40**.
- Cost: **1 Daylight per tile stepped** (a die roll of 4 costs 4).
- Entering an interior costs 0 extra.
- Regen: **1 per 3 real minutes** while below cap.
- Full top-up to 40 at local **08:00** if current < 40.
- Start: 40.
- **MUST NOT be purchased.** If any shop SKU grants Daylight, FAIL.
- At 0 Daylight: player can stand, use lobby, Settings, Play Safe, decorate owned items. Cannot Walk, spin, deal, or start a mini. Copy: `Daylight returns with the clock.` **No shop prompt.** Button: `Return to Paloma House.`

## Shells
- Start: **1,000**.
- Daily 08:00 grant: **+200** if balance < 2,000 (do not inflate large balances).
- Pass PORCH (tile 00): **+25** once per calendar day.
- HUD: one Shells number.
- Floor: 0. Island + skill + Tide build + Practice poker remain available.

## Poker stacks
- Cash blinds **25 / 50**.
- Sit-n-Go buy-in **500**.
- Practice table: house credits that **never convert** to Shells.
- F2P can play AI practice forever.
- Human / SNG costs 500, earnable over a few days of play.

## Daily free session math (must make T1 true)
Full Daylight 40 = a full 24-tile lap + buffer.  
Starting 1,000 + tile grants + daily 200 covers ~40 Palm Reels at bet 1 and still leaves island sinks.

## Optional IAP (desk shop only)
| SKU | Price | Grants |
|---|---|---|
| `season_pass_paloma` | 7.99 / 6 weeks | Cosmetics track. No Tide parts. No odds change. +50 Shells added to the daily grant while active. |
| `bungalow_linen_set` | 4.99 | 6 furniture meshes, no stats |
| `felt_sunset_alt` | 2.99 | Alternate felt |
| `cabinet_skin_orchid` | 2.99 | Palm Reels cabinet skin |
| `shell_pack_small` | 4.99 | +800 Shells. Only at desk. Daily spend cap applies. |

First IAP extra confirm: amount in local currency + `Shells cannot be cashed out.`

No limited-time fake countdown. No contextual pack after a loss.

## Spend caps
- Daily IAP default **$15**, player-set **$0–$15**.
- Weekly default **$40**.
- Lower = instant. Raise = **48 hour cool-off**.

## Forbidden products
Daylight, energy, dice, Tide parts, better cards, higher RTP, streak insurance, raid shields.

---

# 5. ART BIBLE

Two cameras. Do not blend into one style.

## Outside — toy diorama
Chunky stylized 3D. Circular wooden boardwalk of oversized colorful tiles around a lagoon. Thatched bungalows. Bamboo Tide Machine. Shades the pelican on a piling. Small stylized adult guests on the path. Golden-hour key light.

## Inside — boutique hotel
Travel-magazine interiors. Linen, carved wood, lanterns, ocean in the open wall. Higher-fidelity adults. Cabinets still read as slots. Felt still reads as poker.

## Palette (source colors)
| Role | Hex |
|---|---|
| Lagoon teal | `#2EC4B6` |
| Deep water | `#0B6E6F` |
| Wet-sand gold | `#E2C290` |
| Coral | `#E07A5F` |
| Bamboo | `#C4A35A` |
| Lantern amber | `#F4A261` |
| Cream plaster | `#F7F1E3` |
| Ink | `#1B1B1B` |

**FORBIDDEN as primaries:** magenta `#FF00FF` range, casino chrome gold `#FFD700`.

## Cameras
1. Aerial diorama ~35°  
2. Walking height 1.6 m  
3. Dusk interior 35 mm  
4. Tide Machine hero 24 mm  

Board tokens: stylized. In-room player: higher fidelity. No photoreal pores on path tokens.

## Type and UI words
Door signs, carved wood, all caps verbs only: `SLOTS` `POKER` `ROULETTE` `TIDE MACHINE`.  
Forbidden UI: PLAY NOW, WIN BIG, JACKPOT CASH, LAST CHANCE, HURRY.

## Audio
Outside: low surf + distant steel pan.  
Tide Machine: physical Foley chain, no slot jingle.  
Slots: win jingle **only if net win ≥ stake**.  
Poker: quiet room.

---

# 6. CHARACTERS

**Player:** customizable adult avatar. Body types, linen, resort wear, swimwear as climate. Cosmetics do not change odds or Daylight. Default modest resort wear. No “hotter = better.”

**Shades:** brown pelican, oversized sunglasses. Steals then returns sunglasses on tile 09. Honk only. Never sells anything.

**Staff (named, persistent, not dateable)**
| Name | Role |
|---|---|
| Mara | Concierge, Paloma House lobby. Onboarding + Play Safe shortcut. Linen shirt, tablet. |
| Kenji | Poker dealer. Professional himbo energy, not sexualized. |
| Lila | Roulette croupier. Older glamorous, silver jewelry. |
| Mateo | Marina / jet-ski + Coconut Shy attendant. |
| Rafael | Kitchen pass / Recipe Mix. No affection meter. |

**Background guests (ambient, 18+ only)**
- Arthur — 60s, linen, book  
- Nia — 30s, tote, camera  
- Jules — towel on shoulder, friendly wave  
- Priya — sunhat, cocktail as prop  
- Sam & Devon — adult paddleboarders  

**Animals:** Shades, one lazy sea turtle on a marina piling, reef fish (decoration).

**No bartender hearts. No gift trees. No kids.**

---

# 7. PALOMA HOUSE (HOTEL / LOBBY)

Entered from porch tap (tile 00) and from HUD `House`.

**Porch:** wide steps, rattan fans, chalkboard `Paloma House`. Doors visible toward Lounge, Cabana, Salon, Lobby.

**Lobby:**
- Reception desk. Mara.
- Notice board: Daylight, Shells, Play Safe button.
- Two rattan sofas: Arthur reading, Nia with a tote. Ambient only.
- Stairs up = player suite (decorate).
- Hall left = Tiki Lounge.
- Hall right = Sunset Cabana.
- Rear = Coral Salon.
- Garden = back to island.

Mara first-visit line: `Welcome to Paloma House. This is for fun. You cannot win money.`

**Player suite v1:** one room, 8 furniture slots: bed, lamp, rug, window drape, chair, plant, wall art, nightstand. Cosmetics only. No stat bonuses. Guest corridor nameplates (Nia, Arthur, Jules) are not enterable.

**Nightclub v1:** lantern deck preview + music loop. No chance games.

**Shop:** a **tab on Mara’s desk only**. Never a modal over reels, wheel, ball, hand, or mid-tile.

---

# 8. BOARD — 24 TILES

Closed clockwise loop. Token on the ring. Tide Machine plaza is visual center; tiles 12–13 sit on the ring beside it.

**Movement:** button `Walk` rolls a **fair six-sided die** (faces 1–6 equal, shown). Move that many tiles. Cost = tiles stepped. **No multiplier. No paid x10 roll.**

## Tile table (index MUST match)

| # | ID | On land |
|---|---|---|
| 00 | PORCH | Start. +25 Shells **first pass per calendar day**. Enter Paloma House on tap. |
| 01 | BUNGALOW | Tap: decorate studio. Land: +10 Shells + 1 Decor Point. |
| 02 | PALM_PATH | Rest. +5 Shells. |
| 03 | BUILD_A | Next Tide part if any remain, else +15 Shells. |
| 04 | MARINA_DOOR | Tap to enter Jet-Ski Slalom. Does not auto-launch. |
| 05 | GUEST_BENCH | Named guest waves. +10 Shells + postcard fragment. |
| 06 | BEACH | Rest. +5 Shells. |
| 07 | POKER_DOOR | Label `POKER`. Tap: Sunset Cabana. Does not force sit. |
| 08 | BUILD_B | Same as BUILD_A. |
| 09 | WILDLIFE | Shades steals/returns sunglasses. +10 Shells. Not a loot box. |
| 10 | LANTERN_PATH | Rest. +5 Shells. |
| 11 | SLOTS_DOOR | Label `SLOTS`. Tap: Tiki Lounge. |
| 12 | CRANK | If machine complete, tap to fire. If incomplete, toast `Need more parts` + 10 Shells. |
| 13 | SPLASH | Safe. If Crank fires while any token is here, splash VFX. +20 Shells to the token on SPLASH. Does **not** destroy buildings. |
| 14 | BUILD_C | Same as BUILD_A. |
| 15 | ROULETTE_DOOR | Label `ROULETTE`. Tap: Coral Salon. |
| 16 | COCONUT_GROVE | Rest. +5 Shells. |
| 17 | FRIEND_DOCK | Leave a note / visit. +10 Shells. MUST NOT raid or damage. |
| 18 | BUILD_D | Same as BUILD_A. |
| 19 | LOOKOUT | +15 Shells first landing per day. |
| 20 | NIGHTCLUB_DOOR | Interior preview + concert loop. No chance games in v1. |
| 21 | BUILD_E | Same as BUILD_A. |
| 22 | SPA_PATH | Rest. +5 Shells. |
| 23 | BUILD_F | Same as BUILD_A. Then 00. |

Washington: tiles 07, 11, 15 still exist; Enter is disabled with `Chance games are unavailable in your region.`

---

# 9. TIDE MACHINE

Not Hasbro IP. Do not name it Mouse Trap in UI.

## Parts in order
1. **CRANK & GEARS** — wooden crank, two painted gears  
2. **FLIP-FLOP & POST** — rubber flip-flop on driftwood; gears slap it  
3. **BUCKET & STAIRS** — coconut-shell bucket on coral stairs; flip-flop kicks it  
4. **GUTTER** — bamboo gutter; painted coconut rolls  
5. **CRAB & BOARD** — hermit crab pops a diving board  
6. **UMBRELLA CAGE** — beach-umbrella cage drops onto SPLASH. Lagoon plume  

BUILD A–F grant exactly the next missing part. After 6/6, BUILD grants Shells only.  
Parts are **never sold**. Parts are **never gacha**.

## Crank
- Only if 6/6.  
- 8.0 seconds. Unskippable first time per day; skippable after.  
- Always plays the full chain.  
- Reward **every crank:** **40 Shells + 1 postcard fragment**. No jackpot table. No “cage almost dropped.”  
- Incomplete machine: jam animation at the missing part. Toast `The tide isn’t finished.` No prize. No shop.  
- Spectators (up to 4 clubmates): +10 Shells empathy. No PvP wipe.

---

# 10. ENGINE A — CHANCE (v1 = THREE + ROULETTE)

All use Shells. All use ChanceRng. Result chosen on press, then animated.  
Celebration audio/VFX **only if net win ≥ stake**.  
Near-miss rate = natural strip math. Do not overweight jackpot-adjacent stops.  
Odds plaque on every device.  
Default bet **1** where applicable.  
Washington: rooms will not open.

Tiki Lounge: three cabinets left to right as named. Ocean windows. Door plate: `SLOTS — FOR FUN`. Imani-equivalent is Mara’s line plus a plaque. Empty fourth plinth: `Coming with the next tide` (no IAP teaser).

---

## 10.1 PALM REELS — Cabinet 1
**Different because:** the only classic line-pay slot. Teaching cabinet.

- Grid 5×3, **20 paylines**, always on  
- Bet steps: 1 / 5 / 25 / 50 Shells  
- RTP **96.0%** medium volatility  
- Theme: fruit + pelican + shells  

| Symbol | 5 | 4 | 3 |
|---|---|---|---|
| Shades wild | 50× | 15× | 5× |
| Pineapple | 25× | 8× | 3× |
| Coconut | 20× | 6× | 2× |
| Hibiscus | 12× | 4× | 2× |
| Shell | 8× | 3× | 1× |
| Leaf | 5× | 2× | 1× |

Multipliers apply to **total bet**.  
Wild = Shades, substitutes all but scatter.  
Scatter = beach ball. 3+ anywhere: **8 free spins** with 2× wilds. Extra scatter during bonus +2 spins, cap 20.  
Scatter pay on trigger: 3=1×, 4=3×, 5=10× bet.

Put exact 32-stop strips in `data/paytables/palm_reels.json`.

---

## 10.2 COCONUT WHEEL — Cabinet 2
**Different because:** one resolution, no lines, readable in two seconds. A wheel, not reels.

- 16 slices  
- Cost **5 Shells** per pull  
- RTP **95.5%**  

| Slice | Pays (Shells) | Count on wheel |
|---|---|---|
| Small | 2 | 3 |
| Small | 3 | 3 |
| Small | 5 | 2 |
| Medium | 8 | 2 |
| Medium | 12 | 1 |
| Medium | 15 | 1 |
| Big | 25 | 1 |
| Big | 40 | 1 |
| Jackpot | 100 | 1 |
| Spin again | 0 + free extra pull | 1 |

Weights = slice counts above (total 16). Publish on plaque.  
“Spin again” cannot chain more than **two** extra pulls (hard cap).

---

## 10.3 LAGOON DIVE — Cabinet 3
**Different because:** cluster + cascade, not paylines. Still obviously chance.

- 5 reels × 3 rows treated as a cluster grid (adjacent orthogonal)  
- Bet steps: 1 / 5 / 25 / 50  
- RTP **96.2%** high-medium volatility  
- Theme: fish tiles  

Clusters of **5+** matching fish pay and pop. Remaining tiles drop (cascade). Up to **8 cascades per stake**. Each cascade adds **+0.2×** multiplier on that stake only; resets next bet.

Base cluster pays (× bet):
- 5 = 1×  
- 6–7 = 2×  
- 8–9 = 4×  
- 10–12 = 8×  
- 13–15 = 20×  

Scatter = treasure chest. 3+ starts pick-3 chests. Values pre-rolled at trigger from published table:

| Chest prize (× bet) | Weight |
|---|---|
| 1 | 30 |
| 2 | 25 |
| 3 | 20 |
| 5 | 15 |
| 8 | 7 |
| 15 | 3 |

Odds sheet: `Prizes are set when the bonus starts.`  
No purchase of extra picks.

**Do not ship Volcano Drop in v1.** That is season 2.

---

## 10.4 CORAL SALON — EUROPEAN ROULETTE
Door plate: `ROULETTE — SINGLE ZERO`. Croupier Lila.

- 37 pockets: 0 + 1–36. **No double zero.**  
- Visual lazy-river tube is theater. Result = `ChanceRng.rand_int(37)` mapped 0–36 equally.  
- House edge **2.70%**. Publish that sentence.

Payouts:
| Bet | Pays |
|---|---|
| Straight | 35:1 |
| Split | 17:1 |
| Street | 11:1 |
| Corner | 8:1 |
| Line (6) | 5:1 |
| Column / dozen | 2:1 |
| Red/black, odd/even, 1–18/19–36 | 1:1 (0 loses) |

Min total 1 Shell. Max total **50 Shells** per spin.  
No call bets, no lightning, no American wheel, no “skill physics.”

---

# 11. ENGINE B — POKER (SUNSET CABANA)

Door plate: `POKER — TEXAS HOLD’EM`. Dealer Kenji.

Player picks **HUMAN** or **PRACTICE (AI)** **before** credits move. Mixed tables forbidden.

## Games
1. Hold’em cash 6-max, blinds **25/50**  
2. Hold’em Sit-n-Go 6-max, buy-in **500**, prizes 1st 300 / 2nd 150 / 3rd 50 of a 500×6 pool if full; scale if short-handed. **0 rake.**  
3. Omaha 6-max cash 25/50 — unlocks after the player finishes **20 Hold’em hands**.

Standard rules. No bomb pots. No run-it-twice.  
Shuffle: Fisher–Yates, 52 cards, ChanceRng. Felt plaque: `Fair shuffle. No rake. For fun only.`  
No hand-strength meter on HUMAN or cash AI-fill. Coach overlay only on Practice, default **off**.

## Human table
Matchmade. If no human in 20s: dialog `Play now vs labeled AI?` Never silently seat a bot. Offline: door disabled.

## Practice table
Nameplate `AI — Practice`. House credits. Cannot convert to Shells. Always available offline.

## AI styles (play-style, not ESP)
| Name | Style |
|---|---|
| Reef | Tight-passive. Folds most, calls strong, rarely bluffs |
| Breaker | Loose-aggressive. Steals blinds, c-bets, folds to 3-bet without equity |
| Lagoon | Tight-aggressive. ABC + small bluff frequency on missed boards |

AI sees **only its hole cards + board**. NEVER other hole cards. NEVER future streets.  
Decision time 1.2–3.5s.  
River-win rate when trailing on the turn must sit within **2 percentage points of equity** over 5,000 simulated hands.  
IAP must not change AI parameters (action-histogram test 1,000 hands pre/post).

HUD: stack, blinds, pot, board, 12s time bank. No win-probability on real tables.

---

# 12. ENGINE C — SKILL (ALWAYS PAY SOMETHING)

Success is player input. If a miss is decided before the tap, REJECT the mini.

## C1 Jet-Ski Slalom (tile 04, Mateo)
- **8 buoys**. Timing / hold-to-steer. Gates do not move after spawn.  
- Finish always **20 Shells**. Perfect gates **+15**. Miss ≥3 gates still **8 Shells**. Never a jackpot.

## C2 Coconut Shy (from grove or marina overflow)
- 6 coconuts, 8 throws. Drag-release. Deterministic physics for the same aim vector. No magnet on the last coconut.  
- 4 Shells per coconut + 15 if 6/6. Miss-all still **5 Shells**.

## C3 Recipe Mix (Paloma House kitchen pass, Rafael)
- 4-step card shown 3.0s then hidden. Memory, not RNG.  
- 4/4 = 25 Shells + recipe card. 3/4 = 8. 0–2/4 = **5 Shells**.

Skill never pays a slot-scale jackpot.

---

# 13. PLAY SAFE

Available from: Mara’s notice board, Settings, Pause (≤ two taps).

| Control | Behavior |
|---|---|
| Session clock | Visible after 15 min, then every 15. No sale attached |
| Spend cap | Daily $0–$15 (default $15), weekly default $40. Lower instant, raise 48h |
| Cool-off | 24h / 7d / 30d. Island + skill + Tide + practice poker on. Chance staking + IAP off |
| Self-exclude | 180d or permanent. Survives reinstall if an account exists. Support cannot send Shells. Full lock option: static lobby `You're taking a break.` |
| Reality check | On chance-room exit: `Today: N spins, net Shells +/− X` |
| Delete account | Local (+ server if any) within 72h except documented legal hold |

Self-exclude MUST lock Tiki Lounge, Coral Salon, and human/SNG poker.

---

# 14. REGION

`systems/region_policy.gd`  
- `US-WA`: IAP off, chance doors Enter disabled. Island, Tide, skill, decorate stay.  
- `CA-BC`: age copy 19+.  
- No GPS precision. If region unknown, show 19+ copy only when locale is CA; do not false-block chance rooms except known WA.

---

# 15. UI SCREENS (ALL REQUIRED)

1. Splash (title + Shades, no WIN)  
2. Age gate  
3. Lock screen  
4. Paloma House lobby  
5. Island board  
6. Tiki Lounge  
7. Cabinet close-up (data-driven)  
8. Odds sheet  
9. Coral Salon  
10. Sunset Cabana pit  
11. Poker table  
12. Tide Machine close-up  
13. Jet-ski  
14. Coconut Shy  
15. Recipe Mix  
16. Bungalow decorate  
17. Desk shop  
18. Play Safe  
19. Settings  
20. Pause  
21. Postcard album  
22. Region-blocked dialog  

**Island HUD:** Shades portrait (opens nothing) · Daylight `n/40` · Shells · `Walk` · `House` · `Pause`.  
No shop cart on the island HUD.

---

# 16. COLLECTION

12 postcards. Fragments from tiles 05, Crank, daily. No gold lock. No trade. 12/12 once: +200 Shells + bungalow frame.  
8 recipes from Recipe Mix. 8/8: kitchen cosmetic.  
No sticker packs. No gacha envelopes.

---

# 17. ANALYTICS

If present, log only: session length, Play Safe changes, room enters, IAP SKU.  
No “whale” labels in code, comments, or dashboards.

---

# 18. TESTS TO SHIP

```
tests/test_purchase_does_not_change_slots.gd
tests/test_purchase_does_not_change_poker_ai.gd
tests/test_ai_cannot_read_other_hole_cards.gd
tests/test_single_currency_strings.gd
tests/test_european_roulette_37.gd
tests/test_tide_machine_incomplete_no_prize.gd
tests/test_tide_machine_complete_pays_40.gd
tests/test_daylight_zero_no_shop_modal.gd
tests/test_self_exclude_blocks_iap.gd
tests/test_no_daylight_sku.gd
```

README build:
```
godot --headless --export-release "Windows Desktop" build/windows/PalmAtoll.exe
godot --headless --export-release "Linux/X11" build/linux/PalmAtoll.x86_64
godot --headless --export-release "Android" build/android/PalmAtoll.apk
godot --headless -s res://tests/run_all.gd
```

---

# 19. OUT OF SCOPE v1

iOS · ads · Volcano Drop · American roulette · paid dice multipliers · raids · sticker gacha · dating · Warzone skins · voice chat · extra islands · Alpine/Neon seasons (SeasonConfig path may exist; do not ship season 2 art)

---

# 20. BUILDER CLOSEOUT

You are done when T1–T10 and the AT-* tests pass, three platforms boot Paloma Atoll, three chance cabinets + European roulette + labeled AI Hold’em + three skill minis + six-part Tide Machine work as specified, Play Safe can shut the till, grep is clean, Washington cannot open the Lounge, Shades has sunglasses, and outside looks like a toy island while inside looks like a hotel.

If you cannot point to each checkbox with a scene or a test, the game is **not built**.
