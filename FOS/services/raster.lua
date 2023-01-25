-- purpose: handles the texture drawing

local screen = textures:newTexture(FOS_REGISTRY.system_name..".screen",FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y)
screen:fill(0,0,FOS_REGISTRY.resolution.x,FOS_REGISTRY.resolution.y,vec(1,0,0))
screen:update()
FOS_REGISTRY.screen_model:setPrimaryTexture("CUSTOM",screen)