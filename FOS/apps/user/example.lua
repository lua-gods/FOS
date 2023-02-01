local app = APP.begin("exammmmpl")
local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")

local function switch_theme()
    themeManager.themes.default = themeManager.themes.default == themeManager.themes.light and themeManager.themes.dark or themeManager.themes.light
    app.redraw()
end

app.pages.main = {
    {type = "text", text = "this is example app still no text wrapping :3"},
    {type = "text", text = "in  this\nexample app\nyou can\nchange theme\nnote:\nFOS is in progress\nthere will be\nsettings app\ninstead", pos = vec(0, 16)},

    {type = "text", text = "switch theme", pos = vec(14, 8*14), pressAction = switch_theme},
    {type = "text", text = "go back", pos = vec(26, 8*16), pressAction = function() APP.open() end}
}