local app = APP.begin("gallery", "gallery")

app.pages.main = {
    {type = "rectangle", size = vec(96, 8)},
    {type = "text", text = app.display_name},
}

app.pages.empty = {}

app.pages.image_tile = {
    {type = "texture"},
    [-1] = {type = "marker", pos = vec(1, 0), size = vec(46, 46)},
    [-2] = {type = "marker", pos = vec(48 + 1, 0), size = vec(46, 46)},
    [-3] = {type = "marker", pos = vec(1, 0), size = vec(46, 46)},
    [-4] = {type = "marker", pos = vec(48 + 1, 0), size = vec(46, 46)},
    [-5] = {type = "marker", pos = vec(1, 0), size = vec(46, 46)},
    [-6] = {type = "marker", pos = vec(48 + 1, 0), size = vec(46, 46)},
}

app.pages.selected_photo = {{type = "rectangle", color = "text"}}
local selected_photo_lines = {
    vec(0, 0, 1, 46),
    vec(45, 0, 1, 46),
    vec(1, 0, 44, 1),
    vec(1, 45, 44, 1),
}

local pos = vec(0, 0)

local photos = {}

local function sort_func(a, b)
    return a[1] > b[1]
end

local function get_photos()
    photos = {}
    if type(fileSystem.photos) == "table" then
        for i, v in pairs(fileSystem.photos) do
            table.insert(photos, {i, v})
        end
    end

    table.sort(photos, sort_func)
end

local function render_gallery()
    app.current_page = "empty"
    app.redraw(nil, true)

    for i = 1, 6 do
        local image = photos[i + pos.y * 2]
        if image then
            -- convert string to texture if needed
            if type(image[2]) == "string" then
                local success, output = pcall(texture.read, image[2])
                if success then
                    image[2] = output
                else
                    goto next
                end
            end

            -- set marker pos
            local marker = app.pages.image_tile[-i]
            marker.pos.y = math.floor((i - 1) * 0.5) * 48 + 9

            -- set texture
            local center = marker.pos + marker.size * 0.5
            local texture_element = app.pages.image_tile[1]
            texture_element.texture = image[2]
            texture_element.size = 46 / math.min(image[2].width, image[2].height)
            texture_element.pos = center - texture_element.size * image[2]:getDimensions() * 0.5 

            -- draw
            app.current_page = "image_tile"
            app.redraw({-i}, true)

            -- select
            local isSelected = i == 1
            if isSelected then
                app.current_page = "selected_photo"
                for _, v in ipairs(selected_photo_lines) do
                    app.pages.selected_photo[1].pos = v.xy + marker.pos
                    app.pages.selected_photo[1].size = v.zw
                    app.redraw({1}, false)
                end
            end
        end
        ::next::
    end
    app.pages.image_tile.texture = nil
    
    app.current_page = "main"
    app.redraw({1})
end

local function setPage(page)
    if page == "main" or page == nil then
        app.selected_item = -1
        pos = vec(0, 0)
        get_photos()
        render_gallery()
    else
        app.setPage(page)
    end
end

function app.events.open()
    setPage()
end

function app.events.close()
    photos = {}
end

function app.events.tick()

end