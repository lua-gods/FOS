-- purpose: handles the texture drawing

-- variables --
local fontManager = require(FOS_RELATIVE_PATH..".services.fontManager")
local themeManager = require(FOS_RELATIVE_PATH..".services.ThemeManager")
local raster = {}
local draw_area = vec(0, 0, 0, 0) -- limit drawing

-- screen
local screen_portrait = textures:newTexture(SYSTEM_REGISTRY.system_name..".screen_portrait", SYSTEM_REGISTRY.resolution.x, SYSTEM_REGISTRY.resolution.y)
local screen_landscape = textures:newTexture(SYSTEM_REGISTRY.system_name..".screen_landscape", SYSTEM_REGISTRY.resolution.y, SYSTEM_REGISTRY.resolution.x)

local current_screen = screen_portrait
local screen_size = SYSTEM_REGISTRY.resolution

local landscape_mode_uv_matrix = matrices.mat3(
   vec(1, 0, 0),
   vec(0, 1, 0),
   vec(0, 0, 1)
):rotate(0, 0, -90)

local function set_screen_mode()
   if APP.landscapeMode() then
      current_screen = screen_landscape
      screen_size = SYSTEM_REGISTRY.resolution.yx

      SYSTEM_REGISTRY.screen_model:setUVMatrix(landscape_mode_uv_matrix)
   else
      current_screen = screen_portrait
      screen_size = SYSTEM_REGISTRY.resolution
      SYSTEM_REGISTRY.screen_model:setUVMatrix(matrices.mat3())
   end

   SYSTEM_REGISTRY.screen_model:setPrimaryTexture("CUSTOM", current_screen)
end

-- pixel functions
local function setPixel(x, y, rgba)
   if x >= draw_area.x and y >= draw_area.y and x < draw_area.z and y < draw_area.w then
      current_screen:setPixel(x, y, rgba)
   end
end

local function fillPixels(x, y, width, height, color)
   if width + x > draw_area.x and height + y > draw_area.y then
      current_screen:fill(
         math.max(x, draw_area.x),
         math.max(y, draw_area.y),
         math.min(width, draw_area.z - x),
         math.min(height, draw_area.w - y),
         color
      )
   end
end

-- get render size of something --
local render_size = {
   text = function(obj)
      local font = "minimojangles"

      local pos = obj.pos or vec(0, 0)
      local size = obj.size or 1
      local text = tostring(obj.text)
      local wrap_after = obj.wrap_after or math.huge

      local max_x = 0
      local x, y = 0, fontManager.fonts[font]["\n"].newline_height * size
      for i = 1, #text do
         local data = fontManager.fonts[font][text:sub(i, i)]
         if data then
            if data.newline_height then
               max_x = math.max(x, max_x)
               x, y = 0, y + data.newline_height * size
            elseif x + data.width >= wrap_after then
               max_x = math.max(x, max_x)
               x, y = data.width * size, y + data.newline_height * size
            else
               x = x + data.width * size
            end
         end
      end

      return vec(pos.x, pos.y, math.max(x, max_x), y)
   end,
   texture = function(obj)
      if obj.texture == nil then
         return vec(0, 0, 0, 0)
      end
      local pos = obj.pos or vec(0, 0)
      local size = obj.size or 1
      local dimensions = obj.texture:getDimensions() * size
      return vec(pos.x, pos.y, dimensions.x, dimensions.y)
   end,
   rectangle = function(obj)
      local pos = obj.pos or vec(0, 0)
      local size = obj.size or vec(16, 16)
      return vec(pos.x, pos.y, size.x, size.y)
   end,
   marker = function(obj)
      local pos = obj.pos or vec(0, 0)
      local size = obj.size or vec(0, 0)
      return vec(pos.x, pos.y, size.x, size.y)
   end
}

-- draw something --
local draw_functions = {
   text = function(obj, color, select_color)
      local font = "minimojangles"

      local render_pos = obj.pos or vec(0, 0)
      local text = tostring(obj.text)
      local size = obj.size or 1
      local wrap_after = obj.wrap_after or math.huge

      local pixel_size = math.ceil(size)
   
      local x, y = 0, 0
      local font_height = fontManager.fonts[font]["\n"].newline_height * size
      for i = 1, #text do
         local data = fontManager.fonts[font][text:sub(i, i)]
         if data then
            if data.newline_height then
               x, y = 0, y + font_height
            else
               if x + data.width >= wrap_after then
                  x, y = 0, y + font_height
               end 
               if render_pos.x + x + data.width * size >= draw_area.x and render_pos.x + x < draw_area.z and render_pos.y + y  + font_height >= draw_area.y and render_pos.y + y <= draw_area.w then
                  for _, pos in ipairs(data.bitmap) do
                     fillPixels(render_pos.x + x + pos.x * size, render_pos.y + y + pos.y * size, pixel_size, pixel_size, color)
                  end
               end
               x = x + data.width * size
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
      
      local start_x = math.floor(math.max(0, draw_area.x - render_pos.x) / size) * size
      local start_y = math.floor(math.max(0, draw_area.y - render_pos.y) / size) * size
      local end_x = math.min(dimensions.x - 1, draw_area.z - render_pos.x)
      local end_y = math.min(dimensions.y - 1, draw_area.w - render_pos.y)

      for x = start_x, end_x, size do
         for y = start_y, end_y, size do
            local pixel = texture:getPixel(x * inverted_size, y * inverted_size)
            fillPixels(x + render_pos.x, y + render_pos.y, size, size, pixel * color_to_use)
         end
      end
   end,
   rectangle = function(obj, color, select_color)
      local pos = obj.pos or vec(0, 0)
      local size = obj.size or vec(16, 16)

      local x = math.max(draw_area.x, pos.x)
      local y = math.max(draw_area.y, pos.y)

      fillPixels(
         x,
         y,
         math.min(draw_area.z, pos.x + size.x) - x,
         math.min(draw_area.w, pos.y + size.y) - y,
         select_color or color
      )
   end,
   marker = function() end
}

-- sets space where you can draw, used for optimization, not everything needs to be updated (mostly used for textures) --
local function set_draw_area(page, elements)
   if type(elements) == "table" then
      draw_area = vec(screen_size.x - 1, screen_size.y - 1, 0, 0)
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
      draw_area.z = math.min(draw_area.z, screen_size.x)
      draw_area.w = math.min(draw_area.w, screen_size.y)
   else
      draw_area = vec(0, 0, screen_size.x, screen_size.y)
   end
end

-- draw screen --
function raster.draw(elements, dont_update)
   local page = APP.app.pages[APP.app.current_page]
   
   set_screen_mode()

   set_draw_area(page, elements)

   fillPixels(
      draw_area.x, draw_area.y, draw_area.z - draw_area.x, draw_area.w - draw_area.y,
      themeManager.readColor()
   )

   -- current_screen:applyFunc(0, 0, screen_size.x, screen_size.y, function(c) return math.lerp(c, vec(0.5, 0.5, 0.5, 1), 0.1) end)

   for i, v in ipairs(page) do
      local isSelected = v.pressAction and i == APP.app.selected_item
      if draw_functions[v.type] then
         draw_functions[v.type](
            v,
            themeManager.readColor(v.color, v.type),
            isSelected and themeManager.readColor(v.select_color, v.type.."_select")
         )
      end
   end

   if not dont_update then
      current_screen:update()
   end
end

-- return --
return raster