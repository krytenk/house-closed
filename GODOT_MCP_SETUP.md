# Godot MCP Pro setup (Palm Atoll)

## Installed

1. **Addon** at `addons/godot_mcp/` (from your download) — enabled in Project Settings → Plugins.
2. **Free bridge server** at `/home/chriswinters/tools/godot-mcp-pro-free-server/server/index.js`
3. **Grok config** `~/.grok/config.toml` → `[mcp_servers.godot-mcp-pro]`

## How to use

1. Start Godot editor on this project (`godot --path /home/chriswinters/palm-atoll --editor`).
2. Confirm bottom panel **MCP Pro** shows connecting/connected on ports 6505–6514.
3. **Restart this Grok session** so the MCP tools load (new servers are not always hot-injected mid-session).
4. Then the agent can `play_scene`, `get_game_screenshot`, `simulate_mouse_click`, edit scenes via Godot UndoRedo.

Optional zero-addon runtime: `[mcp_servers.godot-runtime]` → `npx -y godot-mcp-runtime`.
