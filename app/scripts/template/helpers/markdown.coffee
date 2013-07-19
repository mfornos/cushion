define 'template/helpers/markdown', ['handlebars', 'marked'], (Handlebars, marked) -> 
  markdown = (context, options)->
  	marked context
 
  Handlebars.registerHelper('markdown', markdown)
