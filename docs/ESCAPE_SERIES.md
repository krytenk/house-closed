# House Closed — session contract

Full bible: **`docs/HOUSE_CLOSED.md`**.

Then: `docs/SCENE_PIPELINE.md`, `docs/INTERACTABLES.md`, `docs/ASSETS.md`, `docs/TRAPS.md`, `docs/FOLDER_LAYOUT.md`.

Then **only** the next `rooms/room_NN_*/ROOM.md`.

## What a new session does

1. Read the bible, then that ROOM.md.
2. Build **only that room**. Do not restyle a shipped room except shared escape systems (`escape_inventory.gd`, Use protocol).
3. Length is in `docs/HOUSE_CLOSED.md`. Room 01 is short. Room 02 is about 30 minutes. Later rooms are longer and harder. FPV. Inventory items. Scripted traps. Never `ChanceRng`.
4. Exit names the next sealed space. Do not build it.
5. Verify with Godot MCP: wake → each critical Use → door opens.

Palm Atoll spec is archive. Forbidden strings unchanged: no whale, sweeps, cash out, WIN BIG, LAST CHANCE, Beads as currency.
