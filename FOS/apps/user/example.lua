return [=[
local app = APP.begin("example")

local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")

local function switch_theme()
    PUBLIC_REGISTRY.save("theme", PUBLIC_REGISTRY.theme == "dark" and "light" or "dark")
    themeManager.updateTheme()
    app.redraw()
end

app.pages.main = {
    {type = "text", text = "this is example app  still no text wrapping :3      ", pos = vec(0, 0)},
    {type = "text", text = "in  this\nexample app\nyou can\nchange theme\nnote:\nFOS is in progress\nthere will be\nsettings app\ninstead", pos = vec(0, 16)},

    {type = "text", text = "switch theme", pos = vec(14, 8*14), pressAction = switch_theme},
    {type = "text", text = "go back", pos = vec(26, 8*16), pressAction = function() APP.open() end}
}

local vel = 0
local x = 0
local old_x = x
function app.events.tick()
    old_x = x
    vel = vel * 0.7
    x = math.clamp(x + vel, -120, 0)
    if old_x + vel ~= x then
        vel = 0
    end
    if app.isPressed("LEFT") then
        vel = vel + 4
    elseif app.isPressed("RIGHT") then
        vel = vel - 4
    end
end

function app.events.render(delta)
    if math.floor(x) ~= math.floor(old_x) then
        app.pages.main[1].pos.x = math.lerp(old_x, x, delta)
        app.redraw({1})
    end
end
--]=]