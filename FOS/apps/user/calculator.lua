local app = APP.begin("calculator", "calculator")

SYSTEM_REGISTRY.home_app = "user:calculator"

app.pages.main = {
    {type = "rectangle", size = vec(96, 8)},
    {type = "rectangle", size = vec(96, 8), pos = vec(0, 16)},
    {type = "text", text = "2+2*2", pos = vec(64, 16), size = 1},
    {type = "text", text = app.display_name},
}

local i = 0
for y = 0, 3 do
    for x = 0, 3 do
        i = i + 1
        app.pages.main[i + 4] = {
            type = "rectangle",
            color = i == 1 and "rectangle_select" or "rectangle",
            size = vec(23 + (x == 3 and 1 or 0), 23),
            pos = vec(x * 24, 121 - y * 24),
        }
    end
end

local function pos_to_index(pos)
    return pos.x + pos.y * 4 + 5
end

local pos = vec(0, 0)
function app.events.key_press(key)
    local new_pos = pos:copy()

    if key == "LEFT" then
        new_pos.x = math.max(new_pos.x - 1, 0)
    elseif key == "RIGHT" then
        new_pos.x = math.min(new_pos.x + 1, 3)
    elseif key == "DOWN" then
        new_pos.y = math.max(new_pos.y - 1, 0)
    elseif key == "UP" then
        new_pos.y = math.min(new_pos.y + 1, 3)
    end

    app.pages.main[pos_to_index(pos)].color = "rectangle"
    app.pages.main[pos_to_index(new_pos)].color = "rectangle_select"

    app.redraw({pos_to_index(pos), pos_to_index(new_pos)})

    pos = new_pos
end

--[[
local fontManager = require(FOS_RELATIVE_PATH..".services.fontManager")
print(fontManager.fonts.minimojangles["0"].width, "0")
print(fontManager.fonts.minimojangles["*"].width, "*")
print(fontManager.fonts.minimojangles["("].width, "(")
print(fontManager.fonts.minimojangles[")"].width, ")")
print(fontManager.fonts.minimojangles[" "].width, " ")
--]]