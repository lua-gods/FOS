local app = APP.begin("error", "error page")
local printErr = nil

app.can_be_opened = false

local page = {
    {type = "text", text = "", wrap_after = 96}
}
app.pages.main = page

function app.events.open(err, printText)
    printErr = printText
    page[1].text = err
end

function app.events.key_press(key)
    if key == "ENTER" then
        APP.open()
    elseif key == "UP" and printErr then
        print(printErr)
        printErr = nil
        APP.open()
    end
end