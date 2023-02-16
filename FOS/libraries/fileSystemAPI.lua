config:setName(SYSTEM_REGISTRY.system_name..".files")
fileSystem = config:load("main")

if type(fileSystem) ~= "table" then
    fileSystem = {}
end

function fileSystem.save()
    config:setName(SYSTEM_REGISTRY.system_name..".files")
    config:save("main", fileSystem)
end