--[[
================================================================================
debug.lua
--------------------------------------------------------------------------------
Optional debug overlay for the Smash mod.
Disabled by default — enable by uncommenting in ikemen-smash-mod.lua:
  table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/debug.lua"))

Currently displays:
  - Team side assignment for each player (P1=side1, P2=side2, etc.)

Useful for verifying simul mode team assignments and player counts.
Remove or disable before distributing the mod.
================================================================================
--]]

if gameRunning() then
    local f   = fontNew("font/f-6x9.def")
    local img = textImgNew()
    textImgSetFont(img, f)
    textImgSetScale(img, 1, 1)
    textImgSetLayerno(img, 9)
    textImgSetColor(img, 255, 0, 0)  -- red so it stands out

    local out = ""
    for i = 1, numPlayer() do
        player(i)
        out = out .. "P"..i.."=side"..tostring(teamSide()).." "
    end

    textImgSetText(img, out)
    textImgSetPos(img, 10, 20)
    textImgDraw(img)
end