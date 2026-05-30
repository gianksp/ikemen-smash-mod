# ikemen-smash-mod

A Smash Bros style gameplay mod for [IkemenGO](https://github.com/ikemen-engine/Ikemen-GO).

Transforms any IkemenGO installation into a Smash Bros style experience — percent damage, knockback scaling, blast zone KOs, stocks, and a minimal HUD. Works with up to 8 players in simul mode. Zero modifications to engine files.

![Gameplay screenshot showing 4 players with percent and stock HUD](screenshot.png)

---

## Features

- Percent damage system — hits accumulate % instead of depleting a life bar
- Knockback scaling — the higher your %, the further you fly
- Blast zone KOs — fly off any edge to lose a stock
- Stock lives — each player starts with 3 lives, lose them all and you're out
- Multi-player support — works with 2 to 8 players in simul mode
- Minimal HUD — shows percent and stocks for every player
- No engine file modifications — drop-in, drop-out installation

---

## Requirements

- IkemenGO nightly build `2026.05.27` or later
- Any characters and stages compatible with IkemenGO

---

## Installation

1. Download or clone this repository
2. Copy the `ikemen-smash-mod` folder into your IkemenGO installation:
   ```
   <IkemenGO>/external/mods/ikemen-smash-mod/
   ```
3. Launch IkemenGO — the mod loads automatically

That's it. No config files to edit, no engine files to modify.

## Uninstall

Delete the `ikemen-smash-mod` folder from `external/mods/`. Everything reverts to default.

---

## How to Play

1. Launch IkemenGO
2. Go to **Options → Engine Settings → Players** and set to 2–8
3. Select **VS Mode → Simul** (for team play) or **Free Battle**
4. Pick your characters and fight

The HUD at the bottom shows each player's current percent and stocks remaining. Get launched off screen to lose a stock. Last team standing wins.

---

## Configuration

Edit `ikemen-smash-mod.lua` to tune gameplay:

```lua
local smash = {
    enabled = true,   -- false to disable mod without removing files

    stocks = 3,       -- starting lives per player

    vars = {
        percent = 20, -- ZSS var index for percent (change if conflicting)
        stocks  = 21, -- ZSS var index for stocks
        dead    = 22, -- ZSS var index for death flag
    },

    blast = {
        left   = -520, -- blast zone boundaries (stage coordinates)
        right  =  520,
        top    = -320,
        bottom =  260,
    },
}
```

To tune knockback scaling, edit `ikemen-smash-mod.zss`:
```
velMul{x: 1 + var(20) * 0.008; y: 1 + var(20) * 0.008}
```
- `0.004` — gradual, harder to die
- `0.008` — moderate (default)
- `0.015` — aggressive, easier to die at lower percent

---

## File Structure

```
external/mods/ikemen-smash-mod/
  ikemen-smash-mod.lua    Main entry point, config, hooks
  ikemen-smash-mod.zss    ZSS state script (per-character per-frame logic)
  hud.lua                 HUD rendering (percent + stocks display)
  win.lua                 Win condition detection
  debug.lua               Debug overlay (disabled by default)
```

---

## Developer Guide

### Architecture

IkemenGO auto-loads all `.lua` files in `external/mods/` at startup. This mod uses two hook points:

**`main.f_default`** — fires before each game mode. Used to override `main.fightscreen` settings (hides health bars and timer).

**`launchFight`** — fires before each fight. Used to:
- Set round time to infinite (`setRoundTime(-1)`)
- Inject the ZSS state script via `common.states`
- Inject per-frame Lua scripts via `common.lua`

### ZSS Injection

ZSS files added to `common.states` are loaded as common states for **all characters** in the fight, without modifying `common1.cns.zss`. Everything runs in `statedef -2` which executes every frame for every character.

```lua
common.states = common.states or {}
table.insert(common.states, "external/mods/ikemen-smash-mod/ikemen-smash-mod.zss")
```

### Lua Injection

Lua files added to `common.lua` run as inline code every frame during the fight. They are read as strings using `main.f_fileRead()`.

```lua
common.lua = common.lua or {}
table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/hud.lua"))
```

**Important:** commonLua code runs in a limited context. Not all IkemenGO Lua functions are available. See known limitations below.

### Player Redirect Pattern

In commonLua, `player(i)` sets a redirect context. All trigger calls after it read from that player until redirected again:

```lua
for i = 1, numPlayer() do
    player(i)               -- redirect to player i
    local pct = var(20)     -- reads var(20) FROM player i
    local hp  = life()      -- reads life FROM player i
end
```

### Variable Convention

| Variable | Purpose |
|----------|---------|
| `var(20)` | Percent damage counter |
| `var(21)` | Stocks remaining |
| `var(22)` | Dead flag (1 = out of stocks) |
| `fvar(0)` | Init flag (1 = initialized this match) |
| `fvar(1)` | Blast zone guard (prevents multi-trigger) |

If you're building another mod alongside this one, avoid these variable indices or change them in the config.

### Adding Features

To add a new per-frame system:

1. Create a new `.lua` file in the mod folder
2. Add it to `common.lua` in `ikemen-smash-mod.lua`:
   ```lua
   table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/myfeature.lua"))
   ```
3. Or add ZSS logic to `ikemen-smash-mod.zss` inside `statedef -2`

### Known Limitations

- `common.lua` accepts inline code strings only, not file paths
- `common.states` accepts file paths only, not inline code
- Camera position cannot be controlled from Lua (engine limitation)
- `setZoom`, `setZoomMin`, `setZoomMax` crash from `launchFight` hook — use stage `.def` camera settings instead
- `findEntityByPlayerId()` throws on missing players — wrap in `pcall`
- Per-frame Lua has no persistent state between frames — all locals reset each frame

### IkemenGO Lua API (Confirmed Working)

See `ikemengo_lua_sdk.lua` for a full reference of confirmed-working functions and patterns discovered during development of this mod.

---

## Contributing

Issues and pull requests welcome. When reporting bugs please include:
- IkemenGO build date/version
- Number of players
- Steps to reproduce

---

## License

MIT