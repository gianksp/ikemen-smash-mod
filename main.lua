local smash = {
    enabled = true,
    stocks = 3,
    vars = {
        percent = 20,
        stocks = 21,
        dead = 22,
        airjump = 23
    },
    blast = {
        left = -520,
        right = 520,
        top = -320,
        bottom = 260
    }
}

local portraits = {}
local portraitsLoaded = false

hook.add("main.f_default", "smash_defaults", function()
    if main.fightscreen then
        main.fightscreen.bars = false
        main.fightscreen.timer = false
    end
end)

hook.add("launchFight", "smash_fight", function(common, t, data)
    if not smash.enabled then
        return
    end

    -- in launchFight hook
    local playerCount = 0
    for side = 1, 2 do
        if start.p[side] and start.p[side].t_selected then
            for _ in ipairs(start.p[side].t_selected) do
                playerCount = playerCount + 1
            end
        end
    end
    -- Store in a global so hud.lua can read it
    smashPlayerCount = playerCount
    print("Player count: " .. playerCount)

    portraits = {}
    portraitsLoaded = false

    setRoundTime(-1)

    common.states = common.states or {}
    table.insert(common.states, "external/mods/ikemen-smash-mod/actions/camera.zss")
    table.insert(common.states, "external/mods/ikemen-smash-mod/actions/blastzones.zss")
    table.insert(common.states, "external/mods/ikemen-smash-mod/actions/doublejump.zss")
    table.insert(common.states, "external/mods/ikemen-smash-mod/actions/knockback.zss")
    table.insert(common.states, "external/mods/ikemen-smash-mod/actions/playerarrow.zss")
    table.insert(common.states, "external/mods/ikemen-smash-mod/actions/main.zss")

    common.lua = common.lua or {}
    table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/engine/hud.lua"))
    table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/engine/win.lua"))
end)

-- Load portraits once fight starts using animGetPreloadedCharData
-- P1/P2 work via preloaded, others via animNew in loop context
hook.add("loop", "smash_portrait_load", function()
    if not gameRunning() then
        return
    end
    if portraitsLoaded then
        return
    end

    local playerIdx = 1
    for side = 1, 2 do
        if start.p[side] and start.p[side].t_selected then
            for _, sel in ipairs(start.p[side].t_selected) do
                local cd = start.f_getCharData(sel.ref)
                if cd then
                    local sff = cd.dir .. cd.char .. ".sff"
                    local anim = animNew(sff, "9000, 0, 0, 0, -1")
                    if anim then
                        portraits[playerIdx] = anim
                        print("Portrait P" .. playerIdx .. ": " .. cd.name .. " sff=" .. sff)
                    end
                    playerIdx = playerIdx + 1
                end
            end
        end
    end

    portraitsLoaded = true
end)

-- Draw all portraits at bottom of screen, evenly spaced
hook.add("loop", "smash_portrait_draw", function()
    if not gameRunning() then
        return
    end
    if not portraitsLoaded then
        return
    end

    local count = 0
    for i = 1, 8 do
        if portraits[i] then
            count = count + 1
        end
    end
    if count == 0 then
        return
    end

    local screenW = 320
    local screenH = 240
    local slotW = screenW / count
    local slot = 0

    for i = 1, 8 do
        if portraits[i] then
            local cx = slot * slotW + slotW / 2
            animSetPos(portraits[i], cx, screenH - 20)
            animSetScale(portraits[i], 0.12, 0.12)
            animSetLayerno(portraits[i], 2)
            animUpdate(portraits[i])
            animDraw(portraits[i])
            slot = slot + 1
        end
    end
end)

return smash
