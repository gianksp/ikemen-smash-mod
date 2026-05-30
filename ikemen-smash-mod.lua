local smash = {
    enabled = true,
    stocks = 3,
    vars = {
        percent = 20,
        stocks = 21,
        dead = 22
    },
    blast = {
        left = -520,
        right = 520,
        top = -320,
        bottom = 260
    }
}

hook.add("main.f_default", "smash_defaults", function()
    if main.fightscreen then
        main.fightscreen.bars = false
        main.fightscreen.timer = false
    end
end)

hook.add("launchFight", "smash_fight", function(common, t, data)
    if not smash.enabled then return end

    setRoundTime(-1)

    common.states = common.states or {}
    table.insert(common.states, "external/mods/ikemen-smash-mod/ikemen-smash-mod.zss")

    common.lua = common.lua or {}
    table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/hud.lua"))
    table.insert(common.lua, main.f_fileRead("external/mods/ikemen-smash-mod/win.lua"))
    -- table.insert(common.lua, main.f_fileRead("external/mods/smash/debug.lua"))
end)

return smash