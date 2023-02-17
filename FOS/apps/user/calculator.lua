local app = APP.begin("calculator", "calculator")

-- main page
app.pages.main = {
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
    {type = "rectangle", size = vec(96, 8), pos = vec(0, 16)},
    {type = "text", text = "2+2*2", pos = vec(64, 16)}
}

-- variables
local input_text = ""
local tile_pos = vec(0, 4)

-- update text input
local function input_text_update(str, redraw)
    local offset = 94
    for i = 1, #str do
        local char = str:sub(i, i)
        if char == "*" or char == "(" or char == ")" then
            offset = offset - 5
        elseif char == " " then
            offset = offset - 3
        elseif char == "." then
            offset = offset - 2
        else
            offset = offset - 6
        end
    end

    input_text = str

    app.pages.main[4].text = str
    app.pages.main[4].pos.x = offset

    if redraw then
        app.redraw()
    end
end

-- tiles data
local tiles_data = {
    {"0"},
    {"."},
    {"<", function() input_text_update(input_text:sub(1, -2), true) end},
    {"=", function()
        if input_text == "error" then
            return
        end
        local func = loadstring("return "..input_text)
        if func then
            local success, output = pcall(func)
            if success then
                input_text_update(tostring(output), true)
                return
            end
        end
        input_text_update("error", true)
    end},
    {"1"},
    {"2"},
    {"3"},
    {"+"},
    {"4"},
    {"5"},
    {"6"},
    {"-"},
    {"7"},
    {"8"},
    {"9"},
    {"*"},
    {"AC", function() input_text_update("", true) end},
    {"()", function()
        if input_text:sub(-1, -1):match("[0-9]") then
            input_text_update(input_text..")", true)
        else
            input_text_update(input_text.."(", true)
        end
    end},
    {" ^"},
    {" /"},
}

-- generate tiles
local tiles_start = #app.pages.main + 1
local function pos_to_index(x, y)
    return x + y * 4 + tiles_start, x + y * 4 + 1
end

for y = 0, 4 do
    for x = 0, 3 do
        local i, i2 = pos_to_index(x, y)
        app.pages.main[i] = {
            type = "rectangle",
            color = vec(x, y) == tile_pos and "rectangle_select" or "rectangle",
            size = vec(x == 3 and 24 or 23, y == 4 and 12 or 23),
            pos = vec(x * 24, (y == 4 and 132 or 121) - y * 24),
        }

        app.pages.main[i + 20] = {
            type = "text",
            text = tiles_data[i2][1],
            size = y == 4 and 1 or 2,
            pos = vec(x * 24 + 5, (y == 4 and 134 or 125) - y * 24),
        }
    end
end

-- move and buttons
function app.events.key_press(key)
    local new_pos = tile_pos:copy()

    if key == "LEFT" then
        new_pos.x = math.max(new_pos.x - 1, 0)
    elseif key == "RIGHT" then
        new_pos.x = math.min(new_pos.x + 1, 3)
    elseif key == "DOWN" then
        new_pos.y = math.max(new_pos.y - 1, 0)
    elseif key == "UP" then
        new_pos.y = math.min(new_pos.y + 1, 4)
    elseif key == "ENTER" then
        local _, i = pos_to_index(tile_pos.x, tile_pos.y)
        if tiles_data[i][2] then
            tiles_data[i][2]()
        else
            input_text_update(input_text..tiles_data[i][1]:match("[^ ]"), true)
        end
        return
    else
        return
    end

    local tile_pos_i = pos_to_index(tile_pos.x, tile_pos.y)
    local new_pos_i = pos_to_index(new_pos.x, new_pos.y)

    app.pages.main[tile_pos_i].color = "rectangle"
    app.pages.main[new_pos_i].color = "rectangle_select"

    app.redraw({tile_pos_i, new_pos_i})

    tile_pos = new_pos
end

-- init
function app.events.open()
    input_text_update("")
    app.setPage("main")
end