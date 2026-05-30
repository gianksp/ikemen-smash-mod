--[[
================================================================================
hud.lua
--------------------------------------------------------------------------------
Per-frame HUD rendering for the Smash mod.
Injected into every fight via common.lua in ikemen-smash-mod.lua.

Displays percent damage and stock count for each active player
at the bottom of the screen, evenly distributed by player count.

LAYOUT:
  Players are spaced evenly across the screen width.
  Each slot shows:
    P{n}         player number
    {x}%         current percent damage
    [{s}]        stocks remaining

SCREEN COORDINATES:
  Based on stage localcoord = 320, 240.
  If your stage uses a different localcoord, adjust screenW and screenH.

VARIABLE READS (via ZSS vars set in ikemen-smash-mod.zss):
  var(20)  percent damage
  var(21)  stocks remaining

NOTE:
  This file is read as a plain string by main.f_fileRead() and passed
  to common.lua. It runs in the commonLua context, not the module context.
  No access to upvalues from ikemen-smash-mod.lua.

  player(i) sets the redirect context — subsequent trigger calls
  (var, life, teamSide, etc.) read from that player until redirected again.
================================================================================
--]]

if gameRunning() then
    local n       = numPlayer()
    local screenW = 320
    local screenH = 240
    local slotW   = screenW / math.max(n, 1)
    local f       = fontNew("font/f-6x9.def")

    for i = 1, n do
        -- Redirect all trigger calls to player i
        player(i)

        local pct    = math.floor(var(20))
        local stocks = math.floor(var(21))

        local img = textImgNew()
        textImgSetFont(img, f)
        textImgSetScale(img, 1, 1)
        textImgSetLayerno(img, 9)           -- render on top of everything
        textImgSetColor(img, 255, 255, 0)   -- yellow
        textImgSetAlign(img, 0)             -- center aligned
        textImgSetText(img, "P"..i.."\n"..pct.."%\n["..stocks.."]")

        -- Center text within this player's horizontal slot
        local x = (i - 1) * slotW + slotW / 2
        textImgSetPos(img, x, screenH - 30)
        textImgDraw(img)
    end
end