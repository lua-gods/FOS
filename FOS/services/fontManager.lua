-- Purpose: Font rendering for textures
-->========================================[ API ]=========================================<--
local font_version = "cookie" -- font version to not use cache when its old (also maybe we should get rid of cache? i dont know)
local font_manager = {}
local fonts = {}
font_manager.fonts = fonts
local char_map = "`1234567890-=~!@#$%^&*()_+qwertyuiop[]QWERTYUIOP{}asdfghjkl;'ASDFGHJKL:\"zxcvbnm,./ZXCVBNM<>?\\|"

function font_manager:renderFont(texture)
   local character_id = 1
   local font_package = {}
   local dim = texture:getDimensions()
   local character = {} -- a lookup table on how to draw the character
   local offset = 0
   font_package = {}
   for x = 0, dim.x-1, 1 do
      local empty_column = true
      for y = 0, dim.y-1, 1 do
         local data = texture:getPixel(x,y).x > 0.5
         if data then
            empty_column = false
            table.insert(character,vectors.vec2(x-offset,y))
         end
      end
      if empty_column then -- package character into the font
         font_package[char_map:sub(character_id,character_id)] = {bitmap=character,width=x-offset}
         
         character = {}
         character_id = character_id + 1
         offset = x
      end
   end
   font_package[" "] = {bitmap={},width=3}
   font_package["\n"] = {bitmap={},newline_height=8}
   font_package.VERSION = font_version
   return font_package
end

-->========================================[ MANAGER ]=========================================<--

for key, texture in pairs(textures:getTextures()) do
   local tex_name = texture:getName()
   if tex_name:sub(1,#SYSTEM_REGISTRY.font_texture_prefix) == SYSTEM_REGISTRY.font_texture_prefix then
      
      local font_namespace = tex_name:sub(#SYSTEM_REGISTRY.font_texture_prefix+1,#tex_name)
      
      config:setName(SYSTEM_REGISTRY.system_name..".".."fontcache")
      local cache = config:load(font_namespace)
      
      if cache and cache.VERSION == font_version then
         fonts[font_namespace] = cache
      else
         print("UPDATE")
         local font_package = font_manager:renderFont(texture)
         fonts[tex_name:sub(#SYSTEM_REGISTRY.font_texture_prefix+1,#tex_name)] = font_package
         config:setName(SYSTEM_REGISTRY.system_name..".".."fontcache")
         config:save(font_namespace,font_package)
      end
   end
end

return font_manager