local app = APP.begin("exammmmpl")

app.pages.main = {
    {type = "text", text = "this is example app still no text wrapping :3"},
    {type = "text", text = "go back", pos = vec(26, 32), pressAction = function() APP.open() end}
}