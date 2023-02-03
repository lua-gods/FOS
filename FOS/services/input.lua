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

    local play_sound = false
    local stop_sound = eventsManager.runEvent("KEY_PRESS", key)

    local page = APP.app.pages[APP.app.current_page]
    local currently_selected = APP.app.selected_item
    local new_selected
    if key == "UP" then
        for i = currently_selected - 1, 1, -1 do
            if page[i] and page[i].pressAction then
                new_selected = i
                play_sound = true
                break
            end
        end
    elseif key == "DOWN" then
        for i = currently_selected + 1, #page do
            if page[i] and page[i].pressAction then
                new_selected = i
                play_sound = true
                break
            end
        end
    elseif key == "ENTER" then
        if page[currently_selected] and type(page[currently_selected].pressAction) == "function" then
            page[currently_selected].pressAction()
            play_sound = true
        end
    end

    if new_selected then
        APP.app.selected_item = new_selected
        raster.draw({currently_selected, new_selected})
    end
    if play_sound and not stop_sound then
        sounds:playSound("ui.button.click", player:getPos(), 0.25, 2)
    end
end

for key_path, display_name in pairs(input_keys) do
    local key = keybinds:newKeybind(display_name:lower(), key_path)

    key.press = function()
        press(display_name)
    end
end