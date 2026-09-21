# Interactables, inventory, flags, traps

There is **no** message bus. One room script owns hover, use, flags, and save.

## Use protocol

1. `_mark(node, id, size, offset)` adds a `StaticBody3D` child named `Use_<id>` with `set_meta("use_id", id)`.
2. Each physics frame, raycast from the camera ~3.4 m. First collider with `use_id` becomes `_hover_id`.
3. Bottom hint is `_hint_for(id)`.
4. Left click, E, or Space calls `_use()` → `match _hover_id`.
5. Special case **bird**: hold left mouse and drag to rotate; release checks angle.

Never put the only clue in a Label3D on empty plaster. The mesh must read as the thing.

## Inventory

Autoload `EscapeInventory` (`systems/escape_inventory.gd`).

- 8 slots. Items stack by `id`.
- `add_item(id, label, amount)`, `has_item(id)`, `take(id, amount)`, `selected_id()`.
- Keys 1–8 select a slot.
- Using an item on a world target: look at the target while the item is selected (or the script just checks `has_item`). Room 01: coins on tray, fuse on register, key on door.

Ids already in play: `coin`, `notebook`, `fuse`, `key`, `light` (flashlight, optional).

## Flags

`Save.progress.escape.room_NN` is a Dictionary. Room 01 keys:

`bird_turned`, `coins_dumped`, `notebook`, `wallpaper` (means house-line was read), `coins_in_tray`, `jackpot`, `fuse`, `fuse_in`, `code_ok`, `has_key`, `door_open`, `cleared`, `flashlight`, `notice` (window sheet taken)

Do not reuse these names in later rooms. Persist on every meaningful Use (`_persist()`).

## Traps (definition)

A **trap** is a scripted lock or device that gates the hour. It is not RNG, not a fake timer, not a shop.

Each trap in a ROOM.md must list:

| Field | Meaning |
|---|---|
| `id` | `use_id` string |
| Object | Mesh / socket |
| Locked look | What the player sees before solve |
| Action | Drag, Use, insert item, set symbols, enter code |
| Opens | Flag or item granted |
| Fail look | What happens if used too early (short line, no softlock) |

If the object cannot be built as that thing (no wallpaper texture, no peel), **change the trap** to something that belongs in the room (Room 01: house-line plaque instead of peel).

## Shared HUD

- Centre crosshair
- Bottom hint
- Inventory line
- Esc: free mouse; H: last learned line (never the full solution)
- Till pad: digits, Close, code `418` in Room 01

## Scene keys (`Game.goto`)

Current product key: `room_01`. Add `room_02` … only when that folder has a playable tscn. Do not point boot at leftover `lounge` / `slot_palm`.
