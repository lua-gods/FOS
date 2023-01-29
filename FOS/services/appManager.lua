APP = {
    app = nil,
}

local app_list = {}

-- apps amount
local apps_count = 0
local loaded_apps_count = 0

-- list of apps (to not install app twice)
local loaded_apps = {}

-- load app
local function loadApp(path, app_type)
    -- prevent installing app twice
    if loaded_apps[path] then
        return
    end
    loaded_apps[path] = true

    --
    apps_count = apps_count + 1
    APP.app = nil

    --load app
    local loaded = pcall(require, path)

    -- app couldnt be loaded
    if not loaded then
        print("could not load: "..path)
        return
    end

    -- app loaded
    loaded_apps_count = loaded_apps_count + 1

    table.insert(app_list, APP.app)
end


-- begin function for apps
function APP.begin(name)
    if app then
        error("Can't create app second time", 2)
    else
        APP.app = {
            id = tostring(name)
        }
    end

    return APP.app
end


-- Load apps that are not loaded
local loading_apps = false
function APP.loadApps()
    if loading_apps then
        return
    end
    loading_apps = true

    for _, name in ipairs(listFiles(FOS_RELATIVE_PATH..".apps.system")) do
        loadApp(name, "system")
    end
    for _, name in ipairs(listFiles(FOS_RELATIVE_PATH..".apps.user")) do
        loadApp(name, "user")
    end

    if apps_count ~= loaded_apps_count then
        print("not loaded apps: "..(apps_count - loaded_apps_count))
    end

    loading_apps = false
end