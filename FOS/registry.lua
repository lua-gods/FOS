local r = {
   system_name = "FOS",
   root_path = "", -- auto generated | sets the root path of all FOS services
   resolution = vectors.vec2(96,144), --12 * 8, 18 * 8
   font_texture_prefix = "font.", -- every texture with this prefix will be converted into a fontmap
   services = {
      "AppDevelopmentKit",
      "appManager",
      "fontManager",
      "raster",
      "ThemeManager"
   },
}

return r