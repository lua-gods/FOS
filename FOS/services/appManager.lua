APP = {}
APP.apps = {}

local loaded_apps = {}


local apps_count = 0
local loaded_apps_count = 0
local app_name = nil

local function loadApp(path, app_type)
    if loaded_apps[path] then
        return
    end
    loaded_apps[path] = true

    apps_count = apps_count + 1

    app_name = nil
    local loaded = pcall(require, path)
    if not loaded then
        print("could not load: "..path)
        return
    end

    loaded_apps_count = loaded_apps_count + 1
end

function APP.begin(name)
    if app_name then
        error("Can't begin app second time", 2)
    else
        app_name = tostring(name):gsub("\n", "\\n")
    end
end

function APP.loadApps()
    for _, name in ipairs(listFiles(FOS_REGISTRY.root_path..".apps.system")) do
        loadApp(name, "system")
    end

    for _, name in ipairs(listFiles(FOS_REGISTRY.root_path..".apps.user")) do
        loadApp(name, "user")
    end

    if apps_count ~= loaded_apps_count then
        print("not loaded apps: "..(apps_count - loaded_apps_count))
    end
end