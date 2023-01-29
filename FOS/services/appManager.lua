APP = {
    app = nil,
    apps = {}
}

local appManager = {}
local eventManager = require(FOS_RELATIVE_PATH..".services.eventsManager")

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
    local loaded = pcall(require, path)

    -- app couldnt be loaded
    if not loaded then
        print("could not load: "..path)
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
        events = eventManager.newEventsTable()
    }

    APP.apps[app.id] = app
    APP.app = app
    return APP.app
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
end


appManager.loadApps()

return appManager