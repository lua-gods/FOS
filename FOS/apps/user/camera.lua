local app = APP.begin("camera")

local image_preview_size = 4

local landscape_mode = false

local image_preview_portrait = texture.newTexture(96 / image_preview_size, 128 / image_preview_size)
local image_preview_landscape = texture.newTexture(128 / image_preview_size, 96 / image_preview_size)

local screen_texture

app.pages.portrait = {
    orientation = "portrait",
    {type = "texture", texture = image_preview_portrait, size = image_preview_size, pos = vec(0, 0)},
    -- {type = "rectangle", size = vec(96, 8)},
    -- {type = "text", text = app.display_name},
}

app.pages.landscape = {
    orientation = "landscape",
    {type = "texture", texture = image_preview_landscape, size = image_preview_size, pos = vec(0, 0)},
}

function app.events.init()
    landscape_mode = false
    app.setPage("portrait")
end

function app.events.key_press(key)
    if key == "DOWN" then
        landscape_mode = true
        app.setPage("landscape")
    elseif key == "UP" then
        landscape_mode = false
        app.setPage("portrait")
    end
end

function app.events.render(delta)
    screen_texture = host:screenshot("CAMERA")
end

function app.events.tick()
    if not screen_texture then
        return
    end

    -- texture to draw on
    local texture = landscape_mode and image_preview_landscape or image_preview_portrait

    -- calculate position and scale for getting pixels
    local aspect_ratio = texture.width / texture.height

    local screen_dimensions = screen_texture:getDimensions()

    local size = vec(0, 0)
    if screen_dimensions.x / screen_dimensions.y > aspect_ratio then
        size.y = screen_dimensions.y
        size.x = screen_dimensions.y * aspect_ratio
    else
        size.x = screen_dimensions.x
        size.y = screen_dimensions.x / aspect_ratio
    end
    
    local pos = (screen_dimensions - size) * 0.5
    
    size.x = size.x / texture.width
    size.y = size.y / texture.height 

    -- get pixels
    for x = 0, texture.width - 1 do
        for y = 0, texture.height - 1 do
            texture:setPixel(
                x,
                y,
                screen_texture:getPixel(
                    x * size.x + pos.x,
                    y * size.y + pos.y
                )
            )
        end
    end

    -- update screen
    app.redraw({1})
end