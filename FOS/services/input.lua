local input = {}

local eventsManager = require(FOS_RELATIVE_PATH..".services.eventsManager")
local raster = require(FOS_RELATIVE_PATH..".services.raster")

local key_names = {
    ["key.keyboard.left"] = "LEFT",
    ["key.keyboard.up"] = "UP",
    ["key.keyboard.right"] = "RIGHT",
    ["key.keyboard.down"] = "DOWN",
    ["key.keyboard.enter"] = "ENTER",
["key.keyboard.backspace"] = "BACK",
}

local can_press_keys = 0 -- 0 is true, 1 and above if false
local go_to_home_time = 0

local keys = {}
local press

for key_path, display_name in pairs(key_names) do
    local key = keybinds:newKeybind(display_name:lower(), key_path)

    key.press = function()
        press(display_name)
    end

    keys[display_name] = key
end


function press(key)
    if can_press_keys >= 1 then
        return
    end

    local play_sound = false
    eventsManager.runEvent("KEY_PRESS", key)

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
            page[currently_selected].pressAction(page[currently_selected], currently_selected)
            play_sound = true
        end
    elseif key == "BACK" then
        if go_to_home_time >= 1 and SYSTEM_REGISTRY.home_app ~= APP.app.id then
            go_to_home_time = 0
            APP.open(SYSTEM_REGISTRY.home_app)
            play_sound = true
        end
        go_to_home_time = 10
    end

    if new_selected then
        APP.app.selected_item = new_selected
        raster.draw({currently_selected, new_selected})
    end

    if play_sound then
        sounds:playSound("ui.button.click", player:getPos(), 0.25, 2)
    end

    eventsManager.runEvent("POST_KEY_PRESS", key)
end

function input.isPressed(key)
    if keys[key] then
        return keys[key]:isPressed()
    end
end

function events.tick()
    go_to_home_time = math.max(go_to_home_time - 1, 0)

    can_press_keys = math.max(can_press_keys - 1, 0)

    if player:getItem(1).id ~= "minecraft:air" then
        can_press_keys = 2
    elseif host:isChatOpen() then
        can_press_keys = 2
    end
end

return input