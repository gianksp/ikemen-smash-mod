if gameRunning() then
    local f = fontNew("font/f-6x9.def")
    local img = textImgNew()
    textImgSetFont(img, f)
    textImgSetScale(img, 1, 1)
    textImgSetLayerno(img, 9)
    textImgSetColor(img, 255, 0, 0)
    local out = ""
    for i = 1, numPlayer() do
        player(i)
        out = out .. "P"..i.."=side"..tostring(teamSide()).." "
    end
    textImgSetText(img, out)
    textImgSetPos(img, 10, 20)
    textImgDraw(img)
end