local app = APP.begin("home", "fos home screen")

local configAppManager = require(FOS_RELATIVE_PATH..".services.configAppManager")

app.can_be_opened = false -- hide on home screen

local wallpaper_light = texture.read("iVBORw0KGgoAAAANSUhEUgAAAAwAAAASCAMAAABYd88+AAAAAXNSR0IArs4c6QAAABtQTFRFAAAA0/x+AAAA/+tX////meZfM5hLWsVPHm9QOO7O5AAAAAl0Uk5T//8A////////7HvdrwAAAFRJREFUCJlNilEWADEEA+OVxP1PvKqrr/lghgBv7AlsrVpu7lc2u51aTM2MFjFCMkItNYtDOkJmmwRVawxS5s+cz+aSeinUN3BL45abTFyqIIdannxAjwPk4AOkqQAAAABJRU5ErkJggg")
local wallpaper_dark = texture.read("iVBORw0KGgoAAAANSUhEUgAAAAwAAAASCAMAAABYd88+AAAAAXNSR0IArs4c6QAAABhQTFRFAAAADgcbAAAAGhky2N3qKi9OZXOSQkxuuHla6gAAAAh0Uk5T//8A//////8XRfkYAAAAU0lEQVQImU2KAQ4AQQQDSbf6/x8f9sg2ITPU7I0DPjGck0YnV4rptxZ/LUceMSIyQi25k0O6QqJNsiytmQT8zPkUp+RLob4ZSxpLNoAtZQxDLU8+OqUDMI8q6tYAAAAASUVORK5CYII")

-- create main page
app.pages.main = {
    orientation = "portrait", -- "landscape", true, 1 - is landscape, everything else is portrait

    {type = "texture", size = 8},

    {type = "text", text = "clock", color = vec(1, 1, 1)},
}


-- install app page
local page_main, page_install

app.pages.install = {
    {type = "rectangle", size = vec(SYSTEM_REGISTRY.resolution.x, 8)},
    {type = "text", text = "App installer", pos = vec(14, 0)},
    {type = "text", text = "do you want\nto install:", pos = vec(0, 16)},
        {type = "text", text = "THIS APP", pos = vec(0, 34)},
        {type = "rectangle", size = vec(SYSTEM_REGISTRY.resolution.x, 24), pos = vec(0, SYSTEM_REGISTRY.resolution.y - 24)},
    {type = "text", text = "install", pressAction = function() configAppManager.install() end, pos = vec(0, SYSTEM_REGISTRY.resolution.y - 24)},
    {type = "text", text = "don't install", pressAction = function() configAppManager.ignore_install() page_main() end, pos = vec(0, SYSTEM_REGISTRY.resolution.y - 16)},
    {type = "text", text = "install later", pressAction = function() page_main() end, pos = vec(0, SYSTEM_REGISTRY.resolution.y - 8)},
}

local elements_count = #app.pages.main -- needed to know where its safe to remove elements from list

-- update clock
local function update_clock(redraw)
    local date = client:getDate()
    local text = string.format("%02d:%02d", date.hour, date.minute)
    
    if app.pages.main[2].text ~= text then
        app.pages.main[2].text = text
        if redraw then
            app.redraw({2})
        end
    end
end

-- main page
function page_main()
    for i = elements_count + 1, #app.pages.main do
        app.pages.main[i] = nil
    end

    app.pages.main[1].texture = PUBLIC_REGISTRY.theme == "dark" and wallpaper_dark or wallpaper_light

    local y = 8*2
    for _, name in pairs(APP.sorted_apps) do
        local data = APP.apps[name]
        if data.can_be_opened then
            table.insert(
                app.pages.main,
                {
                    type = "text",
                    text = data.display_name,
                    pos = vec(0, y),
                    pressAction = function()
                        APP.open(name)
                    end
                }
            )
            y = y + 8
        end
    end

    update_clock(false)
    app.setPage("main")
end

-- install page 
function page_install()
    app.pages.install[4].text = configAppManager.app_to_import_name:sub(13, -1)
    app.setPage("install")
end
    
-- called when app opened --
function app.events.init()
    if configAppManager.app_to_import then
        page_install()
    else
        page_main()
    end
end

-- called every tick --
function app.events.tick()
    if app.current_page == "main" then
        update_clock(true)
    end
end