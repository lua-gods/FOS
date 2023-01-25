FOS_REGISTRY = {
   system_name="FOS",
   root_path = "", -- auto generated | sets the root path of all FOS services
   resolution = vectors.vec2(96,144), --12 * 8, 18 * 8
   font_texture_prefix = "font.", -- every texture with this prefix will be converted into a fontmap
   services = { -- a list of things that gets called as the FOS boots up, order from top to bottom
      "AppDevelopmentKit",
      "appManager",
      "fontManager",
      "raster",
      "ThemeManager"
   },
   screen_model = models.FOS.phone.screen,
}