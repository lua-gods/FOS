-- save to registry
function PUBLIC_REGISTRY.save(name, data)
    if name and data then
        PUBLIC_REGISTRY[name] = data
    end
    config:setName(SYSTEM_REGISTRY.system_name..".registry")
    config:save("main", PUBLIC_REGISTRY)
end

-- can be loaded
local function can_be_loaded(loaded, orginal)
    if type(loaded) ~= type(orginal.default) then
        return false
    elseif (type(orginal.default) == "string" and orginal.length and not (#loaded >= orginal.length.x and #loaded <= orginal.length.y)) then
        return false
    else
        return true
    end
end

-- load
config:setName(SYSTEM_REGISTRY.system_name..".registry")
local data = config:load("main")
if type(data) == "table" then
    for name, value in pairs(PUBLIC_REGISTRY) do
        if name ~= "save" then
            if can_be_loaded(data[name], value) then
                PUBLIC_REGISTRY[name] = data[name]
            else
                PUBLIC_REGISTRY[name] = value.default
            end
        end
    end
end