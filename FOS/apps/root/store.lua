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

-- variables --
local current_page = 0
local apps = {}

-- lutils --
local http = lutils and lutils.http;
local readers = lutils and lutils.readers;
local providers = lutils and lutils.providers;

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
        pos = vec(0, i * 8 + 8)
    })
end

-- open
function app.events.open()
    if not lutils then
        return app_error("lutils not found")
    end
    
    local http = lutils.http;

    if not http:canSendHTTPRequests() then
        return app_error("Avatar don't have permission for sending HTTP requests")
    end

    current_page = 0
end