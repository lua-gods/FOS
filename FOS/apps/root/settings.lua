local app = APP.begin("settings", "settings")

app.pages.main = {
    {type = "text", text = app.display_name, size = 2}
}