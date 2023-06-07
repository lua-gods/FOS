APP = {
    app = nil,
    apps = {},
    sorted_apps = {},
    loaded_apps = {}
}

-- app manager apis
local appManager = {}
local eventManager = require(FOS_RELATIVE_PATH..".services.eventsManager")
local configAppManager = require(FOS_RELATIVE_PATH..".services.configAppManager")
local raster = require(FOS_RELATIVE_PATH..".services.raster")
local input = require(FOS_RELATIVE_PATH..".services.input")

-- app apis
local appData = require(FOS_RELATIVE_PATH..".libraries.appDataAPI")
require(FOS_RELATIVE_PATH..".libraries.fileSystemAPI")
require(FOS_RELATIVE_PATH..".libraries.textureAPI")

-- apps amount
local apps_count = 0
local loaded_apps_count = 0


-- list of apps (to not install app twice)
-- load app
local current_app_type
local function loadApp(path, app_type)
    -- prevent installing app twice
    if APP.loaded_apps[path] then
        return
    end
    APP.loaded_apps[path] = true

    
    apps_count = apps_count + 1
    APP.app = nil
    
    current_app_type = app_type

    --load app
    local loaded, output_error
    
    if path:sub(1, 7) == "CONFIG." then
        local str = configAppManager.apps[path]
        if str then
            local func = load(str)
            if type(func) == "function" then
                loaded, output_error = pcall(func)
                if loaded and APP.app then
                    configAppManager.exportable[APP.app.id] = str
                end
            elseif type(func) == "string" then
                output_error = func
            end
        end
    else
        loaded, output_error = pcall(require, path)
        if loaded and APP.app == nil and type(output_error) == "string" then
            --exportable mode
            local str = output_error
            local func = load(output_error)
            if type(func) == "function" then
                loaded, output_error = pcall(func)
                if loaded and APP.app then
                    configAppManager.exportable[APP.app.id] = str
                end
            end
        end
    end 

    if loaded == false or APP.app == nil then
        -- app couldnt be loaded
        print("could not load: "..path)
        print(tostring(output_error):sub(1, 128))

        if path:sub(1, 7) == "CONFIG." then -- if its config app, allow user to uninstall it
            local app = {
                path = path,
                can_be_opened = false,
                display_name = path:sub(8, -1),
                id = "error:"..path
            }
            APP.apps[app.id] = app
            table.insert(APP.sorted_apps, app.id)
        else -- dont need to sort
            return
        end
    else
        -- app loaded
        loaded_apps_count = loaded_apps_count + 1

        APP.app.path = path
        APP.apps[APP.app.id] = APP.app
        table.insert(APP.sorted_apps, APP.app.id)
    end

    table.sort(APP.sorted_apps, function(a, b) return APP.apps[a].display_name < APP.apps[b].display_name end)
end

-- begin function for apps
function APP.begin(name, display_name)
    if APP.app then
        return error("Can't create app second time", 2)
    end

    local id = current_app_type..":"..tostring(name)

    local app = {
        id = id,
        display_name = tostring(display_name or name):gsub("\n", ""),

        data = appData.new(id),
        events = eventManager.newEventsTable(),
        pages = {},

        setPage = appManager.setPage,
        redraw = raster.draw,
        isPressed = input.isPressed,

        current_page = nil,
        selected_item = -1,

        can_be_opened = true,
    }

    APP.app = app
    return APP.app
end


-- open app
function APP.open(name, ...)
    local app_to_load = APP.apps[name]
    local custom_data = nil
    if app_to_load == nil then
        if type(name) == "string" then
            app_to_load = APP.apps["root:"..name] or APP.apps["user:"..name]
        else
            app_to_load = APP.apps[SYSTEM_REGISTRY.home_app]
        end
        if app_to_load == nil then
            app_to_load = APP.apps[SYSTEM_REGISTRY.error_app]
            custom_data = "home screen app not found"
        end
        if app_to_load == nil then
            app_to_load = {pages = {main = {
                {type = "rectangle", color = vec(0, 0, 0, 1), size = vec(1000, 1000)},
                {type = "text", text = "home screen app\nand error app\nnot found", color = vec(1, 1, 1, 1)}
            }}}
        end
    end

    if APP.app then
        eventManager.runEvent("CLOSE")
    end

    APP.app = app_to_load

    APP.app.current_page = nil

    if custom_data then
        eventManager.runEvent("OPEN", custom_data)
    else
        eventManager.runEvent("OPEN", ...)
    end

    if APP.app.current_page == nil then
        appManager.setPage()
    end
end

function appManager.setPage(page_name)
    if page_name == nil then
        page_name = "main"
    end

    APP.app.current_page = page_name
    APP.app.selected_item = -1

    if APP.app.pages[APP.app.current_page] == nil then
        APP.app.pages[APP.app.current_page] = {}
    end
    
    raster.draw()
end

function APP.landscapeMode()
    return APP.app and (APP.app.pages[APP.app.current_page].orientation == true or APP.app.pages[APP.app.current_page].orientation == 1 or APP.app.pages[APP.app.current_page].orientation == "landscape")
end

-- Load apps that are not loaded
local loading_apps = false
function APP.loadApps()
    if loading_apps then
        return
    end
    loading_apps = true

    if APP.app then
        eventManager.runEvent("CLOSE")
    end

    for _, name in ipairs(listFiles(FOS_RELATIVE_PATH..".apps.root")) do
        loadApp(name, "root")
    end
    
    for _, name in ipairs(listFiles(FOS_RELATIVE_PATH..".apps.user")) do
        loadApp(name, "user")
    end

    for name in pairs(configAppManager.apps) do
        loadApp(name, "user")
    end

    if apps_count ~= loaded_apps_count then
        print("not loaded apps: "..(apps_count - loaded_apps_count))
    end

    loading_apps = false

    APP.app = nil
    APP.open()
end


APP.loadApps()

return appManager