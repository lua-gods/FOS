local app = APP.begin("camera")

local image_preview_size = 2
local image_preview = texture.newTexture(128 / image_preview_size, 96 / image_preview_size)

local screen_texture

app.pages.main = {
    orientation = "landscape",
    -- {type = "rectangle", size = vec(96, 8)},
    -- {type = "text", text = app.display_name},
    {type = "rectangle", size = vec(8, 96)},
    {type = "text", text = app.display_name, wrap_after = 0, pos = vec(0, -8)},
    {type = "texture", texture = image_preview, size = image_preview_size, pos = vec(8, 0)}
}

function app.events.render(delta)
    if not screen_texture then
        -- screen_texture = host:screenshot("CAMERA")
    end
end