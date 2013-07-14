define 'template/helpers/ctype', ['handlebars', 'underscore'], (Handlebars, _) -> 
  ctype = (context, options)->
    if context.length
      _.reduce(context, ((memo, label)->  memo + label.name + ' '), '')
    else
      "default"
 
  Handlebars.registerHelper('ctype', ctype)
