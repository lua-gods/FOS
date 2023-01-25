-- purpose: handles the texture drawing

local screen = textures:newTexture(FOS_REGISTRY.system_name..".screen",FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y)
screen:applyFunc(0,0,FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y,function (col, x, y)
   return vec(x/FOS_REGISTRY.resolution.x,y/FOS_REGISTRY.resolution.y,0,1)
end)
screen:update()
FOS_REGISTRY.screen_model:setPrimaryTexture("CUSTOM",screen)