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
         offset = vectors.vec3(8, -1, -8),
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
   if context == "FIRST_PERSON" then
      applyTransformPreset(config[orientation].first_person)
   elseif context == "RENDER" or context == "FIGURA_GUI" or context == "MINECRAFT_GUI" then
      applyTransformPreset(config[orientation].third_person)
   end
end)

local os = require("FOS.OS")