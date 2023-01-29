local app = APP.begin("home")

--[[
app.pages.main = {
    {type = "text", text = "Hello World", x = 0, y = 0}
}
==]]

---[[
function app.events.INIT()
    print("APP OPENED", app)
end
--]]