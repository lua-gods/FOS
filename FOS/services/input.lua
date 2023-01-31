local eventsManager = require(FOS_RELATIVE_PATH..".services.eventsManager")
local raster = require(FOS_RELATIVE_PATH..".services.raster")

local input_keys = {
    ["key.keyboard.left"] = "LEFT",
    ["key.keyboard.up"] = "UP",
    ["key.keyboard.right"] = "RIGHT",
    ["key.keyboard.down"] = "DOWN",
    ["key.keyboard.enter"] = "ENTER"
}

local function press(key)
    if player:getItem(1).id ~= "minecraft:air" then
        return
    end

    eventsManager.runEvent("KEY_PRESS", key)

    local page = APP.app.pages[APP.app.current_page]
    local currently_selected = APP.app.selected_item
    if key == "UP" then
        for i = currently_selected - 1, 1, -1 do
            if page[i] and page[i].pressAction then
                APP.app.selected_item = i
                raster.draw()
                break
            end
        end
    elseif key == "DOWN" then
        for i = currently_selected + 1, #page do
            if page[i] and page[i].pressAction then
                APP.app.selected_item = i
                raster.draw()
                break
            end
        end
    elseif key == "ENTER" then
        if page[currently_selected] and type(page[currently_selected].pressAction) == "function" then
            page[currently_selected].pressAction()
        end
    end
end

for key_path, display_name in pairs(input_keys) do
    local key = keybinds:newKeybind(display_name:lower(), key_path)

    key.press = function()
        press(display_name)
    end
end