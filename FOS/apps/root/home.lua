local app = APP.begin("home")
local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")

local wallpaper_light = texture.read("iVBORw0KGgoAAAANSUhEUgAAAAwAAAASCAMAAABYd88+AAAAAXNSR0IArs4c6QAAABtQTFRFAAAA0/x+AAAA/+tX////meZfM5hLWsVPHm9QOO7O5AAAAAl0Uk5T//8A////////7HvdrwAAAFRJREFUCJlNilEWADEEA+OVxP1PvKqrr/lghgBv7AlsrVpu7lc2u51aTM2MFjFCMkItNYtDOkJmmwRVawxS5s+cz+aSeinUN3BL45abTFyqIIdannxAjwPk4AOkqQAAAABJRU5ErkJggg")
local wallpaper_dark = texture.read("iVBORw0KGgoAAAANSUhEUgAAAAwAAAASCAMAAABYd88+AAAAAXNSR0IArs4c6QAAABhQTFRFAAAADgcbAAAAGhky////Ki9OZXOSQkxuy6cUJwAAAAh0Uk5T//8A//////8XRfkYAAAAU0lEQVQImU2KAQ4AQQQDSbf6/x8f9sg2ITPU7I0DPjGck0YnV4rptxZ/LUceMSIyQi25k0O6QqJNsiytmQT8zPkUp+RLob4ZSxpLNoAtZQxDLU8+OqUDMI8q6tYAAAAASUVORK5CYII")

app.pages.main = {
    -- orientation = "portrait" -- not added yet
    {type = "texture", size = 8},

    {type = "text", text = "Hello World", color = vec(1, 1, 1, 1)},
    {type = "text", text = "meow\n\nyep this is\nhome screen", pos = vec(0, 8)},
    {type = "text", text = "foxgirl", pos = vec(26, SYSTEM_REGISTRY.resolution.y - 8)},
}


local elements_count = #app.pages.main -- needed to know where its safe to remove elements from list
function app.events.init()
    for i = elements_count + 1, #app.pages.main do
        app.pages.main[i] = nil
    end

    app.pages.main[1].texture = PUBLIC_REGISTRY.theme == "dark" and wallpaper_dark or wallpaper_light

    local y = 8*6
    for name in pairs(APP.apps) do
        table.insert(
            app.pages.main,
            {
                type = "text",
                text = name:match(":(.*)"),
                pos = vec(0, y),
                pressAction = function()
                    APP.open(name)
                end
            }
        )
        y = y + 8
    end

    app.setPage("main") -- note: this line is not needed, default page name is "main"
end