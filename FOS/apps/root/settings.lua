local app = APP.begin("settings", "settings")

---- functions ----
local function setPage(page, ...)
    if app.pages[page].load then
        app.pages[page].load(app.pages[page], ...) 
    end

    app.setPage(page)
end

local function goPageBack()
    local page = app.current_page
    local new_page = page:match("^(.*)%.[^.]*$")
    if new_page then
        setPage(new_page)
    else
        APP.open()
    end
end

function app.events.key_press(key)
    if key == "LEFT" then
        goPageBack()
    end
end

---- services ----
local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")
local configAppManager = require(FOS_RELATIVE_PATH..".services.configAppManager")
local appData = require(FOS_RELATIVE_PATH..".libraries.appDataAPI")
---- pages ----

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
    local offset = 0
    local element_count = 0

    local function update_app_list()
        for i = 1, 16 do
            local tbl = app.pages["main.apps"][i + element_count]
            if i == 16 and i + offset < #APP.sorted_apps then
                tbl.text = "..."
            elseif i == 1 and offset ~= 0 then
                tbl.text = "..."
            else
                local current_app = APP.apps[APP.sorted_apps[i + offset]]
                if current_app then
                    tbl.text = current_app.display_name
                else
                    tbl.text = ""
                end
            end
        end
    end

    function app.events.post_key_press()
        if app.current_page ~= "main.apps" then
            return
        end

        if app.selected_item - element_count == 16 and offset + 16 ~= #APP.sorted_apps then
            offset = offset + 1
            app.selected_item = 15 + element_count

            update_app_list()
            app.redraw()
        elseif app.selected_item - element_count == 1 and offset ~= 0 then
            offset = offset - 1
            app.selected_item = 2 + element_count

            update_app_list()
            app.redraw()
        elseif app.selected_item >= 1 and not APP.sorted_apps[app.selected_item - element_count] then
            app.selected_item = #APP.sorted_apps + element_count

            app.redraw()
        end
    end
    
    app.pages["main.apps"] = {
        load = function()
            offset = 0

            update_app_list()
        end,
        {type = "rectangle", size = vec(96, 8)},
        {type = "text", text = "apps"},
    }
    
    element_count = #app.pages["main.apps"]

    
    local pressAction = function(_, i)
        setPage("main.apps.app", APP.sorted_apps[i - element_count + offset])
    end

    local y = 16
    for _ = 1, 16 do
        table.insert(app.pages["main.apps"], {type = "text", text = "meow", pos = vec(0, y), pressAction = pressAction})
        y = y + 8
    end
end

-- app settings tab
do
    local selected_app
    local data_can_be_cleared = true
    local already_exported = false
    app.pages["main.apps.app"] = {
        load = function(page, selected_app_id)
            if not selected_app_id then
                return
            end
            selected_app = APP.apps[selected_app_id]

            -- variables
            data_can_be_cleared = true
            already_exported = false

            -- info
            page[2].text = selected_app.display_name
            page[3].text = "id:\n"..selected_app_id
            page[4].text = "path:\n"..selected_app.path

            -- options
            page[6].color = selected_app.can_be_opened and "text" or "text_locked"
            page[7].color = configAppManager.exportable[selected_app_id] and "text" or "text_locked"
            page[8].color = "text"
            page[9].color = selected_app.path:sub(1, 7) == "CONFIG." and "text" or "text_locked"
        end,
        {type = "rectangle", size = vec(96, 8)},
        {type = "text", text = "app name"},
        {type = "text", text = "id", pos = vec(0, 8 * 2)},
        {type = "text", text = "path", pos = vec(0, 8 * 5), wrap_after = 96},

        {type = "rectangle", size = vec(96, 32), pos = vec(0, 112)},
        {type = "text", text = "open", pos = vec(0, 112),
            pressAction = function()
                if selected_app.can_be_opened then
                    APP.open(selected_app.id)
                end
            end
        },
        {type = "text", text = "export", pos = vec(0, 120), pressAction = function(obj, i)
                if configAppManager.exportable[selected_app.id] and not already_exported then
                    configAppManager.export(selected_app.id)
                    already_exported = true
                    obj.color = "text_locked"
                    app.redraw({i})
                end
            end
        },
        {type = "text", text = "clear app data", pos = vec(0, 128), pressAction = function(obj, i)
                if data_can_be_cleared then
                    appData.clear(selected_app.id)
                    data_can_be_cleared = false
                    obj.color = "text_locked"
                    app.redraw({i})
                end
            end
        },
        {type = "text", text = "uninstall", pos = vec(0, 136), pressAction = function()
                if selected_app.path:sub(1, 7) == "CONFIG." then
                    setPage("main.apps.app.uninstall_confirm")
                end
            end
        },
    }

    app.pages["main.apps.app.uninstall_confirm"] = {
        load = function(page)
            page[2].text = selected_app.display_name
        end,
        {type = "rectangle", size = vec(96, 8)},
        {type = "text", text = "app name"},

        {type = "text", text = "are you sure you\nwant to uninstall\nthis app?", pos = vec(0,16)},

        {type = "rectangle", size = vec(96, 16), pos = vec(0, 128)},
        {type = "text", text = "yes", pos = vec(0, 128), pressAction = function() configAppManager.uninstall(selected_app.id) setPage("main.apps") end},
        {type = "text", text = "no", pos = vec(0, 136), pressAction = function() goPageBack() end},
    }
end