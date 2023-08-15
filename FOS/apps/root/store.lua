-- app --
local app = APP.begin("app_store", "app store")

-- services --
local configAppManager = require(FOS_RELATIVE_PATH..".services.configAppManager")

-- config --
local appsPerPage = 15
local backend_ip = "https://fosappstorebackend.glitch.me/" --"http://127.0.0.1:3000/"
local appLoadingText = {{name = "loading apps", locked = true}, {name = "might take a while", locked = true}}
local welcomeText = "Welcome to\nfos app store\n\nclick left or right\nto switch between\npages\n\nyou can upload\nyour apps at:\n"..backend_ip..'\ntip: you can click\n"app store" text\nat top'

-- variables --
local current_page = -1
local apps = {}
local searchedApps = {}
local appElementList = {}
local requests = {}
local appsListElementOffset = 0
local request_functions
local last_selected_app_item = 0
local authors = {}
local selectedApp = nil
local isInstalled = {} -- 1 = installing, 2 = installed
local appsToInstall = {}
local search_query = ""
local appsToUpdate = {}
local updateCount = 0
local appIdToAppPath
local appPathToAppId
local updateAppUpdateText

-- lutils --
local http = lutils and lutils.http
local readers = lutils and lutils.readers
local providers = lutils and lutils.providers

local function httpGet(url, func, data)
    table.insert(requests, {
        func = func,
        extra_data = data,
        res = http:getAsync(backend_ip..url, readers.string)
        -- res = http:getAsync(url, readers.string)
    })
end

function app.events.tick()
    for i, v in pairs(requests) do
        if v.res:isDone() then
            local res = v.res:get()
            v.func(res, res:getCode(), res:getData(), v.extra_data)
            requests[i] = nil
        end
    end
end

-- pages --
local function app_error(text)
    app.pages["error"][3].text = text
    app.setPage("error")
end

app.pages["error"] = { -- app error
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
    {type = "text", pos = vec(0, 16), text = "meow", wrap_after = 96}
}

app.pages["main"] = { -- app list
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name, pressAction = function() app.setPage("settings") end},
    {type = "text", text = "pages", pos = vec(0, 8 * 17)},
    {type = "text", text = "1-2", pos = vec(0, 8 * 17)},
    {type = "text", text = "welcome", pos = vec(0, 12), wrap_after = 96},
}

