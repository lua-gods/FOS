---purpose: Handles the Themes
local themes = {
    light = {
        background = vec(1, 1, 1, 1),
        accent = nil, -- accent

        text = vec(0, 0, 0, 1),
        text_locked = vec(0.4, 0.4, 0.4, 1),
        text_select = nil, -- accent
        
        texture = vec(1, 1, 1, 1),
        texture_select = vec(0.75, 0.75, 0.75, 1),
        
        rectangle = vec(0.9, 0.9, 0.9, 1),
        rectangle_select = vec(0.8, 0.8, 0.8, 1),
    },
    dark = {
        background = vec(0.1, 0.1, 0.1, 1),
        accent = nil, -- accent

        text = vec(1, 1, 1, 1),
        text_locked = vec(0.6, 0.6, 0.6, 1),
        text_select = nil, -- accent

        texture = vec(1, 1, 1, 1),
        texture_select = vec(0.75, 0.75, 0.75, 1),

        rectangle = vec(0.15, 0.15, 0.15, 1),
        rectangle_select = vec(0.2, 0.2, 0.2, 1),
    }
}

local themeManager = {themes = themes}

function themeManager.updateTheme()
    -- apply theme
    themes.default = themes[PUBLIC_REGISTRY.theme] or themes.light
    -- apply accent color
    themes.default.accent = PUBLIC_REGISTRY.accent_color.rgb_
    themes.default.accent.a = 1
    
    local color = vectors.rgbToHSV(PUBLIC_REGISTRY.accent_color)
    color.y = math.lerp(color.y, 0.5, 0.75)
    color.z = math.lerp(color.z, 0.75, 0.5)
    
    themes.default.text_select = vectors.hsvToRGB(color).rgb_
    themes.default.text_select.a = 1
end 

themeManager.updateTheme()

function themeManager.readColor(color, obj)
    if type(color) == "Vector4" then
        return color
    elseif type(color) == "Vector3" then
        color = color.rgb_
        color.a = 1
        return color
    elseif type(color) == "string" then
        if color:match("%.") then
            local theme_name, color_name = color:match("^(.*)%.(.*)$")
            return themes[theme_name] and themes[theme_name][color_name] or themes.default.background
        else
            return themes.default[color] or themes.default.background
        end
    end

    return themes.default[obj] or themes.default.background
end


return themeManager
