local app = APP.begin("settings", "settings")

SYSTEM_REGISTRY.home_app = "root:settings"
-- SYSTEM_REGISTRY.home_app = "root:home"

---- functions --
local function setPage(page)
    if app.pages[page].load then
        app.pages[page].load(app.pages[page]) 
    end

    app.setPage(page)
end

function app.events.key_press(key)
    if key == "LEFT" then
        local page = app.current_page
        local new_page = page:match("^(.*)%.[^.]*$")
        if new_page then
            setPage(new_page)
        else
            APP.open()
        end
    end
end

---- pages --
local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")

app.pages["main"] = {
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
    {type = "text", text = "personalization", pos = vec(0, 8 * 2), pressAction = function() setPage("main.personalization") end},
    {type = "text", text = "apps", pos = vec(0, 8 * 3), pressAction = function() setPage("main.apps") end},
}

app.pages["main.personalization"] = {
    {
        type = "text", pos = vec(0, 8 * 0),
        text = "theme: "..PUBLIC_REGISTRY.theme,
        pressAction = function(obj)
            PUBLIC_REGISTRY.save("theme", PUBLIC_REGISTRY.theme == "light" and "dark" or "light")
            themeManager.updateTheme()
            obj.text = "theme: "..PUBLIC_REGISTRY.theme
            app.redraw()
        end
    }
}

do
    local all_apps = {}
    -- local 
    app.pages["main.apps"] = {
        load = function(o) print(o) end
    }
end