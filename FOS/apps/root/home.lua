local app = APP.begin("home")

app.pages.main = {
    -- orientation = "portrait" -- not added yet
    {type = "text", text = "Hello World\nmeow\n\nyep this is\nhome screen", pos = vec(0, 0)},
    {type = "text", text = "foxgirl", pos = vec(26, FOS_REGISTRY.resolution.y - 8)},
}


local elements_count = #app.pages.main -- needed to know where its safe to remove elements from list
function app.events.init()
    for i = elements_count + 1, #app.pages.main do
        app.pages.main[i] = nil
    end

    local y = 8*6
    for name in pairs(APP.apps) do
        table.insert(
            app.pages.main,
            {
                type = "text",
                text = name:match(":(.*)"),
                pos = vec(0, y),
                pressAction = function()
                    APP.open(name)
                end
            }
        )
        y = y + 8
    end

    app.setPage("main") -- note: this line is not needed, default page name is "main"
end