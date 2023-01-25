models.FOS.phone.base.screen:setPrimaryRenderType("EMISSIVE_SOLID")
local config = {
   third_person = {
      pivot = vectors.vec3(4,22,0),
      offset = vectors.vec3(1,-10,-10),
      rotation = vectors.vec3(-100,0,0),
      scale = vectors.vec3(0.4,0.4,0.4),
   },
   first_person = {
      pivot = vectors.vec3(0,0,0),
      offset = vectors.vec3(8,2,-10),
      rotation = vectors.vec3(-120,-60,0),
      scale = vectors.vec3(0.8,0.8,0.8),
   }
}

local function applyTransformPreset(preset)
   models.FOS.phone:setScale(preset.scale)
   if player:isLeftHanded() then
      models.FOS:setParentType("LEFT_ARM")
      models.FOS.phone:setPivot(
         -preset.pivot.x-preset.offset.x,
         preset.pivot.y-preset.offset.y,
         -preset.pivot.z-preset.offset.z)
      models.FOS.phone:setPos(-preset.offset.x,preset.offset.y,preset.offset.z)
      models.FOS.phone.base:setRot(preset.rotation.x,-preset.rotation.y,-preset.rotation.z)
   else
      models.FOS:setParentType("RIGHT_ARM")
      models.FOS.phone:setPivot(
         preset.pivot.x-preset.offset.x,
         preset.pivot.y-preset.offset.y,
         preset.pivot.z-preset.offset.z)
      models.FOS.phone:setPos(preset.offset.x,preset.offset.y,preset.offset.z)
      models.FOS.phone.base:setRot(preset.rotation)
   end
end

events.ENTITY_INIT:register(function ()
   applyTransformPreset(config.third_person)
end)
if not host:isHost() then return end


events.RENDER:register(function (td,context)
   if player:isLoaded() then
      if context == "FIRST_PERSON" then
         applyTransformPreset(config.first_person)
      else
         applyTransformPreset(config.third_person)
      end
   end
end)

local os = require("FOS.OS")