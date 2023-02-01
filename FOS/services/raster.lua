-- purpose: handles the texture drawing

local fontManager = require(FOS_RELATIVE_PATH..".services.fontManager")
local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")
local raster = {}

local screen = textures:newTexture(FOS_REGISTRY.system_name..".screen",FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y)

FOS_REGISTRY.screen_model:setPrimaryTexture("CUSTOM",screen)

local function setPixel(x, y, rgba)
   if x >= 0 and y >= 0 and x < FOS_REGISTRY.resolution.x and y < FOS_REGISTRY.resolution.y then
      screen:setPixel(x, y, rgba)
   end
end

local draw_functions = {
   text = function(obj, color, select_color)
   local font = "minimojangles"
      local render_pos = obj.pos or vec(0, 0)
      local text = tostring(obj.text)
   
      local x, y = 0, 0
      for i = 1, #text do
         local data = fontManager.fonts[font][text:sub(i, i)]
         if data then
            if data.newline_height then
               x, y = 0, y + data.newline_height
            else
               for _, pos in ipairs(data.bitmap) do
                  setPixel(render_pos.x + pos.x + x, render_pos.y + pos.y + y, color)
               end
               x = x + data.width
            end
         end
      end
   
      if select_color then
         for line_y = 0, y + fontManager.fonts[font]["\n"].newline_height - 1 do
            setPixel(render_pos.x, render_pos.y + line_y, select_color)
         end
      end
   end,
   texture = function(obj, color, select_color)
      local render_pos = obj.pos or vec(0, 0)
      local size = obj.size or 1
      local inverted_size = 1 / size
      local texture = obj.texture

      local dimensions = texture:getDimensions() * size
      local color_to_use = select_color or color
      for x = 0, dimensions.x - 1 do
         for y = 0, dimensions.y - 1 do
            local pixel = texture:getPixel(x * inverted_size, y * inverted_size)
            setPixel(render_pos.x + x, render_pos.y + y, pixel * color_to_use)
         end
      end
   end
}

function raster.draw()
   local page = APP.app.pages[APP.app.current_page]

   screen:fill(
      0,
      0,
      FOS_REGISTRY.resolution.x,
      FOS_REGISTRY.resolution.y,
      themeManager.readColor()
   )

   for i, v in ipairs(page) do
      local isSelected = v.pressAction and i == APP.app.selected_item
      if draw_functions[v.type] then
         draw_functions[v.type](
            v,
            themeManager.readColor(v.color, v.type),
            isSelected and themeManager.readColor(v.color, v.type.."_select")
         )
      end
   end

   screen:update()
end


return raster