local app = APP.begin("home")

app.pages.main = {
    -- orientation = "portrait" -- not added yet
    {type = "text", text = "Hello World\nmeow\n\nyep this is\nhome screen", pos = vec(0, 0)},
    {type = "text", text = "foxgirl", pos = vec(26, FOS_REGISTRY.resolution.y - 8)},
}

local elements_count = #app.pages.main

function app.events.init()
    for i = elements_count + 1, #app.pages.main do
        app.pages.main[i] = nil
    end

    local y = 8*6
    for name, data in pairs(APP.apps) do
        table.insert(
            app.pages.main,
            {type = "text", text = name, pos = vec(0, y)}
        )
        y = y + 8
    end

    app.setPage("main") -- note: this line is not needed, default page name is "main"
end

function app.events.key_press(KEY)
    if KEY == "DOWN" then
        if APP.apps["user:exammmmpl"] then
            APP.open("user:exammmmpl")
        end
    end
end