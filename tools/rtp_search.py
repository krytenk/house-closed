#!/usr/bin/env python3
"""Hill-climb 32-stop Palm Reels strips toward 96.0% RTP. Pay values stay frozen."""
from __future__ import annotations

import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "paytables" / "palm_reels.json"

LINES = [
    (1, 1, 1, 1, 1),
    (0, 0, 0, 0, 0),
    (2, 2, 2, 2, 2),
    (0, 1, 2, 1, 0),
    (2, 1, 0, 1, 2),
    (0, 0, 1, 2, 2),
    (2, 2, 1, 0, 0),
    (1, 2, 1, 0, 1),
    (1, 0, 1, 2, 1),
    (1, 0, 0, 0, 1),
    (1, 2, 2, 2, 1),
    (0, 1, 1, 1, 2),
    (2, 1, 1, 1, 0),
    (0, 1, 2, 2, 2),
    (2, 1, 0, 0, 0),
    (1, 1, 0, 1, 1),
    (1, 1, 2, 1, 1),
    (0, 0, 1, 0, 0),
    (2, 2, 1, 2, 2),
    (0, 2, 1, 2, 0),
]
PAY = {
    "W": {5: 50, 4: 15, 3: 5},
    "P": {5: 25, 4: 8, 3: 3},
    "C": {5: 20, 4: 6, 3: 2},
    "H": {5: 12, 4: 4, 3: 2},
    "S": {5: 8, 4: 3, 3: 1},
    "L": {5: 5, 4: 2, 3: 1},
}
SCATTER = {3: 1, 4: 3, 5: 10}


def line_pay(window, line, bet=1, wild_mult=1):
    seq = [window[i][line[i]] for i in range(5)]
    face = ""
    count = 0
    used_wild = False
    for s in seq:
        if s == "B":
            break
        if s == "W":
            used_wild = True
            count += 1
            continue
        if face == "":
            face = s
            count += 1
            continue
        if s == face:
            count += 1
            continue
        break
    if face == "" and count >= 3:
        face = "W"
    if face not in PAY or count < 3:
        return 0
    c = min(count, 5)
    if c not in PAY[face]:
        return 0
    m = PAY[face][c]
    if used_wild:
        m *= wild_mult
    return m * bet


def eval_window(window, bet=1, wild_mult=1):
    lw = sum(line_pay(window, ln, bet, wild_mult) for ln in LINES)
    sc = sum(1 for col in window for s in col if s == "B")
    sw = SCATTER.get(min(sc, 5), 0) * bet if sc >= 3 else 0
    fs = 8 if sc >= 3 else 0
    return lw + sw, fs, sc


def spin(rng, strips, wild_mult=1):
    window = []
    for strip in strips:
        st = rng.randrange(len(strip))
        window.append([strip[(st + r) % len(strip)] for r in range(3)])
    total, fs, sc = eval_window(window, 1, wild_mult)
    return total, fs, sc


def play(rng, strips):
    total, extra, _ = spin(rng, strips, 1)
    played = 0
    cap = 20
    while extra > 0 and played < cap:
        extra -= 1
        played += 1
        t, more_fs, sc = spin(rng, strips, 2)
        total += t
        extra = min(cap - played, extra + (2 if sc >= 3 else 0))
    return total


def seed_strips():
    """Sparse premiums. 1 scatter, 1 wild per reel. Rest mostly leaves."""
    strips = []
    rng = random.Random(7)
    for i in range(5):
        s = ["L"] * 32
        s[0] = "B"
        s[8] = "W"
        s[16] = "P"
        s[20] = "C"
        s[24] = "C"
        s[4] = "H"
        s[12] = "H"
        s[28] = "S"
        s[6] = "S"
        s[18] = "S"
        rng.shuffle(s)
        # keep scatter from clustering: if two B somehow, skip
        strips.append(s)
    return strips


def mutate(strips, rng):
    out = [list(s) for s in strips]
    r = rng.randrange(5)
    i = rng.randrange(32)
    # never drop the only scatter on a reel
    if out[r].count("B") == 1 and out[r][i] == "B":
        return out
    pool = ["L", "L", "L", "L", "L", "L", "S", "S", "H", "C", "P", "W"]
    out[r][i] = rng.choice(pool)
    if out[r].count("B") == 0:
        out[r][rng.randrange(32)] = "B"
    if out[r].count("W") == 0:
        j = rng.randrange(32)
        if out[r][j] != "B":
            out[r][j] = "W"
    return out


def rtp_of(strips, n=12000, seed=1):
    rng = random.Random(seed)
    paid = 0.0
    for _ in range(n):
        paid += play(rng, strips)
    return paid / n


def main():
    rng = random.Random(20260917)
    cur = seed_strips()
    cur_r = rtp_of(cur, 8000, seed=3)
    print(f"start rtp={cur_r:.4f}")
    target = 0.96
    best = [list(s) for s in cur]
    best_r = cur_r
    for i in range(160):
        cand = mutate(best, rng)
        r = rtp_of(cand, 6000, seed=11 + i)
        if abs(r - target) < abs(best_r - target):
            best = cand
            best_r = r
            print(f"step {i} rtp={r:.4f}")
            if abs(r - target) < 0.01:
                break
    r2 = rtp_of(best, 30000, seed=99)
    print(f"verify rtp={r2:.4f}")
    data = json.loads(OUT.read_text()) if OUT.exists() else {"id": "palm_reels"}
    data["strips"] = best
    data["rtp_measured"] = round(r2, 4)
    data["rtp_target"] = 0.96
    OUT.write_text(json.dumps(data, indent=2) + "\n")
    print("wrote", OUT)


if __name__ == "__main__":
    main()
