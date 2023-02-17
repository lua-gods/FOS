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

app.pages.image_view = {
    {type = "texture"},
    {type = "rectangle", pos = vec(0, 140), size = vec(96, 4)},
}

app.pages.image_view_info = {
    {type = "rectangle", size = vec(96, 16)},
    {type = "text", text = "unknown", wrap_after = 96},
    {type = "rectangle", color = "background", pos = vec(0, 16), size = vec(96, 144)},
    {type = "text", text = "resolution: ", pos = vec(0, 24)},
    {type = "text", text = "unknown", pos = vec(0, 32)},
    {type = "rectangle", pos = vec(0, 128), size = vec(96, 16)},
    {type = "text", text = "enter to\nremove photo", pos = vec(0, 128)},
}

local delete_photo
app.pages.delete_photo_confirm = {
    {type = "text", text = "are you sure you\nwant to remove\nthis photo?"},
    {type = "rectangle", pos = vec(0, 128), size = vec(96, 16)},
    {type = "text", pressAction = function() delete_photo() end, text = "yes", pos = vec(0, 128)},
    {type = "text", pressAction = function() app.setPage("image_view") end, text = "no", pos = vec(0, 136)},
}

local pos = vec(0, 0)
local selected_photo = -1

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

    local y_limit = math.ceil(#photos * 0.5) - 1
    local image_offset = pos.y * 2
    local selected = pos.x + 1
    local y_offset
    if pos.y == 0 then
        y_offset = 0
    elseif pos.y == y_limit then
        if #photos <= 4 then
            y_offset = 0
            image_offset = image_offset - 2
            selected = selected + 2
        else
            y_offset = -8
            image_offset = image_offset - 4
            selected = selected + 4
        end
    elseif pos.y >= 1 then
        image_offset = image_offset - 2
        selected = selected + 2
        y_offset = -4
    end

    selected_photo = image_offset + selected

    for i = 1, 6 do
        local image = photos[i + image_offset]
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
            marker.pos.y = math.floor((i - 1) * 0.5) * 48 + 9 + y_offset

            -- set texture
            local center = marker.pos + marker.size * 0.5
            local texture_element = app.pages.image_tile[1]
            texture_element.texture = image[2]
            texture_element.size = 46 / math.min(image[2].width, image[2].height)
            texture_element.pos = center - texture_element.size * image[2]:getDimensions() * 0.5 

            -- draw
            app.current_page = "image_tile"
            app.redraw({-i}, true)

            -- select outline
            if selected == i then
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

local function image_view_page()
    local image = photos[selected_photo]
    if not image then
        return
    end

    if type(image[2]) == "string" then
        local success, output = pcall(texture.read, image[2])
        if success then
            image[2] = output
        else
            return
        end
    end

    local image_element = app.pages.image_view[1]
    local dimensions = image[2]:getDimensions()

    image_element.texture = image[2]
    image_element.size = 96 / dimensions.x
    image_element.pos = vec(0, (144 - image_element.size * dimensions.y) * 0.5)

    app.pages.image_view_info[2].text = image[1]
    app.pages.image_view_info[5].text = dimensions.x.."x"..dimensions.y

    app.setPage("image_view")
end

local function setPage(page)
    if page == "main" or page == nil then
        app.selected_item = -1
        render_gallery()
    elseif page == "image_view" then
        image_view_page()
    else
        app.setPage(page)
    end
end

function app.events.open()
    pos = vec(0, 0)
    get_photos()
    setPage()
end

function app.events.close()
    photos = {}
    app.pages.image_view[1].texture = nil
end

function app.events.key_press(key)
    if app.current_page == "main" then
        local old_pos = pos:copy()
        local y_limit = math.ceil(#photos * 0.5) - 1
        if key == "LEFT" then
            pos.x = 0
        elseif key == "RIGHT" then
            pos.x = 1
        elseif key == "UP" then
            pos.y = math.max(pos.y - 1, 0)
        elseif key == "DOWN" then
            pos.y = math.min(pos.y + 1, y_limit)
        elseif key == "ENTER" then
            setPage("image_view")
            return
        end
        
        if pos.y == y_limit and pos.x == 1 and #photos % 2 == 1 then
            pos.x = 0
        end
        
        if old_pos ~= pos then
            render_gallery()
        end
    elseif app.current_page == "image_view" then
        local old_selected_photo = selected_photo
        if key == "LEFT" then
            selected_photo = math.max(selected_photo - 1, 0)
        elseif key == "RIGHT" then
            selected_photo = math.min(selected_photo + 1, #photos)
        elseif key == "DOWN" then
            pos = vec((selected_photo - 1) % 2, math.floor((selected_photo - 1) / 2))
            setPage()
            return
        elseif key == "UP" then
            setPage("image_view_info")
        end

        if old_selected_photo ~= selected_photo then
            image_view_page()
        end
    elseif app.current_page == "image_view_info" then
        if key == "DOWN" then
            app.setPage("image_view")
        elseif key == "ENTER" then
            app.setPage("delete_photo_confirm")
        end
    end
end

function delete_photo()
    local image = photos[selected_photo]
    if image then
        
        if type(fileSystem.photos) == "table" then
            fileSystem.photos[image[1]] = nil
            fileSystem.save()
        end
    end

    pos = vec(0, 0)
    get_photos()
    setPage()
end