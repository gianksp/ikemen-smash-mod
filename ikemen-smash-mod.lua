--[[
================================================================================
ikemen-smash-mod.lua
--------------------------------------------------------------------------------
Main entry point for the Ikemen GO Smash Bros mod.

This file is auto-loaded by IkemenGO because it lives in external/mods/.
It defines the mod configuration, registers engine hooks, and injects the
ZSS state script and per-frame Lua scripts into every fight.

INSTALLATION:
  Drop the entire folder into:
    <IkemenGO>/external/mods/ikemen-smash-mod/

CONFIGURATION:
  Edit the `smash` table below to tune gameplay.

FILES:
  ikemen-smash-mod.lua   This file. Config + hooks.
  ikemen-smash-mod.zss   ZSS state script. Runs per-character per-frame.
  hud.lua                Per-frame HUD rendering (percent + stocks).
  win.lua                Per-frame win condition check.
  debug.lua              Optional debug overlay. Disabled by default.

ARCHITECTURE:
  IkemenGO loads all .lua files in external/mods/ at startup.
  We use two hook points:
    - main.f_default  : fires before each mode starts, used to hide lifebars
    - launchFight     : fires before each fight, used to inject ZSS + Lua

  ZSS is injected via common.states — applies to ALL characters globally.
  Lua is injected via common.lua — runs as inline code every frame.
  Per-frame Lua files are read with main.f_fileRead() and passed as strings.

VARIABLE USAGE (ZSS vars, reserved by this mod):
  var(20)  : percent damage counter (accumulates from hits)
  var(21)  : stock count (lives remaining, initialized to smash.stocks)
  var(22)  : dead flag (1 = this character has lost all stocks)
  fvar(0)  : init flag (1 = character has been initialized this match)
  fvar(1)  : blast zone guard (1 = currently being processed by blast zone)

ENGINE COMPATIBILITY:
  Requires IkemenGO nightly build 2026.05.27 or later.
  Uses: common.states, common.lua, hook system, ZSS statedef -2.
================================================================================
--]]

-- Mod configuration table.
-- Edit these values to tune gameplay behavior.
local smash = {

    -- Set to false to disable the mod without removing the files.
    enabled = true,

    -- Number of stocks (lives) each player starts with.
    stocks = 3,

    -- ZSS variable indices used by this mod.
    -- Change these if they conflict with another mod's variables.
    vars = {
        percent = 20,   -- var(20): percent damage counter
        stocks  = 21,   -- var(21): stocks remaining
        dead    = 22,   -- var(22): death flag
        airjump = 23,   -- var(23): double jump
    },

    -- Blast zone boundaries in stage coordinates.
    -- Players crossing these are knocked out.
    -- Adjust to match your stage size.
    blast = {
        left   = -520,
        right  =  520,
        top    = -320,
        bottom =  260,
    },
}

--------------------------------------------------------------------------------
-- HOOK: main.f_default
-- Fires before each game mode starts.
-- Used to override fight screen settings before loadStart() is called.
--------------------------------------------------------------------------------
hook.add("main.f_default", "smash_defaults", function()
    if main.fightscreen then
        -- Hide health bars — damage is tracked via percent, not life
        main.fightscreen.bars = false
        -- Hide round timer — Smash has no time limit
        main.fightscreen.timer = false
    end
end)

--------------------------------------------------------------------------------
-- HOOK: launchFight
-- Fires just before each fight begins.
-- Injects ZSS states and per-frame Lua scripts into the fight.
--
-- Parameters (provided by engine):
--   common  table  Shared fight config. We append to common.states and common.lua.
--   t       table  Selected characters data.
--   data    table  Fight launch parameters.
--------------------------------------------------------------------------------
hook.add("launchFight", "smash_fight", function(common, t, data)
    if not smash.enabled then return end

    -- Disable round timer (backup in case hook order matters)
    setRoundTime(-1)

    -- Inject ZSS state script.
    -- Runs as common states for ALL characters, every frame.
    common.states = common.states or {}
    table.insert(common.states, "external/mods/ikemen-smash-mod/ikemen-smash-mod.zss")

    -- Inject per-frame Lua scripts.
    -- Each file is read as a string and run every frame during the fight.
    common.lua = common.lua or {}
    table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/hud.lua"))
    table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/win.lua"))

    -- Uncomment to enable debug overlay (shows player sides):
    -- table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/debug.lua"))
end)

return smash