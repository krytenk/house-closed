# Palm Atoll

A resort you live on, with a casino you can visit — not a casino wearing a lei.

**For fun only. You cannot win real money.**

Engine: Godot 4.7.x (4.3+). Spec: [`docs/PALM_ATOLL_BUILD_SPEC.md`](docs/PALM_ATOLL_BUILD_SPEC.md).

## Run

```
godot --path . --editor
godot --path .
```

## Tests

```
godot --headless -s res://tests/run_all.gd
```

## Export

```
godot --headless --export-release "Windows Desktop" build/windows/PalmAtoll.exe
godot --headless --export-release "Linux/X11" build/linux/PalmAtoll.x86_64
godot --headless --export-release "Android" build/android/PalmAtoll.apk
```

Android AAB (Play): preset `Android AAB` → `build/android/PalmAtoll.aab`.

v1 platforms: Android ARM64, Windows x86_64, Linux x86_64. No iOS.

## Tokens

- **Daylight** — movement. Never sold.
- **Shells** — the only wallet.
- **Cosmetics** — IAP / season pass. Zero power.
