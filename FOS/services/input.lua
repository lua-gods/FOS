local eventsManager = require(FOS_RELATIVE_PATH..".services.eventsManager")

local input_keys = {
    ["key.keyboard.left"] = "LEFT",
    ["key.keyboard.up"] = "UP",
    ["key.keyboard.right"] = "RIGHT",
    ["key.keyboard.down"] = "DOWN",
    ["key.keyboard.enter"] = "CONFIRM"
}

local function can_be_pressed()
    if player:getItem(1).id ~= "minecraft:air" then
        return false
    end

    return true
end

for key_name, name in pairs(input_keys) do
    local key = keybinds:newKeybind(name:lower(), key_name)

    key.press = function()
        if not can_be_pressed() then
            return
        end

        eventsManager.runEvent("KEY_PRESS", name)
    end
end