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

local go_to_home_time = 0

local keys = {}
local press

for key_path, display_name in pairs(key_names) do
    local key = keybinds:newKeybind(display_name:lower(), key_path)

    key.press = function()
        return press(display_name)
    end

    keys[display_name] = key
end

-- keybinds
function press(key)
    if SYSTEM_REGISTRY.disable_system then
        return false
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

    if play_sound and player:isLoaded() then
        sounds:playSound("ui.button.click", player:getPos(), 0.25, 2)
    end

    eventsManager.runEvent("POST_KEY_PRESS", key)

    return true
end

function input.isPressed(key)
    if keys[key] then
        return keys[key]:isPressed()
    end
end

-- keyboard
local chat_text = nil
local was_typing_message = false

local function getChatMessage(str)
    if not str then
        return false, nil
    end
    return str:sub(1, #PUBLIC_REGISTRY.keyboard_prefix) == PUBLIC_REGISTRY.keyboard_prefix, str:sub(#PUBLIC_REGISTRY.keyboard_prefix + 1, -1)
end

function events.CHAT_SEND_MESSAGE(str)
    local used_prefix, text = getChatMessage(str)
    if used_prefix then
        host:appendChatHistory(str)
        was_typing_message = false
        eventsManager.runEvent("KEYBOARD", text, true)
    else
        return str
    end
end

-- tick
function events.tick()
    -- keybinds
    go_to_home_time = math.max(go_to_home_time - 1, 0)
    -- keyboard
    local new_chat_text = host:getChatText()
    if new_chat_text ~= chat_text then
        chat_text = new_chat_text
        local used_prefix, text = getChatMessage(chat_text)
        if used_prefix then
            was_typing_message = true
            eventsManager.runEvent("KEYBOARD", text, false)
        elseif was_typing_message then
            eventsManager.runEvent("KEYBOARD", nil, false)
        end

        host:setChatColor(used_prefix and PUBLIC_REGISTRY.accent_color or vec(1, 1, 1))
    end
end

return input