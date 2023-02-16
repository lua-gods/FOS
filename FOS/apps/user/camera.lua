local app = APP.begin("camera", "camera")

local toast_time = 0

local image_preview_size = 4
local landscape_mode = false
local drawing_process = 0
local taking_photo_process = 0
local get_screen = true

local image_preview_portrait = texture.newTexture(96 / image_preview_size, 128 / image_preview_size)
local image_preview_landscape = texture.newTexture(128 / image_preview_size, 96 / image_preview_size)

local screen_texture

app.pages.portrait = {
    orientation = "portrait",
    {type = "texture", texture = image_preview_portrait, size = image_preview_size, pos = vec(0, 8)},
    {type = "marker", pos = vec(0, 136), size = vec(96, 8)},
    {type = "text", text = "", pos = vec(0, 136)},
    {type = "text", text = app.display_name, pos = vec(26, 0)},
}

app.pages.landscape = {
    orientation = "landscape",
    {type = "texture", texture = image_preview_landscape, size = image_preview_size, pos = vec(8, 0)},
    {type = "marker", pos = vec(136, 0), size = vec(8, 96)},
    {type = "text", text = "", wrap_after = 0, pos = vec(136, -8)},
    {type = "text", text = app.display_name, wrap_after = 0, pos = vec(0, 14)}
}

local function set_toast(str, time)
    toast_time = time or 40
    app.pages.portrait[3].text = str
    app.pages.landscape[3].text = str
    app.redraw({2})
end

function app.events.init()
    landscape_mode = false
    app.setPage("portrait")
    drawing_process = 0

    set_toast("enter to take photo")
end

function app.events.key_press(key)
    if taking_photo_process >= 1 then
        return
    end

    if key == "DOWN" then
        drawing_process = 0
        landscape_mode = true
        app.setPage("landscape")
    elseif key == "UP" then
        drawing_process = 0
        landscape_mode = false
        app.setPage("portrait")
    elseif key == "ENTER" then
        taking_photo_process = 1
    end
end

local function calculate_pos_size()
    -- texture to draw on
    local preview_texture = landscape_mode and image_preview_landscape or image_preview_portrait

    -- calculate position and scale for getting pixels
    local aspect_ratio = preview_texture.width / preview_texture.height

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

    return pos, size, preview_texture
end

function app.events.render()
    if get_screen then
        screen_texture = host:screenshot("CAMERA")
        get_screen = false
    end
end

function app.events.tick()
    if not screen_texture then
        get_screen = true
        return
    end

    -- update toast
    if toast_time >= 1 then
        toast_time = toast_time - 1
        if toast_time <= 0 then
            set_toast("", 0)
        end
    end

    -- drawing preview
    if taking_photo_process >= 1 then
        if taking_photo_process == 1 then
            local pos, size, preview_texture = calculate_pos_size()
            local width, height = preview_texture.width * image_preview_size, preview_texture.height * image_preview_size

            local image = texture.newTexture(width, height)
            
            size.x = size.x / image.width
            size.y = size.y / image.height
            
            for x = 0, image.width - 1 do
                for y = 0, image.height - 1 do
                    image:setPixel(x, y, screen_texture:getPixel(x * size.x + pos.x, y * size.y + pos.y))
                end
            end
            
            set_toast("took photo", 20)

            local date = client:getDate()
            local file_name = string.format("photo-%s-%s-%s-%s-%s-%s", date.second, date.minute, date.hour, date.day, date.month, date.year)
            if fileSystem.photos == nil then
                fileSystem.photos = {}
            end
            if type(fileSystem.photos) == "table" then
                fileSystem.photos[file_name] = image:save()
                fileSystem.save()
            end
        end
        taking_photo_process = (taking_photo_process + 1) % 2
    else
        if drawing_process == 0 then   
            local pos, size, preview_texture = calculate_pos_size()
            
            size.x = size.x / preview_texture.width
            size.y = size.y / preview_texture.height
            
            for x = 0, preview_texture.width - 1 do
                for y = 0, preview_texture.height - 1 do
                    preview_texture:setPixel(x, y, screen_texture:getPixel(x * size.x + pos.x, y * size.y + pos.y))
                end
            end
            
            get_screen = true
        elseif drawing_process == 1 then
            app.redraw({1})
        end
        
        drawing_process = (drawing_process + 1) % 2
    end
end