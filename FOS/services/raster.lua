-- purpose: handles the texture drawing

local fontManager = require(FOS_RELATIVE_PATH..".services.fontManager")
local raster = {}

local screen = textures:newTexture(FOS_REGISTRY.system_name..".screen",FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y)

FOS_REGISTRY.screen_model:setPrimaryTexture("CUSTOM",screen)

local function drawText(obj)
   local characters = fontManager:text2pixels("minimojangles", tostring(obj.text))

   local text_pos = obj.pos or vec(0, 0)

   local x, y = 0, 0
   for i, data in pairs(characters) do
      for _, pos in ipairs(data.bitmap) do
         local pixel_x, pixel_y = text_pos.x + pos.x + x, text_pos.y + pos.y + y
         if pixel_x >= 0 and pixel_y >= 0 and pixel_x < FOS_REGISTRY.resolution.x and pixel_y < FOS_REGISTRY.resolution.y then
            screen:setPixel(text_pos.x + pos.x + x, text_pos.y + pos.y + y, vec(1, 1, 1, 1))
         end
      end
      if data.newline then
         x = 0
         y = y + 8
      else
         x = x + data.width
      end
   end
end

function raster.draw()
   local page = APP.app.pages[APP.app.current_page] or {}

   screen:applyFunc(0,0,FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y,function (col, x, y)
      return vec(0, 0 ,0,1)
   end)

   for i, v in ipairs(page) do
      if v.type == "text" then
         drawText(v)
      end
   end

   screen:update()
end


return raster