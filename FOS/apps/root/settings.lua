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

-- presonalization tab
app.pages["main.personalization"] = {
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = "personalization"},

    {
        type = "text", pos = vec(0, 8 * 2),
        text = "theme: "..PUBLIC_REGISTRY.theme,
        pressAction = function(obj)
            PUBLIC_REGISTRY.save("theme", PUBLIC_REGISTRY.theme == "light" and "dark" or "light")
            themeManager.updateTheme()
            obj.text = "theme: "..PUBLIC_REGISTRY.theme
            app.redraw()
        end
    }
}

-- apps tab
do
    local all_apps
    local offset = 0
    local element_count = 0

    local function update_app_list()
        for i = 1, 16 do
            local tbl = app.pages["main.apps"][i + element_count]
            if i == 16 and i + offset < #all_apps then
                tbl.text = "..."
            elseif i == 1 and offset ~= 0 then
                tbl.text = "..."
            else
                tbl.text = all_apps[i + offset] or ""
            end
        end
    end

    function app.events.post_key_press()
        if app.current_page ~= "main.apps" then
            return
        end

        if app.selected_item - element_count == 16 and offset + 16 ~= #all_apps then
            offset = offset + 1
            app.selected_item = 15 + element_count

            update_app_list()
            app.redraw()
        elseif app.selected_item - element_count == 1 and offset ~= 0 then
            offset = offset - 1
            app.selected_item = 2 + element_count

            update_app_list()
            app.redraw()
        elseif app.selected_item >= 1 and not all_apps[app.selected_item - element_count] then
            app.selected_item = #all_apps + element_count

            app.redraw()
        end
    end
    
    app.pages["main.apps"] = {
        load = function()
            offset = 0
            all_apps = {current = 1}
            for i in pairs(APP.apps) do
                table.insert(all_apps, i)
            end

            for i = string.byte("a"), string.byte("z") do
                -- table.insert(all_apps, (string.char(i).." "):rep(5))
            end

            update_app_list()
        end,
        {type = "rectangle", size = vec(96, 8)},
        {type = "text", text = "apps"},
    }
    
    element_count = #app.pages["main.apps"]

    local y = 16
    for _ = 1, 16 do
        table.insert(app.pages["main.apps"], {type = "text", text = "meow", pos = vec(0, y), pressAction = true})
        y = y + 8
    end
end