local configAppManager = {}
configAppManager.exportable = {}
configAppManager.apps = {}

-- export
function configAppManager.export(name)
    if not APP.apps[name] then
        print("app "..tostring(name).." not found")
        return
    end

    if not configAppManager.exportable[name] then
        print("could not export "..tostring(name))
        return
    end
    
    local str = configAppManager.exportable[name]
    config:setName(SYSTEM_REGISTRY.system_name..".exported_app")
    config:save("app_name", tostring(name))
    config:save("app", str)

    print("exported "..tostring(name).." to FOS.exported_app")
end
-- /figura run require(FOS_RELATIVE_PATH..".services.configAppManager").export("user:example")

-- install
function configAppManager.install()
    if not configAppManager.app_to_import then
        print("could not install app")
        return
    end
    
    config:setName(SYSTEM_REGISTRY.system_name..".exported_app")
    config:save("app_name", nil)
    config:save("app", nil)

    config:setName(SYSTEM_REGISTRY.system_name..".apps")
    if configAppManager.app_to_import_name:sub(1, 7) == "CONFIG." then
        configAppManager.apps[configAppManager.app_to_import_name] = configAppManager.app_to_import
    else
        configAppManager.apps["CONFIG."..configAppManager.app_to_import_name] = configAppManager.app_to_import
    end
    config:save("apps", configAppManager.apps)

    configAppManager.app_to_import = nil
    configAppManager.app_to_import_name = nil
    
    APP.loadApps()
end

function configAppManager.installFromString(...)
    local list = {...}

    for i = 1, #list, 2 do
        local name = list[i]
        local code = list[i + 1]
        if name:sub(1, 7) == "CONFIG." then
            configAppManager.apps[name] = code
        else
            configAppManager.apps["CONFIG."..name] = code
        end
    end
        
    config:setName(SYSTEM_REGISTRY.system_name..".apps")
    config:save("apps", configAppManager.apps)

    APP.loadApps()
end

function configAppManager.ignore_install()
    if configAppManager.app_to_import then
        config:setName(SYSTEM_REGISTRY.system_name..".exported_app")
        config:save("app_name", nil)
        config:save("app", nil)
        
        configAppManager.app_to_import = nil
        configAppManager.app_to_import_name = nil
    end
end

-- uninstall
function configAppManager.uninstall(id)
    config:setName(SYSTEM_REGISTRY.system_name..".apps")
    local app = APP.apps[id]
    for i, v in ipairs(APP.sorted_apps) do
        if v == id then
            table.remove(APP.sorted_apps, i)
            break
        end
    end
    APP.loaded_apps[app.path] = nil
    configAppManager.apps[app.path] = nil
    config:save("apps", configAppManager.apps)
end

-- allow to install
config:setName(SYSTEM_REGISTRY.system_name..".exported_app")
local import_app = config:load("app")
local import_app_name = config:load("app_name")
if type(import_app) == "string" and type(import_app_name) == "string" then
    configAppManager.app_to_import = import_app
    configAppManager.app_to_import_name = "CONFIG."..import_app_name
end

-- load apps
config:setName(SYSTEM_REGISTRY.system_name..".apps")
local apps = config:load("apps")
if type(apps) == "table" then
    configAppManager.apps = {}
    for i, v in pairs(apps) do
        if i:sub(1, 7) == "CONFIG." then
            configAppManager.apps[i] = v
        else
            configAppManager.apps["CONFIG."..i] = v
        end
    end
end

return configAppManager