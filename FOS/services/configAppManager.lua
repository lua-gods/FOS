local configAppManager = {}
configAppManager.exportable = {}

function configAppManager.export(name)
    if not configAppManager.exportable[name] then
        return
    end
    local str = configAppManager.exportable[name]

    config:setName("FOS.exported_app")
    config:save("app_name", name)
    config:save("app", str)

    print("exported "..name.." to FOS.exported_app")
end

-- /figura run require(FOS_RELATIVE_PATH..".services.configAppManager").export("user")
return configAppManager