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
    configAppManager.apps[configAppManager.app_to_import_name] = configAppManager.app_to_import
    config:save("apps", configAppManager.apps)

    configAppManager.app_to_import = nil
    configAppManager.app_to_import_name = nil
    
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
    configAppManager.apps = apps
end

return configAppManager