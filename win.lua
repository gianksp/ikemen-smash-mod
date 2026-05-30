if gameRunning() and fightTime() > 180 then
    local teamDead = {true, true}
    local teamTotal = {0, 0}
    for i = 1, numPlayer() do
        player(i)
        local side = teamSide()
        local stocks = math.floor(var(21))
        local dead = math.floor(var(22))
        teamTotal[side] = teamTotal[side] + 1
        if stocks > 0 and dead == 0 then
            teamDead[side] = false
        end
    end
    if teamTotal[1] > 0 and teamTotal[2] > 0 then
        for i = 1, numPlayer() do
            player(i)
            local side = teamSide()
            if teamDead[side] then
                setLife(0)
            end
        end
    end
end