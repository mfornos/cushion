define 'template/helpers/markdown', ['handlebars', 'marked'], (Handlebars) -> 
  markdown = (context, options)->
    window.marked context
 
  Handlebars.registerHelper('markdown', markdown)
