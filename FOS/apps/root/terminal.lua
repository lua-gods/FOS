local app = APP.begin("terminal", "terminal")

local text_element = {type = "text", text = "input", wrap_after = 96, pos = vec(0, 8)}

app.pages.main = {
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
    {type = "marker", pos = vec(0, 8), size = vec(96, 144 - 8)},
    text_element
}

function app.events.open()
    text_element.text = ""
end

function app.events.keyboard(text, sent)
    text_element.text = text or ""
    if sent then
        text_element.text = ""
        pcall(loadstring(text.." "))
    end
    app.redraw({3})
end