-- save to registry
function PUBLIC_REGISTRY.save(name, data)
    if name and data then
        PUBLIC_REGISTRY[name] = data
    end
    config:setName("FOS.registry")
    config:save("main", PUBLIC_REGISTRY)
end

-- load
config:setName("FOS.registry")
local data = config:load("main")
if type(data) == "table" then
    for name, value in pairs(PUBLIC_REGISTRY) do
        if name ~= "save" and type(data[name]) == type(value) then
            PUBLIC_REGISTRY[name] = data[name]
        end
    end
end