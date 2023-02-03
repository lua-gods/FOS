-- purpose: handles the texture drawing

-- variables --
local fontManager = require(FOS_RELATIVE_PATH..".services.fontManager")
local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")
local raster = {}
local draw_area = vec(0, 0, 0, 0) -- limit drawing

-- screen
local screen = textures:newTexture(SYSTEM_REGISTRY.system_name..".screen",SYSTEM_REGISTRY.resolution.x,SYSTEM_REGISTRY.resolution.y)

SYSTEM_REGISTRY.screen_model:setPrimaryTexture("CUSTOM",screen)

local function setPixel(x, y, rgba)
   if x >= draw_area.x and y >= draw_area.y and x < draw_area.z and y < draw_area.w then
      screen:setPixel(x, y, rgba)
   end
end

-- get render size of something --
local render_size = {
   text = function(obj, newline_split)
      if newline_split then
         return nil
      end

      local font = "minimojangles"
      local pos = obj.pos or vec(0, 0)
      local text = tostring(obj.text)
      local x, y = 0, fontManager.fonts[font]["\n"].newline_height
      for i = 1, #text do
         local data = fontManager.fonts[font][text:sub(i, i)]
         if data then
            if data.newline_height then
               x, y = 0, y + data.newline_height
            else
               x = x + data.width
            end
         end
      end

      return vec(pos.x, pos.y, x, y)
   end,
   texture = function(obj)
      if obj.texture == nil then
         return vec(0, 0, 0, 0)
      end
      local pos = obj.pos or vec(0, 0)
      local size = obj.size or 1
      local dimensions = obj.texture:getDimensions() * size
      return vec(pos.x, pos.y, dimensions.x, dimensions.y)
   end
}

-- draw something --
local draw_functions = {
   text = function(obj, color, select_color)
      local font = "minimojangles"
      local render_pos = obj.pos or vec(0, 0)
      local text = tostring(obj.text)
   
      local x, y = 0, 0
      local font_height = fontManager.fonts[font]["\n"].newline_height
      for i = 1, #text do
         local data = fontManager.fonts[font][text:sub(i, i)]
         if data then
            if data.newline_height then
               x, y = 0, y + font_height
            else
               if render_pos.x + x + data.width >= draw_area.x and render_pos.x + x < draw_area.z and render_pos.y >= draw_area.y and render_pos.y + font_height <= draw_area.w then
                  for _, pos in ipairs(data.bitmap) do
                     setPixel(render_pos.x + pos.x + x, render_pos.y + pos.y + y, color)
                  end
               end
               x = x + data.width
            end
         end
      end
   
      if select_color then
         for line_y = 0, y + font_height - 1 do
            setPixel(render_pos.x, render_pos.y + line_y, select_color)
         end
      end
   end,
   texture = function(obj, color, select_color)
      local render_pos = obj.pos or vec(0, 0)
      local size = obj.size or 1
      local inverted_size = 1 / size
      local texture = obj.texture
      if texture == nil then return end

      local dimensions = texture:getDimensions() * size
      local color_to_use = select_color or color
      for x = math.max(draw_area.x), math.min(dimensions.x - 1, draw_area.z) do
         for y = math.max(draw_area.y), math.min(dimensions.y - 1, draw_area.w) do
            local pixel = texture:getPixel(x * inverted_size, y * inverted_size)
            setPixel(render_pos.x + x, render_pos.y + y, pixel * color_to_use)
         end
      end
   end
}

-- sets space where you can draw, used for optimization, not everything needs to be updated (mostly used for textures) --
local function set_draw_area(page, elements)
   if type(elements) == "table" then
      draw_area = vec(SYSTEM_REGISTRY.resolution.x - 1, SYSTEM_REGISTRY.resolution.y - 1, 0, 0)
      for _, i in pairs(elements) do
         if page[i] and render_size[page[i].type] then
            local pos_size = render_size[page[i].type](page[i])

            draw_area.x = math.min(draw_area.x, pos_size.x)
            draw_area.y = math.min(draw_area.y, pos_size.y)
            draw_area.z = math.max(draw_area.z, pos_size.x + pos_size.z)
            draw_area.w = math.max(draw_area.w, pos_size.y + pos_size.w)
         end
      end
      draw_area.x = math.max(draw_area.x, 0)
      draw_area.y = math.max(draw_area.y, 0)
      draw_area.z = math.min(draw_area.z, SYSTEM_REGISTRY.resolution.x)
      draw_area.w = math.min(draw_area.w, SYSTEM_REGISTRY.resolution.y)
   else
      draw_area = vec(0, 0, SYSTEM_REGISTRY.resolution.x, SYSTEM_REGISTRY.resolution.y)
   end
end

-- draw screen --
function raster.draw(elements)
   local page = APP.app.pages[APP.app.current_page]

   set_draw_area(page, elements)

   screen:fill(
      draw_area.x, draw_area.y, draw_area.z - draw_area.x, draw_area.w - draw_area.y,
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

-- return --
return raster