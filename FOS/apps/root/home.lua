local app = APP.begin("home")

app.pages.main = {
    -- orientation = "portrait" -- not added yet
    {type = "text", text = "Hello World\nmeow\n\nyep this is\nhome screen", pos = vec(0, 0)},
    {type = "text", text = "foxgirl", pos = vec(26, FOS_REGISTRY.resolution.y - 8)},
}

function app.events.INIT()
    app.setPage("main") -- note: this line is not needed, default page name is "main"
end