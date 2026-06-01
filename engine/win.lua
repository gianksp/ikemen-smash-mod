--[[
================================================================================
win.lua
--------------------------------------------------------------------------------
Per-frame win condition check for the Smash mod.
Injected into every fight via common.lua in ikemen-smash-mod.lua.

Checks every frame whether all players on one team have exhausted their stocks.
When a team has no surviving players, forces all remaining players on that
team to die via setLife(0), which triggers the engine's normal win/lose flow
including win screen, lose screen, and round transition.

WIN CONDITION:
  A player is considered "alive" if:
    var(21) > 0   (has stocks remaining)
    var(22) == 0  (not flagged as dead)
  A team loses when ALL of its players are no longer alive.

TIMING:
  fightTime() > 180 delay (3 seconds) prevents false triggers during
  initialization, before var(21) has been set by ikemen-smash-mod.zss.

TEAM SIDES (IkemenGO simul mode):
  Side 1: P1, P3, P5, P7 (odd player numbers)
  Side 2: P2, P4, P6, P8 (even player numbers)
  teamSide() returns 1 or 2 for the currently redirected player.

NOTE:
  This file runs in the commonLua context. See hud.lua header for details.
================================================================================
--]]

if gameRunning() and fightTime() > 180 then

    -- First pass: determine if each team has any surviving players
    local teamDead  = {true, true}  -- assume both teams dead, prove otherwise
    local teamTotal = {0, 0}        -- total players per team

    for i = 1, numPlayer() do
        player(i)
        local side   = teamSide()
        local stocks = math.floor(var(21))
        local dead   = math.floor(var(22))

        teamTotal[side] = teamTotal[side] + 1

        -- This player counts as alive if they have stocks and aren't flagged dead
        if stocks > 0 and dead == 0 then
            teamDead[side] = false
        end
    end

    -- Only check win condition if both teams have players
    if teamTotal[1] > 0 and teamTotal[2] > 0 then

        -- Second pass: kill all players on any team that has lost
        for i = 1, numPlayer() do
            player(i)
            local side = teamSide()

            -- Force life to 0 — triggers engine KO and normal win/lose screens
            if teamDead[side] then
                setLife(0)
            end
        end
    end
end