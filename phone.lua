models.FOS.phone.base.screen:setPrimaryRenderType("EMISSIVE_SOLID")

local config = {
   portrait = {
      third_person = {
         pivot = vectors.vec3(4, 22, 0),
         offset = vectors.vec3(3, 10, -6),
         rotation = vectors.vec3(-80, 0, 0),
         scale = vectors.vec3(0.4, 0.4, 0.4),
      },
      first_person = {
         pivot = vectors.vec3(4, 22, 0),
         offset = vectors.vec3(9, -1, -9),
         rotation = vectors.vec3(-120, -60, 0),
         scale = vectors.vec3(0.8, 0.8, 0.8),
      }
   },
   landscape = {
      third_person = {
         pivot = vectors.vec3(4, 22, 0),
         offset = vectors.vec3(1, 9, -4.4),
         rotation = vectors.vec3(-90, 90, 0),
         left_hand_rotation = vectors.vec3(-90, -90, 0),
         scale = vectors.vec3(0.4, 0.4, 0.4),
      },
      first_person = {
         pivot = vectors.vec3(4, 22, 0),
         offset = vectors.vec3(5, 0, -14),
         rotation = vectors.vec3(-90,28, -38),
         left_hand_rotation = vectors.vec3(-90, 208, -38),
         scale = vectors.vec3(1, 1, 1),
      }
   }
}

local function applyTransformPreset(preset)
   models.FOS.phone:setScale(preset.scale)
   if player:isLeftHanded() then
      models.FOS:setParentType("LEFT_ARM")
      models.FOS:setPivot(
         -preset.pivot.x,
         preset.pivot.y,
         -preset.pivot.z)
      models.FOS.phone:setPos(-preset.offset.x,preset.offset.y,preset.offset.z)
      if preset.left_hand_rotation then
         models.FOS.phone.base:setRot(preset.left_hand_rotation.x,-preset.left_hand_rotation.y,-preset.left_hand_rotation.z)
      else
         models.FOS.phone.base:setRot(preset.rotation.x,-preset.rotation.y,-preset.rotation.z)
      end
   else
      models.FOS:setParentType("RIGHT_ARM")
      models.FOS:setPivot(
         preset.pivot.x,
         preset.pivot.y,
         preset.pivot.z)
      models.FOS.phone:setPos(preset.offset.x,preset.offset.y,preset.offset.z)
      models.FOS.phone.base:setRot(preset.rotation)
   end
end

events.ENTITY_INIT:register(function()
   applyTransformPreset(config.portrait.third_person)
end)

if not host:isHost() then return end

events.RENDER:register(function(dt, context)
   local orientation = APP and APP.landscapeMode() and "landscape" or "portrait"

   local render_type = nil
   if client.hasIrisShader() then
      if context == "FIRST_PERSON" or context == "OTHER" then
         render_type = 1
      else
         render_type = 0
      end
   else
      if context == "FIRST_PERSON" then
         render_type = 1
      else
         render_type = 0
      end
   end

   if render_type then
      applyTransformPreset(config[orientation][render_type == 1 and "first_person" or "third_person"])
   end
end)

local in_pocket = false
events.TICK:register(function()
   if not SYSTEM_REGISTRY then
      return
   end
   
   SYSTEM_REGISTRY.disable_system = false
   local hide_model = false

   if in_pocket then
      SYSTEM_REGISTRY.disable_system = true
      hide_model = true
   elseif player:getItem(1).id ~= "minecraft:air" then
      SYSTEM_REGISTRY.disable_system = true
      hide_model = true
   elseif host:isChatOpen() then
      SYSTEM_REGISTRY.disable_system = true
   end

   models.FOS:setVisible(not hide_model)
end)

keybinds:newKeybind("put in pocket", keybinds:getVanillaKey("figura.config.action_wheel_button")).press = function()
   in_pocket = not in_pocket
   print(in_pocket and "FOS is now in pocket" or "FOS in now in hand")
   return true
end

local os = require("FOS.OS")