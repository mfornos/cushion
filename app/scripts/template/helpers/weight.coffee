define 'template/helpers/weight', ['handlebars'], (Handlebars) -> 
  weight = (context, options)->
    return 'small' if context.comments < 3
    if context.comments < 8 then 'medium' else 'big'
 
  Handlebars.registerHelper('weight', weight)