-- app --
local app = APP.begin("app_store", "app store")

-- services --
local configAppManager = require(FOS_RELATIVE_PATH..".services.configAppManager")

--[=[
configAppManager.installFromString("pink", [[
local app = APP.begin("installedFromCode", "installed from app store")
]])
--]=]

-- config --
local appsPerPage = 14
local backend_ip = app.data.ip or "http://127.0.0.1:3000/"
local appLoadingText = {{name = "loading apps"}, {name = "might take a while"}}

-- variables --
local current_page = 0
local apps = {}
local appElementList = {}
local requests = {}

-- lutils --
local http = lutils and lutils.http
local readers = lutils and lutils.readers
local providers = lutils and lutils.providers

local function httpGet(url, func)
    table.insert(requests, {
        func = func,
        res = http:getAsync(backend_ip..url, readers.string)
        -- res = http:getAsync(url, readers.string)
    })
end

function app.events.tick()
    for i, v in pairs(requests) do
        if v.res:isDone() then
            local res = v.res:get()
            v.func(res, res:getCode(), res:getData())
            requests[i] = nil
        end
    end
end

-- pages --
local function app_error(text)
    app.pages["error"][3].text = "error:\n"..text
    app.setPage("error")
end

app.pages["error"] = { -- app error
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
    {type = "text", pos = vec(0, 16), text = "no error\nhere is bunny:\n/)_/)\n{  .  . }\n/      >", wrap_after = 96},
}

app.pages["main"] = { -- app list
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
}

for i = 1, appsPerPage do
    table.insert(app.pages["main"], {
        type = "text",
        text = i,
        pos = vec(0, i * 8 + 8),
        pressAction = true
    })
    table.insert(appElementList, app.pages["main"][#app.pages["main"]])
end

-- functions
local function updateAppList(dont_redraw)
    for i = 1, appsPerPage do
        local selectedApp = apps[i + appsPerPage * current_page]
        if selectedApp then
            appElementList[i].text = selectedApp.name
        else
            appElementList[i].text = ""
        end
    end

    if not dont_redraw then
        app.redraw()
    end
end

-- request functions
local request_functions = {
    getList = function(res, code, data)
        apps = {}
        for text in data:gmatch("[^\n]*\n?") do
            local id, owner, name = text:match("[^\n]*"):match("([^;]*);([^;]*);(.*)")
            if id and owner and name then
                table.insert(apps, {
                    id = id,
                    owner = owner,
                    name = name
                })
            end
        end

        table.sort(apps, function(a, b) return a.name < b.name end)
        updateAppList()
    end
}

-- open
function app.events.open()
    -- errors
    if not lutils then
        return app_error("lutils not found")
    end
    if not http:canSendHTTPRequests() then
        return app_error("Avatar don't have permission for sending HTTP requests")
    end

    -- no errors
    current_page = 0
    requests = {}
    apps = appLoadingText
    updateAppList(true)
    httpGet("api/list", request_functions.getList)
end

-- switching pages
function app.events.key_press(key)
    if app.current_page == "main" then
        if key == "LEFT" then
            current_page = math.max(current_page - 1, 0)
            updateAppList()
        elseif key == "RIGHT" then
            current_page = math.clamp(current_page + 1, 0, math.ceil(#apps / appsPerPage - 1))
            updateAppList()
        end
    end
end