define 'template/helpers/contrast', ['handlebars'], (Handlebars) -> 
  contrast = (context, options)->
    if (luma(hex2rgb context) >= 165) then 'darker' else 'lighter'

  luma = (rgb)->
    (0.2126 * rgb[0]) + (0.7152 * rgb[1]) + (0.0722 * rgb[2])

  hex2rgb = (hex)->
    if hex.length == 4 or hex.length == 7
        hex = hex.substr(1)
    if hex.length == 3
        hex = hex.split("")
        hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2]
    u = parseInt(hex, 16)
    r = u >> 16
    g = u >> 8 & 0xFF
    b = u & 0xFF
    return [r,g,b]
 
  Handlebars.registerHelper('contrast', contrast)
