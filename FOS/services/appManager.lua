APP = {
    app = nil,
    apps = {}
}

local appManager = {}
local eventManager = require(FOS_RELATIVE_PATH..".services.eventsManager")
local raster = require(FOS_RELATIVE_PATH..".services.raster")
local uiManager = require(FOS_RELATIVE_PATH..".libraries.textureAPI")

-- apps amount
local apps_count = 0
local loaded_apps_count = 0


-- list of apps (to not install app twice)
local loaded_apps = {}

-- load app
local current_app_type
local function loadApp(path, app_type)
    -- prevent installing app twice
    if loaded_apps[path] then
        return
    end
    loaded_apps[path] = true

    
    apps_count = apps_count + 1
    APP.app = nil
    
    current_app_type = app_type

    --load app
    local loaded, error = pcall(require, path)

    -- app couldnt be loaded
    if not loaded or not APP.app then
        print("could not load: "..path)
        print(error)
        return
    end

    -- app loaded
    loaded_apps_count = loaded_apps_count + 1
    -- print("app loaded", path, app_type, APP.apps[APP.app.id])
end

-- begin function for apps
function APP.begin(name)
    if APP.app then
        return error("Can't create app second time", 2)
    end

    local app = {
        id = current_app_type..":"..tostring(name),
        events = eventManager.newEventsTable(),
        pages = {},
        setPage = appManager.setPage,
        current_page = nil,
        redraw = raster.draw
    }

    APP.apps[app.id] = app
    APP.app = app
    return APP.app
end


-- open app
function APP.open(name)
    local app_to_load = APP.apps[name] or APP.apps[SYSTEM_REGISTRY.home_app]
    if app_to_load == nil then
        return
    end

    APP.app = app_to_load

    APP.app.current_page = nil

    eventManager.runEvent("INIT")

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

-- Load apps that are not loaded
local loading_apps = false
function appManager.loadApps()
    if loading_apps then
        return
    end
    loading_apps = true

    for _, name in ipairs(listFiles(FOS_RELATIVE_PATH..".apps.root")) do
        loadApp(name, "root")
    end
    for _, name in ipairs(listFiles(FOS_RELATIVE_PATH..".apps.user")) do
        loadApp(name, "user")
    end

    if apps_count ~= loaded_apps_count then
        print("not loaded apps: "..(apps_count - loaded_apps_count))
    end

    loading_apps = false

    APP.open()
end


appManager.loadApps()

return appManager