-- purpose: handles the texture drawing

local fontManager = require(FOS_RELATIVE_PATH..".services.fontManager")
local raster = {}

local screen = textures:newTexture(FOS_REGISTRY.system_name..".screen",FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y)

FOS_REGISTRY.screen_model:setPrimaryTexture("CUSTOM",screen)

local function setPixel(x, y, rgba)
   if x >= 0 and y >= 0 and x < FOS_REGISTRY.resolution.x and y < FOS_REGISTRY.resolution.y then
      screen:setPixel(x, y, rgba)
   end
end

local function drawText(obj, isSelected)
   local font = "minimojangles"
   local text_pos = obj.pos or vec(0, 0)
   local text = tostring(obj.text)

   local x, y = 0, 0
   for i = 1, #text do
      local data = fontManager.fonts[font][text:sub(i, i)]
      if data then
         if data.newline_height then
            x, y = 0, y + data.newline_height
         else
            for _, pos in ipairs(data.bitmap) do
               setPixel(text_pos.x + pos.x + x, text_pos.y + pos.y + y, vec(1, 1, 1, 1))
            end
            x = x + data.width
         end
      end
   end

   if isSelected then
      for line_y = 0, y + fontManager.fonts[font]["\n"].newline_height - 1 do
         setPixel(text_pos.x, text_pos.y + line_y, vec(1, 0.5, 0.8, 1))
      end
   end
end

function raster.draw()
   local page = APP.app.pages[APP.app.current_page]

   screen:applyFunc(0,0,FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y,function (col, x, y)
      return vec(0, 0 ,0,1)
   end)

   for i, v in ipairs(page) do
      local isSelected = v.pressAction and i == APP.app.selected_item
      if v.type == "text" then
         drawText(v, isSelected)
      end
   end

   screen:update()
end


return raster