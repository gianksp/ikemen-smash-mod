-- hud.lua - Smash Bros style HUD
if not gameRunning() then
    return
end

local screenW = 320
local screenH = 240
local n = smashPlayerCount or math.min(numPlayer(), 4)
local slotW = screenW / math.max(n, 1)
local f = fontNew("font/f-6x9.def")

local function percentColor(pct)
    if pct < 50 then
        return 255, 255, 255
    end
    if pct < 100 then
        return 255, 210, 0
    end
    if pct < 150 then
        return 255, 100, 0
    end
    return 255, 30, 30
end

local function drawText(text, x, y, sx, sy, r, g, b, layer)
    local img = textImgNew()
    textImgSetFont(img, f)
    textImgSetScale(img, sx, sy)
    textImgSetLayerno(img, layer or 9)
    textImgSetColor(img, r, g, b)
    textImgSetAlign(img, 0)
    textImgSetText(img, text)
    textImgSetPos(img, x, y)
    textImgDraw(img)
end

for i = 1, n do
    player(i)

    local pct = math.max(math.floor(var(20)), 0)
    local stocks = math.max(math.floor(var(21)), 0)
    local cx = (i - 1) * slotW + slotW / 2
    local baseY = screenH - 20

    -- Background panel
    -- drawText(string.rep("_", 12), cx, baseY - 6, 1.1, 2.8, 15, 15, 20, 8)

    -- Player label
    drawText("P" .. i, cx, baseY, 0.8, 0.8, 180, 180, 255, 9)

    -- Percent
    local r, g, b = percentColor(pct)
    drawText(pct .. "%", cx + 5, baseY + 10, 1, 1, r, g, b, 9)

    -- Stock dots
    local dots = string.rep("* ", stocks):gsub(" $", "")
    drawText(dots, cx + 13, baseY, 0.3, 0.8, 255, 255, 255, 9)

    local worldX = fvar(10)
    local worldY = fvar(11)
    -- Convert world pos to screen pos (approximate)
    local sx = screenW / 2 + worldX * 0.5
    local sy = screenH / 2 + worldY * 0.5

    -- Player label above character
    drawText("P" .. i, sx, math.max(sy + 20, 5), 0.8, 0.8, 180, 180, 255, 9)
    drawText("v", sx, math.max(sy + 28, 15), 0.7, 0.7, 180, 180, 255, 9)

end
