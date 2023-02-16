-- purpose: custom texture api because there is not enough textures
texture = {}
local texture_api = {}
local fallback_color = vec(0, 0, 0, 1)

local texture_metatable = {
    __metatable = false,
    __index = texture_api,
}

-- global
function texture.newTexture(x, y)
    return setmetatable({
        width = x,
        height = y,
    }, texture_metatable)
end


local texture_for_reader = nil
local function texture_reader(color, x, y)
    texture_for_reader:setPixel(x, y, color)
end

function texture.read(base64)
    local readed_texture = textures:read("base64_texture_converter", base64) -- im not going to make base64 reader ok? we got figura already
    local dimensions = readed_texture:getDimensions()
    local texture = texture.newTexture(dimensions.x, dimensions.y)

    texture_for_reader = texture
    readed_texture:applyFunc(0, 0, dimensions.x, dimensions.y, texture_reader)
    texture_for_reader = nil

    return texture
end

-- api
function texture_api:getDimensions()
    return vec(self.width, self.height)
end

function texture_api:setPixel(x, y, color)
    local i = math.floor(x) % self.width + math.floor(y) * self.width
    if type(color) == "Vector4" then
        self[i] = color
    else
        color = color.rgb_
        color.a = 1
        self[i] = color
    end
end

function texture_api:getPixel(x, y)
    return self[math.floor(x) % self.width + math.floor(y) * self.width] or fallback_color
end

function texture_api:applyFunc(x, y, w, h, func)
    for pos_x = x, x + w - 1 do
        for pos_y = y, y + h - 1 do
            local c = func(pos_x, pos_y, self:getPixel(pos_x, pos_y))
            if c then
                self:setPixel(c, pos_x, pos_y)
            end
        end
    end
end

function texture_api:fill(x, y, w, h, color)
    for pos_x = x, x + w - 1 do
        for pos_y = y, y + h - 1 do
            self:setPixel(pos_x, pos_y, color)
        end
    end
end

function texture_api:save()
    local texture = textures:newTexture("base64_texture_converter", self.width, self.height)

    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            texture:setPixel(x, y)
        end
    end

    return texture:save()
end

function texture_api:copy()
    local texture = texture.newTexture(self.width, self.height)

    for i, v in pairs(self) do
        if type(i) == "number" then
            texture[i] = v:copy()
        end
    end

    return texture
end