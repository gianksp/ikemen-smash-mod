if gameRunning() then
    local n = numPlayer()
    local screenW = 320
    local screenH = 240
    local slotW = screenW / math.max(n, 1)
    local f = fontNew("font/f-6x9.def")
    for i = 1, n do
        player(i)
        local pct = math.floor(var(20))
        local stocks = math.floor(var(21))
        local img = textImgNew()
        textImgSetFont(img, f)
        textImgSetScale(img, 1, 1)
        textImgSetLayerno(img, 9)
        textImgSetColor(img, 255, 255, 0)
        textImgSetText(img, "P"..i.."\n"..pct.."%\n["..stocks.."]")
        textImgSetAlign(img, 0)
        local x = (i - 1) * slotW + slotW / 2
        textImgSetPos(img, x, screenH - 30)
        textImgDraw(img)
    end
end