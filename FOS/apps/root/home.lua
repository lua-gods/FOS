local app = APP.begin("home")

app.pages.main = {
    -- orientation = "portrait" -- not added yet
    {type = "text", text = "Hello World", x = 0, y = 0}
}

function app.events.INIT()
    print("APP OPENED", app)

    app.setPage("main") -- note: this line is not needed, default page name is "main"
end