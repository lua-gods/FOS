local tblToID = {}

local function saveData(tbl, i, v)
    if i then
        tbl[i] = v
    end

    config:setName(SYSTEM_REGISTRY.system_name..".apps_data")
    config:save(tblToID[tbl], tbl)
end

local function newAppData(id)
    config:setName(SYSTEM_REGISTRY.system_name..".apps_data")
    local tbl = config:load(id)
    
    if type(tbl) ~= "table" then
        tbl = {}
    end
    
    tbl.save = saveData
    
    tblToID[tbl] = id
    
    return tbl
end

return newAppData