app.pages["settings"] = { -- settings
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = "settings"},
    {type = "text", text = "update apps", pos = vec(0, 16), pressAction = function()
        if #appsToUpdate >= 1 then
            return
        end 

        for path in pairs(configAppManager.apps) do
            local id = appPathToAppId(path)
            if id then
                isInstalled[id] = 2
                table.insert(appsToUpdate, id)
            end
        end

        if #appsToUpdate >= 1 then
            updateCount = #appsToUpdate
            updateAppUpdateText()
            httpGet("api/getApp?id="..appsToUpdate[#appsToUpdate], request_functions.updateApp)
        end
    end}
}

app.pages["appMenu"] = {
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
    {type = "text", text = "app", pos = vec(0, 8 + 4)}, -- 3 name
    {type = "text", text = "author", pos = vec(0, 16 + 4), color="text_locked"}, -- 4 author
    {type = "text", text = "description", wrap_after = 96, pos = vec(0, 8 * 4)}, -- 5 description
    {type = "rectangle", size = vec(96, 8), pos = vec(0, 136)},
    {type = "text", text = "install", pos = vec(0, 136), pressAction = function(element) -- 7 install/update button
        if element.color == "text_locked" then
            return
        end

        element.text = "installing"
        element.color = "text_locked"
        isInstalled[selectedApp.id] = 1
        app.redraw()

        httpGet("api/getApp?id="..selectedApp.id, request_functions.installApp, selectedApp)
    end},
}

appsListElementOffset = #app.pages["main"]
for i = 1, appsPerPage do
    table.insert(app.pages["main"], {
        type = "text",
        text = i,
        pos = vec(0, i * 8 + 4),
        pressAction = true
    })
    table.insert(appElementList, app.pages["main"][#app.pages["main"]])
end

-- functions
function updateAppUpdateText(dont_redraw)
    if #appsToUpdate >= 1 then
        app.pages["settings"][3].text = "updating: "..(updateCount - #appsToUpdate).."/"..updateCount
        app.pages["settings"][3].color = "text_locked"
    else
        app.pages["settings"][3].text = "update"
        app.pages["settings"][3].color = "text"
    end

    if not dont_redraw then
        app.redraw()
    end
end

local function updatePageCounter()
    local text = current_page + 1
    local offset = 0
    if current_page == -1 then
        text = "info"
        offset = offset + 5
    end
    
    text = text.."/"..math.max(math.ceil(#searchedApps / appsPerPage), 1)

    app.pages["main"][4].text = text
    app.pages["main"][4].pos.x = 96 - #text * 6 + offset
end

local function updateSearch()
    searchedApps = {}
    for i, v in pairs(apps) do
        if v.name:match(search_query) then
            table.insert(searchedApps, v)
        end
    end
end

function appIdToAppPath(id)
    return "CONFIG.appStore."..id
end

function appPathToAppId(path)
    if path:sub(1, 16) == "CONFIG.appStore." then
        return path:sub(17, -1)
    end
end

local function updateAppList(dont_redraw)
    for i = 1, appsPerPage do
        local appI = searchedApps[i + appsPerPage * current_page]
        if appI then
            appElementList[i].text = appI.name
        else
            appElementList[i].text = ""
        end
    end

    updatePageCounter()

    app.pages.main[5].text = current_page == -1 and welcomeText or ""

    if not dont_redraw then
        app.redraw()
    end
end

local function openAppMenu(appToOpen)
    if appToOpen == nil or appToOpen.locked then
        return
    end

    last_selected_app_item = app.selected_item
    selectedApp = appToOpen

    app.pages["appMenu"][3].text = appToOpen.name
    if authors[appToOpen.owner] then
        app.pages["appMenu"][4].text = authors[appToOpen.owner]
    else
        app.pages["appMenu"][4].text = appToOpen.owner
        httpGet("api/getName?id="..appToOpen.owner, request_functions.getAuthor, appToOpen.owner)
    end
    if appToOpen.description then
        app.pages["appMenu"][5].text = appToOpen.description
    else
        app.pages["appMenu"][5].text = "loading"
        httpGet("api/getDescription?id="..appToOpen.id, request_functions.getDescription, appToOpen)
    end
    if configAppManager.apps[appIdToAppPath(appToOpen.id)] or isInstalled[appToOpen.id] == 2 then
        app.pages["appMenu"][7].text = "installed"
        app.pages["appMenu"][7].color = "text_locked"
    elseif isInstalled[appToOpen.id] == 1 then
        app.pages["appMenu"][7].text = "installing"
        app.pages["appMenu"][7].color = "text_locked"
    else
        app.pages["appMenu"][7].text = "install"
        app.pages["appMenu"][7].color = "text"
    end

    app.setPage("appMenu")
end

for i = 1, appsPerPage do
    appElementList[i].pressAction = function()
        openAppMenu(searchedApps[i + appsPerPage * current_page])
    end
end

-- request functions
request_functions = {
    getList = function(res, code, data)
        if code ~= 200 then
            return
        end
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
        updateSearch()
        updateAppList()
    end,
    getDescription = function(res, code, data, extra_data)
        if code ~= 200 then
            return
        end
        extra_data.description = data
        if app.current_page == "appMenu" then
            if selectedApp == extra_data then
                app.pages["appMenu"][5].text = data
            end
            app.redraw()
        end
    end,
    getAuthor = function(res, code, data, extra_data)
        if code ~= 200 then
            return
        end
        authors[extra_data] = data
        if app.current_page == "appMenu" then
            if selectedApp.owner == extra_data then
                app.pages["appMenu"][4].text = data
            end
            app.redraw()
        end
    end,
    installApp = function(res, code, data, extra_data)
        if code ~= 200 then
            return
        end
        isInstalled[extra_data.id] = 2
        app.pages["appMenu"][7].text = "installed"
        app.pages["appMenu"][7].color = "text_locked"
        app.redraw()
        table.insert(appsToInstall, appIdToAppPath(extra_data.id))
        table.insert(appsToInstall, data)
    end,
    updateApp = function(res, code, data, extra_data)
        if code ~= 200 then
            return
        end

        if data ~= "" then
            local path = appIdToAppPath(appsToUpdate[#appsToUpdate])
            for _, v in pairs(APP.apps) do
                if v.path == path then
                    configAppManager.uninstall(v.id)
                    break
                end 
            end
            table.insert(appsToInstall, path)
            table.insert(appsToInstall, data)
        end

        appsToUpdate[#appsToUpdate] = nil
        if #appsToUpdate >= 1 then
            httpGet("api/getApp?id="..appsToUpdate[#appsToUpdate], request_functions.updateApp)
        end
        updateAppUpdateText()
    end,
}

-- open
function app.events.open()
    -- errors
    do
        return app_error("sorry fos app\nstore has been\narchived")
    end
    if not lutils then
        return app_error("error:\nlutils not found\nyou can download\nlutils at:\nhttps://github.com/lexize/lutils\n\ngo to actions tab\nto download latest\nversion (requires github account)")
    end
    if not http:canSendHTTPRequests() then
        return app_error("error:\nAvatar don't have permission for sending HTTP requests")
    end

    -- no errors
    isInstalled = {}
    current_page = -1
    requests = {}
    apps = appLoadingText
    search_query = ""
    updateSearch()

    appsToInstall = {}
    updateAppUpdateText(true)
    updateAppList(true)
    httpGet("api/list", request_functions.getList)
end

-- switching pages
function app.events.post_key_press(key)
    if app.current_page == "main" then
        local limit = math.max(math.ceil(#searchedApps / appsPerPage - 1), -1)
        if key == "LEFT" then
            current_page = math.max(current_page - 1, -1)
            updateAppList()
        elseif key == "RIGHT" then
            current_page = math.min(current_page + 1, limit)
            updateAppList()
        end
        if current_page == limit then
            local limit_of_page = #searchedApps % appsPerPage + appsListElementOffset
            if app.selected_item > limit_of_page then
                app.selected_item = limit_of_page
                app.redraw()
            end
        end
    elseif app.current_page == "appMenu" then
        if key == "LEFT" then
            app.setPage("main")
            app.selected_item = last_selected_app_item
            app.redraw()
        end
    elseif app.current_page == "settings" then
        if key == "LEFT" then
            app.setPage("main")
        end
    end
end

-- quit app
function app.events.close()
    if #appsToInstall >= 2 then
        configAppManager.installFromString(table.unpack(appsToInstall))
    end
    appsToInstall = {}
    isInstalled = {}
end

-- search
function app.events.keyboard(text, sent)
    if app.current_page == "main" then
        app.pages.main[2].text = text ~= "" and text or app.display_name
        search_query = text or ""
        updateSearch()
        updateAppList()
    end
end
