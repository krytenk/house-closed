# Folder layout

```
res://
  docs/
    HOUSE_CLOSED.md          ← product SSoT (start here)
    SCENE_PIPELINE.md
    INTERACTABLES.md
    ASSETS.md
    FOLDER_LAYOUT.md         ← this file
    ESCAPE_SERIES.md         ← short contract; points at HOUSE_CLOSED
    PALM_ATOLL_BUILD_SPEC.md ← archive only
  rooms/
    room_01_lounge/          playable
      traps/                 one review file per trap
    room_02_lobby/           ROOM.md only
    room_03_desk/            ROOM.md only
    room_04_cabana/          ROOM.md only
    room_05_salon/           ROOM.md only
    room_06_nightclub/       ROOM.md only
    room_07_suite/           ROOM.md only
    tiki_lounge/             leftover chance (do not ship)
    sunset_cabana/           leftover chance
    coral_salon/             leftover chance
  art/models/                GLB + imported tscn
  art/seasons/paloma/        textures, symbols, wallpaper
  systems/
    escape_inventory.gd      live
    game.gd                  scene table (director)
    save.gd
    *.gd                     leftover Palm Atoll autoloads, unused by Room 01
  tools/
    abandoned_lounge.blend
    build_abandoned_lounge.py
    import_glb.gd
  world/                     island, lobby overlay, bungalow — leftover
  ui/                        pause/boot leftover
  tests/                     Palm Atoll tests, not Room 01 DoD
```

## New room (session recipe)

```
rooms/room_NN_<slug>/
  ROOM.md              required first
  <slug>_escape.tscn   when building
  <slug>_escape.gd
```

Plus `tools/<slug>.blend` and `art/models/<slug>.glb` when art starts.

Do not add a `Game.SCENES` key until the tscn exists and the ROOM.md working list is true.
